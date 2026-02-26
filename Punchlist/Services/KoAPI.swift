import Foundation

struct KoAPI {
    let baseURL: URL

    init(baseURL: URL = URL(string: "https://knockout.gisi.network")!) {
        self.baseURL = baseURL
    }

    // MARK: - Projects

    func fetchProjects() async throws -> [Project] {
        let output = try await run(["project", "ls", "--json"])
        return try JSONDecoder().decode([Project].self, from: output)
    }

    // MARK: - Items

    func fetchItems(project: String) async throws -> [Item] {
        let output = try await run(["ls", "--project=\(project)", "--json"])
        return try JSONDecoder().decode([Item].self, from: output)
    }

    /// Returns the new ticket ID.
    @discardableResult
    func addItem(project: String, title: String) async throws -> String {
        let output = try await run(["add", "--project=\(project)", title])
        // ko add prints the new ticket ID as plain text
        return String(data: output, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    func closeItem(id: String) async throws {
        _ = try await run(["close", id])
    }

    func openItem(id: String) async throws {
        _ = try await run(["open", id])
    }

    func bumpItem(id: String) async throws {
        _ = try await run(["bump", id])
    }

    // MARK: - Plan Questions

    func fetchQuestions(id: String) async throws -> [PlanQuestion] {
        let output = try await run(["show", id, "--json"])
        let ticket = try JSONDecoder().decode(ShowResponse.self, from: output)
        return ticket.planQuestions ?? []
    }

    func submitAnswers(id: String, answers: [String: String]) async throws {
        let json = try JSONEncoder().encode(answers)
        let jsonStr = String(data: json, encoding: .utf8) ?? "{}"
        _ = try await run(["update", id, "--answers", jsonStr])
    }

    // MARK: - Agent

    enum AgentState: String, Codable {
        case running
        case notRunning = "not_running"
        case notProvisioned = "not_provisioned"
    }

    func agentStatus(project: String) async throws -> AgentState {
        let output = try await run(["agent", "status", "--project=\(project)", "--json"])
        let resp = try JSONDecoder().decode(AgentStatusResponse.self, from: output)
        return resp.state
    }

    func agentStart(project: String) async throws -> AgentState {
        let output = try await run(["agent", "start", "--project=\(project)"])
        if let resp = try? JSONDecoder().decode(AgentStatusResponse.self, from: output) {
            return resp.state
        }
        return .running
    }

    func agentStop(project: String) async throws -> AgentState {
        let output = try await run(["agent", "stop", "--project=\(project)"])
        if let resp = try? JSONDecoder().decode(AgentStatusResponse.self, from: output) {
            return resp.state
        }
        return .notRunning
    }

    // MARK: - Transport

    private func run(_ argv: [String]) async throws -> Data {
        let endpoint = URL(string: "\(baseURL.absoluteString)/ko")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(KoRequest(argv: argv))
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw KoError.serverError(status: http.statusCode, body: body)
        }
        return data
    }

    // MARK: - Wire types

    private struct KoRequest: Encodable {
        let argv: [String]
    }

    private struct AgentStatusResponse: Decodable {
        let provisioned: Bool
        let running: Bool

        var state: AgentState {
            if !provisioned { return .notProvisioned }
            return running ? .running : .notRunning
        }
    }

    private struct ShowResponse: Decodable {
        let planQuestions: [PlanQuestion]?

        enum CodingKeys: String, CodingKey {
            case planQuestions = "plan-questions"
        }
    }

    enum KoError: LocalizedError {
        case serverError(status: Int, body: String)

        var errorDescription: String? {
            switch self {
            case .serverError(let status, let body):
                return "ko server error \(status): \(body)"
            }
        }
    }
}
