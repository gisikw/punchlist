import Foundation

@Observable
final class WebSocketManager {
    var isConnected = false
    var debugLog: [String] = []

    private let url: URL
    private var task: URLSessionWebSocketTask?
    private var reconnectDelay: TimeInterval = 1.0
    private var offlineTimer: Task<Void, Never>?
    private var onItems: (([Item]) -> Void)?
    private var connectCount = 0

    init(url: URL = URL(string: "wss://punch.gisi.network/ws")!) {
        self.url = url
    }

    func start(onItems: @escaping ([Item]) -> Void) {
        self.onItems = onItems
        log("start")
        connect()
    }

    func stop() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        offlineTimer?.cancel()
        log("stop")
    }

    func switchProject(_ slug: String) {
        guard let task else { return }
        let msg = "{\"project\":\"\(slug)\"}"
        log("switch → \(slug)")
        task.send(.string(msg)) { [weak self] error in
            if let error {
                self?.log("switch send fail: \(error.localizedDescription)")
            }
        }
    }

    private func connect() {
        connectCount += 1
        let attempt = connectCount
        log("connect #\(attempt)")

        let session = URLSession(configuration: .default)
        task = session.webSocketTask(with: url)
        task?.resume()

        offlineTimer?.cancel()

        receiveLoop(attempt: attempt)
    }

    private func receiveLoop(attempt: Int) {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                if !self.isConnected {
                    self.log("first msg #\(attempt) — online")
                    DispatchQueue.main.async {
                        self.isConnected = true
                        self.reconnectDelay = 1.0
                    }
                }
                self.handleMessage(message)
                self.receiveLoop(attempt: attempt)
            case .failure(let error):
                self.log("recv fail #\(attempt): \(error.localizedDescription)")
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

        guard let items = try? JSONDecoder().decode([Item].self, from: data) else {
            log("decode fail")
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.onItems?(items)
        }
    }

    private func handleDisconnect() {
        task = nil

        // Show offline after 3s delay to avoid flicker on transient drops
        offlineTimer = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                self.isConnected = false
                self.log("offline (3s elapsed)")
            }
        }

        // Reconnect with exponential backoff
        let delay = reconnectDelay
        reconnectDelay = min(reconnectDelay * 2, 30)
        log("reconnect in \(delay)s")
        Task {
            try? await Task.sleep(for: .seconds(delay))
            self.connect()
        }
    }

    private func log(_ msg: String) {
        let ts = ISO8601DateFormatter().string(from: Date())
        let entry = "[\(ts)] \(msg)"
        DispatchQueue.main.async {
            self.debugLog.append(entry)
            if self.debugLog.count > 50 { self.debugLog.removeFirst() }
        }
    }
}
