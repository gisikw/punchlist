import Foundation

struct PunchlistAPI {
    let baseURL: URL

    init(baseURL: URL = URL(string: "https://punch.gisi.network")!) {
        self.baseURL = baseURL
    }

    // MARK: - Projects

    func fetchProjects() async throws -> [Project] {
        let url = baseURL.appendingPathComponent("api/projects")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Project].self, from: data)
    }

    // MARK: - Items (project-scoped)

    func fetchItems(project: String) async throws -> [Item] {
        let url = itemsURL(project: project)
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Item].self, from: data)
    }

    func addItem(project: String, text: String) async throws {
        let url = itemsURL(project: project)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["text": text])
        let _ = try await URLSession.shared.data(for: request)
    }

    func toggleItem(project: String, id: String) async throws {
        let url = itemURL(project: project, id: id)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        let _ = try await URLSession.shared.data(for: request)
    }

    func bumpItem(project: String, id: String) async throws {
        let url = itemURL(project: project, id: id).appendingPathComponent("bump")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let _ = try await URLSession.shared.data(for: request)
    }

    func deleteItem(project: String, id: String) async throws {
        let url = itemURL(project: project, id: id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - Plan Questions

    func fetchQuestions(project: String, id: String) async throws -> [PlanQuestion] {
        let url = itemURL(project: project, id: id).appendingPathComponent("questions")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([PlanQuestion].self, from: data)
    }

    func submitAnswers(project: String, id: String, answers: [String: String]) async throws {
        let url = itemURL(project: project, id: id).appendingPathComponent("questions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(answers)
        let _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - Agent

    enum AgentState: String, Codable {
        case running
        case notRunning = "not_running"
        case notProvisioned = "not_provisioned"
    }

    private struct AgentResponse: Codable {
        let state: AgentState
    }

    func agentStatus(project: String) async throws -> AgentState {
        let url = baseURL.appendingPathComponent("api/projects/\(project)/agent")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(AgentResponse.self, from: data).state
    }

    func agentStart(project: String) async throws -> AgentState {
        let url = baseURL.appendingPathComponent("api/projects/\(project)/agent/start")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AgentResponse.self, from: data).state
    }

    func agentStop(project: String) async throws -> AgentState {
        let url = baseURL.appendingPathComponent("api/projects/\(project)/agent/stop")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(AgentResponse.self, from: data).state
    }

    // MARK: - URL helpers

    private func itemsURL(project: String) -> URL {
        baseURL.appendingPathComponent("api/projects/\(project)/items")
    }

    private func itemURL(project: String, id: String) -> URL {
        baseURL.appendingPathComponent("api/projects/\(project)/items/\(id)")
    }
}
