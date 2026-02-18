import Foundation

@Observable
final class PunchlistViewModel {
    var items: [Item] = []
    var isConnected: Bool { webSocket.isConnected }
    var debugLog: [String] { webSocket.debugLog }

    private let api = PunchlistAPI()
    private let webSocket = WebSocketManager()
    private var pendingQueue: [() async -> Void] = []

    func start() {
        webSocket.start { [weak self] items in
            guard let self else { return }
            self.items = items
            self.drainQueue()
        }

        // Also fetch via REST as initial load
        Task {
            if let fetched = try? await api.fetchItems() {
                self.items = fetched
            }
        }
    }

    func stop() {
        webSocket.stop()
    }

    // MARK: - Actions

    func addItem(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let action: () async -> Void = { [api] in
            try? await api.addItem(text: trimmed)
        }

        if isConnected {
            Task { await action() }
        } else {
            // Optimistic local insert
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
        let action: () async -> Void = { [api] in
            try? await api.toggleItem(id: item.id)
        }

        if isConnected {
            Task { await action() }
        } else {
            // Optimistic toggle + reposition
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
    }

    func deleteItem(_ item: Item) {
        let action: () async -> Void = { [api] in
            try? await api.deleteItem(id: item.id)
        }

        if isConnected {
            Task { await action() }
        } else {
            items.removeAll { $0.id == item.id }
            pendingQueue.append(action)
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
