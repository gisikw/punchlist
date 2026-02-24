import Foundation

@Observable
final class PunchlistViewModel {
    var items: [Item] = []
    var projects: [Project] = []
    var currentProjectSlug: String = "user"
    var isConnected: Bool { webSocket.isConnected }
    /// Only show offline UI when WS is down AND polling isn't covering.
    var showOffline: Bool { !isConnected && pollTask == nil }
    var debugLog: [String] { webSocket.debugLog }

    var currentProject: Project? {
        projects.first { $0.slug == currentProjectSlug }
    }

    var isPersonal: Bool { currentProjectSlug == "user" }
    var agentState: PunchlistAPI.AgentState?

    /// The slug sent to the server for API calls.
    var apiSlug: String { currentProjectSlug }

    private let api = PunchlistAPI()
    private let webSocket = WebSocketManager()
    private var pendingQueue: [() async -> Void] = []
    private var agentPollTask: Task<Void, Never>?
    private var pollTask: Task<Void, Never>?
    private var pollBurstUntil: Date = .distantPast
    private var connectionObserver: Task<Void, Never>?

    func start() {
        webSocket.start { [weak self] items in
            guard let self else { return }
            self.items = items
            self.stopPolling()
            self.drainQueue()
            self.refreshAgentStatus()
        }

        // Start polling fallback — it will self-suspend once WS connects.
        // Also observe connection changes to restart polling on disconnect.
        startPollingIfNeeded()
        observeConnection()

        Task {
            // Fetch project list, user (personal) first then alphabetical
            if let fetched = try? await api.fetchProjects() {
                self.projects = fetched.sorted { a, b in
                    if a.slug == "user" { return true }
                    if b.slug == "user" { return false }
                    return a.slug < b.slug
                }
            }

            // Fetch items for personal (user) project via REST as initial load
            if let fetched = try? await api.fetchItems(project: "user") {
                self.items = fetched
            }
        }
    }

    /// Reset to personal — called on app foreground, not on WS reconnect
    func resetToPersonal() {
        guard currentProjectSlug != "user" else { return }
        switchToProject(slug: "user")
    }

    func refresh() {
        webSocket.reconnect()
        let slug = apiSlug
        Task {
            if let fetched = try? await api.fetchItems(project: slug) {
                self.items = fetched
            }
        }
        refreshAgentStatus()
    }

    func stop() {
        webSocket.stop()
        stopPolling()
        connectionObserver?.cancel()
        agentPollTask?.cancel()
    }

    func switchToProject(slug: String) {
        guard slug != currentProjectSlug else { return }
        currentProjectSlug = slug
        agentState = nil

        // Tell the server to switch WS broadcast
        webSocket.switchProject(slug)

        // Also fetch via REST for immediate display
        Task {
            if let fetched = try? await api.fetchItems(project: slug) {
                self.items = fetched
            }
        }

        // Fetch agent status and start polling for non-personal projects
        startAgentPolling()
    }

    // MARK: - Actions

    func addItem(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let slug = apiSlug
        let action: () async -> Void = { [api] in
            try? await api.addItem(project: slug, text: trimmed)
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
        let slug = apiSlug
        let action: () async -> Void = { [api] in
            try? await api.toggleItem(project: slug, id: item.id)
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
        let slug = apiSlug
        let action: () async -> Void = { [api] in
            try? await api.bumpItem(project: slug, id: item.id)
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
        let slug = apiSlug
        let action: () async -> Void = { [api] in
            try? await api.deleteItem(project: slug, id: item.id)
        }

        if isConnected {
            Task { await action() }
        } else {
            items.removeAll { $0.id == item.id }
            pendingQueue.append(action)
        }
        afterAction()
    }

    /// After any mutation, burst-poll if WS is down so the UI stays fresh.
    private func afterAction() {
        guard !isConnected else { return }
        pollBurst()
    }

    // MARK: - Agent

    func toggleAgent() {
        guard !isPersonal, let state = agentState else { return }
        let slug = apiSlug
        Task {
            switch state {
            case .running:
                if let newState = try? await api.agentStop(project: slug) {
                    self.agentState = newState
                }
            case .notRunning:
                if let newState = try? await api.agentStart(project: slug) {
                    self.agentState = newState
                }
            case .notProvisioned:
                break
            }
        }
    }

    func refreshAgentStatus() {
        guard !isPersonal else { return }
        let slug = apiSlug
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

    // MARK: - Connection observation

    private func observeConnection() {
        connectionObserver?.cancel()
        connectionObserver = Task { [weak self] in
            var wasConnected = true
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled, let self else { break }
                let connected = self.isConnected
                if wasConnected && !connected {
                    // WS just went down — start polling
                    self.startPollingIfNeeded()
                }
                wasConnected = connected
            }
        }
    }

    // MARK: - Polling fallback

    /// Kick the poll loop into burst mode (1s interval for 10s).
    private func pollBurst() {
        pollBurstUntil = Date().addingTimeInterval(10)
        startPollingIfNeeded()
    }

    private func startPollingIfNeeded() {
        guard pollTask == nil else { return }
        pollTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let s = self else { break }
                // Stop polling when WS is healthy
                if s.isConnected { break }
                let interval: TimeInterval = Date() < s.pollBurstUntil ? 1.0 : 5.0
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled, let s = self else { break }
                if s.isConnected { break }
                let slug = s.apiSlug
                if let fetched = try? await s.api.fetchItems(project: slug) {
                    s.items = fetched
                }
            }
            self?.pollTask = nil
        }
    }

    private func stopPolling() {
        pollTask?.cancel()
        pollTask = nil
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
