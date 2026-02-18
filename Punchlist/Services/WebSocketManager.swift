import Foundation

@Observable
final class WebSocketManager {
    var isConnected = false

    private let url: URL
    private var task: URLSessionWebSocketTask?
    private var reconnectDelay: TimeInterval = 1.0
    private var offlineTimer: Task<Void, Never>?
    private var onItems: (([Item]) -> Void)?

    init(url: URL = URL(string: "wss://PUNCH_API_HOST_REDACTED/ws")!) {
        self.url = url
    }

    func start(onItems: @escaping ([Item]) -> Void) {
        self.onItems = onItems
        connect()
    }

    func stop() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        offlineTimer?.cancel()
    }

    private func connect() {
        let session = URLSession(configuration: .default)
        task = session.webSocketTask(with: url)
        task?.resume()

        isConnected = true
        offlineTimer?.cancel()
        reconnectDelay = 1.0

        receiveLoop()
    }

    private func receiveLoop() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.receiveLoop()
            case .failure:
                self.handleDisconnect()
            }
        }
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        let data: Data
        switch message {
        case .string(let text):
            data = Data(text.utf8)
        case .data(let d):
            data = d
        @unknown default:
            return
        }

        guard let items = try? JSONDecoder().decode([Item].self, from: data) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.onItems?(items)
        }
    }

    private func handleDisconnect() {
        task = nil

        // Show offline after 3s delay to avoid flicker
        offlineTimer = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            self.isConnected = false
        }

        // Reconnect with exponential backoff
        let delay = reconnectDelay
        reconnectDelay = min(reconnectDelay * 2, 30)
        Task {
            try? await Task.sleep(for: .seconds(delay))
            self.connect()
        }
    }
}
