import Foundation

@Observable
final class PunchlistViewModel {
    var items: [Item] = []
    var projects: [Project] = []
    var currentProjectSlug: String = "user"
    var isConnected: Bool { sse.isConnected }
    /// Only show offline UI when SSE is down AND polling isn't covering
    /// AND we've been running long enough to rule out cold-start latency.
    var showOffline: Bool {
        !isConnected && pollTask == nil &&
        Date().timeIntervalSince(startDate) > 3
    }
    var debugLog: [String] { sse.debugLog }

    /// Cached plan questions per item ID. Populated on expand of blocked items.
    var questionsForItem: [String: [PlanQuestion]] = [:]

    var currentProject: Project? {
        projects.first { $0.slug == currentProjectSlug }
    }

    var isPersonal: Bool { currentProjectSlug == "user" }
    var agentState: KoAPI.AgentState?
    var agentSessionStartTime: Date?
    var showCompletedFromSession: Bool = false {
        didSet {
            UserDefaults.standard.set(showCompletedFromSession, forKey: showCompletedSessionKey)
        }
    }

    var hasReviewableSession: Bool {
        agentSessionStartTime != nil && agentState != .running
    }

    var hasUnblockedTickets: Bool {
        items.contains { !$0.done && $0.status != "blocked" }
    }

    private let api = KoAPI()
    private let sse = SSEManager()
    private var startDate: Date = Date()
    private var pendingQueue: [() async -> Void] = []
    private var agentPollTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var pollBurstUntil: Date = .distantPast
    private var connectionObserver: Task<Void, Never>?
    private var hasInitialLoad: Bool = false
    private var hasHandledInitialSSE: Bool = false

    private var agentSessionKey: String {
        "agentSessionStartTime_\(currentProjectSlug)"
    }

    private var showCompletedSessionKey: String {
        "showCompletedFromSession_\(currentProjectSlug)"
    }

    func start() {
        startDate = Date()

        // Populate with default "user" project immediately to prevent empty drawer
        projects = [Project(slug: "user", name: "user", isDefault: true)]

        // Load any persisted session state for the personal project
        // This ensures cold start behavior matches the switchToProject() behavior
        let timestamp = UserDefaults.standard.double(forKey: agentSessionKey)
        agentSessionStartTime = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil
        showCompletedFromSession = UserDefaults.standard.bool(forKey: showCompletedSessionKey)

        sse.start { [weak self] items in
            guard let self else { return }
            // Skip the first SSE callback if REST fetch has already loaded data,
            // to avoid race condition where SSE overwrites completed items on cold start.
            // After skipping once, allow all subsequent SSE updates through.
            if self.hasInitialLoad && !self.hasHandledInitialSSE {
                self.hasHandledInitialSSE = true
            } else {
                self.items = self.filtered(items)
            }
            self.stopPolling()
            self.drainQueue()
            self.refreshAgentStatus()
        }

        // Start polling fallback — it will self-suspend once SSE connects.
        // Also observe connection changes to restart polling on disconnect.
        startPollingIfNeeded()
        observeConnection()

        Task {
            // Retry logic with exponential backoff for project fetch
            var fetched: [Project]?
            let retryDelays: [TimeInterval] = [0.5, 1.0, 2.0]
            for (attempt, delay) in [(0, 0.0)] + retryDelays.enumerated().map({ ($0.offset + 1, $0.element) }) {
                do {
                    fetched = try await api.fetchProjects()
                    break
                } catch {
                    if attempt < retryDelays.count {
                        try? await Task.sleep(for: .seconds(delay))
                    }
                }
            }

            if let fetched {
                self.projects = fetched.sorted { a, b in
                    if a.slug == "user" { return true }
                    if b.slug == "user" { return false }
                    return a.slug < b.slug
                }
            }

            // Fetch items for personal (user) project via REST as initial load
            if let fetched = try? await api.fetchItems(project: "user") {
                self.items = self.filtered(fetched)
                self.hasInitialLoad = true
            }
        }
    }

    /// Reset to personal — called on app foreground, not on SSE reconnect
    func resetToPersonal() {
        guard currentProjectSlug != "user" else { return }
        switchToProject(slug: "user")
    }

    func refresh() {
        startDate = Date()
        sse.reconnect()
        let slug = currentProjectSlug
        Task {
            // Re-fetch projects to recover from initial load failures
            if let fetched = try? await api.fetchProjects() {
                self.projects = fetched.sorted { a, b in
                    if a.slug == "user" { return true }
                    if b.slug == "user" { return false }
                    return a.slug < b.slug
                }
            }

            if let fetched = try? await api.fetchItems(project: slug) {
                self.items = self.filtered(fetched)
            }
        }
        refreshAgentStatus()
    }

    func stop() {
        sse.stop()
        stopPolling()
        connectionObserver?.cancel()
        agentPollTask?.cancel()
    }

    func switchToProject(slug: String) {
        guard slug != currentProjectSlug else { return }
        currentProjectSlug = slug
        agentState = nil

        // Reset initial load flags for the new project
        hasInitialLoad = false
        hasHandledInitialSSE = false

        // Load session timestamp from UserDefaults for the new project
        let timestamp = UserDefaults.standard.double(forKey: agentSessionKey)
        agentSessionStartTime = timestamp > 0 ? Date(timeIntervalSince1970: timestamp) : nil

        // Load showCompletedFromSession from UserDefaults for the new project
        showCompletedFromSession = UserDefaults.standard.bool(forKey: showCompletedSessionKey)

        // SSE is URL-scoped per project; reconnect to new stream
        sse.switchProject(slug)

        // Also fetch via REST for immediate display
        Task {
            if let fetched = try? await api.fetchItems(project: slug) {
                self.items = self.filtered(fetched)
                self.hasInitialLoad = true
            }
        }

        startAgentPolling()
    }

    // MARK: - Actions

    func addItem(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let slug = currentProjectSlug
        let action: () async -> Void = { [api] in
            try? await api.addItem(project: slug, title: trimmed)
        }

        if isConnected {
            Task { await action() }
        } else {
            let temp = Item(
                id: String(Int(Date().timeIntervalSince1970 * 1_000_000_000)),
                text: trimmed,
                done: false,
                created: ISO8601DateFormatter().string(from: Date())
            )
            items.insert(temp, at: 0)
            pendingQueue.append(action)
        }
        afterAction()
    }

    func toggleItem(_ item: Item) {
        let action: () async -> Void = { [api] in
            if item.done {
                try? await api.openItem(id: item.id)
            } else {
                try? await api.closeItem(id: item.id)
            }
        }

        if isConnected {
            Task { await action() }
        } else {
            guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
            var toggled = items[idx]
            toggled.done.toggle()
            items.remove(at: idx)
            if toggled.done {
                items.append(toggled)
            } else {
                items.insert(toggled, at: 0)
            }
            pendingQueue.append(action)
        }
        afterAction()
    }

    func bumpItem(_ item: Item) {
        let action: () async -> Void = { [api] in
            try? await api.bumpItem(id: item.id)
        }

        if isConnected {
            Task { await action() }
        } else {
            guard let idx = items.firstIndex(where: { $0.id == item.id }), idx > 0 else { return }
            let bumped = items.remove(at: idx)
            items.insert(bumped, at: 0)
            pendingQueue.append(action)
        }
        afterAction()
    }

    func deleteItem(_ item: Item) {
        // ko doesn't have a delete command — close the item instead
        let action: () async -> Void = { [api] in
            try? await api.closeItem(id: item.id)
        }

        if isConnected {
            Task { await action() }
        } else {
            items.removeAll { $0.id == item.id }
            pendingQueue.append(action)
        }
        afterAction()
    }

    /// After any mutation, burst-poll if SSE is down so the UI stays fresh.
    private func afterAction() {
        guard !isConnected else { return }
        pollBurst()
    }

    // MARK: - Agent

    func clearAgentSession() {
        agentSessionStartTime = nil
        showCompletedFromSession = false
        UserDefaults.standard.removeObject(forKey: agentSessionKey)
        UserDefaults.standard.removeObject(forKey: showCompletedSessionKey)
    }

    func toggleAgent() {
        guard !isPersonal, let state = agentState else { return }
        let slug = currentProjectSlug
        Task {
            switch state {
            case .running:
                if let newState = try? await api.agentStop(project: slug) {
                    self.agentState = newState
                }
            case .notRunning:
                if let newState = try? await api.agentStart(project: slug) {
                    self.agentState = newState
                    // Save session start timestamp
                    let now = Date()
                    self.agentSessionStartTime = now
                    UserDefaults.standard.set(now.timeIntervalSince1970, forKey: self.agentSessionKey)
                }
            case .notProvisioned:
                break
            }
        }
    }

    func refreshAgentStatus() {
        guard !isPersonal else { return }
        let slug = currentProjectSlug
        Task {
            if let state = try? await api.agentStatus(project: slug) {
                self.agentState = state
            }
        }
    }

    private func startAgentPolling() {
        agentPollTask?.cancel()
        guard !isPersonal else { return }
        refreshAgentStatus()
        agentPollTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                self?.refreshAgentStatus()
            }
        }
    }

    // MARK: - Plan Questions

    func fetchQuestions(for itemID: String) {
        Task {
            if let questions = try? await api.fetchQuestions(id: itemID) {
                self.questionsForItem[itemID] = questions
            }
        }
    }

    func submitAnswers(for itemID: String, answers: [String: String]) {
        guard !answers.isEmpty else { return }
        Task {
            try? await api.submitAnswers(id: itemID, answers: answers)
        }
        questionsForItem.removeValue(forKey: itemID)
    }

    // MARK: - Connection observation

    private func observeConnection() {
        connectionObserver?.cancel()
        connectionObserver = Task { [weak self] in
            guard let self else { return }
            var wasConnected = self.isConnected
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { break }
                let connected = self.isConnected
                if wasConnected && !connected {
                    self.startPollingIfNeeded()
                }
                wasConnected = connected
            }
        }
    }

    // MARK: - Polling fallback

    private func pollBurst() {
        pollBurstUntil = Date().addingTimeInterval(10)
        startPollingIfNeeded()
    }

    private func startPollingIfNeeded() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let s = self else { break }
                if s.isConnected { break }
                let interval: TimeInterval = Date() < s.pollBurstUntil ? 1.0 : 5.0
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled, let s = self else { break }
                if s.isConnected { break }
                let slug = s.currentProjectSlug
                if let fetched = try? await s.api.fetchItems(project: slug) {
                    s.items = s.filtered(fetched)
                }
            }
            self?.pollTask = nil
        }
    }

    private func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
    }

    // MARK: - Filtering

    /// Personal shows all items; project views hide closed.
    /// When showCompletedFromSession is true, include closed items modified after agentSessionStartTime.
    internal func filtered(_ items: [Item]) -> [Item] {
        if isPersonal { return items }

        return items.filter { item in
            if !item.done { return true }

            // Include closed items from current session if review mode is active
            guard showCompletedFromSession,
                  let sessionStart = agentSessionStartTime,
                  let modifiedString = item.modified else {
                return false
            }

            // Parse ISO8601 timestamp and compare with session start
            let formatter = ISO8601DateFormatter()
            guard let modifiedDate = formatter.date(from: modifiedString) else {
                return false
            }

            return modifiedDate >= sessionStart
        }
    }

    // MARK: - Queue

    private func drainQueue() {
        guard isConnected, !pendingQueue.isEmpty else { return }
        let queued = pendingQueue
        pendingQueue = []
        Task {
            for action in queued {
                await action()
            }
        }
    }
}
