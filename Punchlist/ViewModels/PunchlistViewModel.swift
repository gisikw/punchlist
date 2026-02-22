import Foundation

@Observable
final class PunchlistViewModel {
    var items: [Item] = []
    var projects: [Project] = []
    var currentProjectSlug: String = "personal"
    var isConnected: Bool { webSocket.isConnected }
    var debugLog: [String] { webSocket.debugLog }

    var currentProject: Project? {
        if currentProjectSlug == "personal" {
            return projects.first { $0.isDefault }
        }
        return projects.first { $0.slug == currentProjectSlug }
    }

    var isPersonal: Bool { currentProjectSlug == "personal" }
    var agentState: PunchlistAPI.AgentState?

    /// The slug used for API calls. nil means the server default (personal list).
    var currentSlug: String? {
        currentProjectSlug == "personal" ? nil : currentProjectSlug
    }

    private let api = PunchlistAPI()
    private let webSocket = WebSocketManager()
    private var pendingQueue: [() async -> Void] = []
    private var agentPollTask: Task<Void, Never>?

    func start() {
        webSocket.start { [weak self] items in
            guard let self else { return }
            self.items = items
            self.drainQueue()
            self.refreshAgentStatus()
        }

        Task {
            // Fetch project list
            if let fetched = try? await api.fetchProjects() {
                self.projects = fetched
            }

            // Fetch items for default project via REST as initial load
            if let fetched = try? await api.fetchItems(project: nil) {
                self.items = fetched
            }
        }
    }

    /// Reset to personal — called on app foreground, not on WS reconnect
    func resetToPersonal() {
        guard currentProjectSlug != "personal" else { return }
        switchToProject(slug: "personal")
    }

    func refresh() {
        webSocket.reconnect()
        let apiSlug = currentSlug
        Task {
            if let fetched = try? await api.fetchItems(project: apiSlug) {
                self.items = fetched
            }
        }
        refreshAgentStatus()
    }

    func stop() {
        webSocket.stop()
        agentPollTask?.cancel()
    }

    func switchToProject(slug: String) {
        guard slug != currentProjectSlug else { return }
        currentProjectSlug = slug
        agentState = nil

        // Tell the server to switch WS broadcast
        webSocket.switchProject(slug)

        // Also fetch via REST for immediate display
        let apiSlug = slug == "personal" ? nil : slug
        Task {
            if let fetched = try? await api.fetchItems(project: apiSlug) {
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

        let slug = currentSlug
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
    }

    func toggleItem(_ item: Item) {
        let slug = currentSlug
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
    }

    func bumpItem(_ item: Item) {
        let slug = currentSlug
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
    }

    func deleteItem(_ item: Item) {
        let slug = currentSlug
        let action: () async -> Void = { [api] in
            try? await api.deleteItem(project: slug, id: item.id)
        }

        if isConnected {
            Task { await action() }
        } else {
            items.removeAll { $0.id == item.id }
            pendingQueue.append(action)
        }
    }

    // MARK: - Agent

    func toggleAgent() {
        guard let slug = currentSlug, let state = agentState else { return }
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
        guard let slug = currentSlug else { return }
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
