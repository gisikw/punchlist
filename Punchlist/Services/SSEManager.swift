import Foundation

@Observable
final class SSEManager {
    var isConnected = false
    var debugLog: [String] = []

    private let baseURL: URL
    private var task: URLSessionDataTask?
    private var session: URLSession?
    private var delegate: SSEDelegate?
    private var reconnectDelay: TimeInterval = 1.0
    private var offlineTimer: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    private var onItems: (([Item]) -> Void)?
    private var connectCount = 0
    private var currentProjectSlug: String = "user"

    init(baseURL: URL = URL(string: "https://knockout.gisi.network")!) {
        self.baseURL = baseURL
    }

    /// Start listening. `onItems` is called with the full item list on connect
    /// and with updated items on each mutation event.
    func start(onItems: @escaping ([Item]) -> Void) {
        self.onItems = onItems
        log("start")
        connect()
    }

    func stop() {
        reconnectTask?.cancel()
        reconnectTask = nil
        task?.cancel()
        task = nil
        session?.invalidateAndCancel()
        session = nil
        delegate = nil
        offlineTimer?.cancel()
        log("stop")
    }

    func reconnect() {
        log("reconnect (foreground)")
        reconnectTask?.cancel()
        reconnectTask = nil
        disconnect()
        connect()
    }

    func switchProject(_ slug: String) {
        guard slug != currentProjectSlug else { return }
        currentProjectSlug = slug
        log("switch → \(slug)")
        disconnect()
        connect()
    }

    // MARK: - Connection

    private func connect() {
        connectCount += 1
        let attempt = connectCount
        log("connect #\(attempt) → \(currentProjectSlug)")

        // URL: /subscribe/#slug — construct from string to avoid double-encoding
        let url = URL(string: "\(baseURL.absoluteString)/subscribe/%23\(currentProjectSlug)")!
        var request = URLRequest(url: url)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.timeoutInterval = .infinity

        let del = SSEDelegate(
            onItems: { [weak self] items in self?.handleItems(items, attempt: attempt) },
            onComplete: { [weak self] in self?.handleDisconnect() }
        )
        self.delegate = del

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = .infinity
        config.timeoutIntervalForResource = .infinity
        let sess = URLSession(configuration: config, delegate: del, delegateQueue: nil)
        self.session = sess
        self.task = sess.dataTask(with: request)
        task?.resume()

        offlineTimer?.cancel()
    }

    private func disconnect() {
        task?.cancel()
        task = nil
        session?.invalidateAndCancel()
        session = nil
        delegate = nil
        isConnected = false
    }

    private func handleItems(_ items: [Item], attempt: Int) {
        if !isConnected {
            log("first event #\(attempt) — online (\(items.count) items)")
            DispatchQueue.main.async {
                self.isConnected = true
                self.reconnectDelay = 1.0
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.onItems?(items)
        }
    }

    private func handleDisconnect() {
        task = nil

        offlineTimer = Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if !Task.isCancelled {
                self.isConnected = false
                self.log("offline (3s elapsed)")
            }
        }

        let delay = reconnectDelay
        reconnectDelay = min(reconnectDelay * 2, 30)
        log("reconnect in \(delay)s")
        reconnectTask?.cancel()
        reconnectTask = Task {
            try? await Task.sleep(for: .seconds(delay))
            guard !Task.isCancelled else { return }
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

// MARK: - URLSession delegate for streaming SSE

private final class SSEDelegate: NSObject, URLSessionDataDelegate {
    private let onItems: ([Item]) -> Void
    private let onComplete: () -> Void
    private var buffer = ""
    private let decoder = JSONDecoder()
    /// Accumulate items across all data: lines in a single SSE frame burst.
    /// The server sends one data: line per ticket; an empty line terminates
    /// a logical batch (the full project state on connect, or a mutation set).
    private var pendingItems: [Item] = []

    init(onItems: @escaping ([Item]) -> Void, onComplete: @escaping () -> Void) {
        self.onItems = onItems
        self.onComplete = onComplete
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let chunk = String(data: data, encoding: .utf8) else { return }
        buffer += chunk

        // Process complete lines
        while let newline = buffer.range(of: "\n") {
            let line = String(buffer[buffer.startIndex..<newline.lowerBound])
            buffer = String(buffer[newline.upperBound...])

            if line.hasPrefix("data: ") {
                let payload = String(line.dropFirst(6))
                if let data = payload.data(using: .utf8),
                   let item = try? decoder.decode(Item.self, from: data) {
                    pendingItems.append(item)
                }
            } else if line.isEmpty && !pendingItems.isEmpty {
                // Empty line = end of event; deliver accumulated items
                let items = pendingItems
                pendingItems = []
                onItems(items)
            }
            // Skip non-data lines (retry:, id:, comments)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        onComplete()
    }
}
