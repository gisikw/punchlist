import Foundation

struct PunchlistAPI {
    let baseURL: URL

    init(baseURL: URL = URL(string: "https://PUNCH_API_HOST_REDACTED")!) {
        self.baseURL = baseURL
    }

    // MARK: - Projects

    func fetchProjects() async throws -> [Project] {
        let url = baseURL.appendingPathComponent("api/projects")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Project].self, from: data)
    }

    // MARK: - Items (project-scoped)

    func fetchItems(project: String?) async throws -> [Item] {
        let url = itemsURL(project: project)
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Item].self, from: data)
    }

    func addItem(project: String?, text: String) async throws {
        let url = itemsURL(project: project)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["text": text])
        let _ = try await URLSession.shared.data(for: request)
    }

    func toggleItem(project: String?, id: String) async throws {
        let url = itemURL(project: project, id: id)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        let _ = try await URLSession.shared.data(for: request)
    }

    func bumpItem(project: String?, id: String) async throws {
        let url = itemURL(project: project, id: id).appendingPathComponent("bump")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let _ = try await URLSession.shared.data(for: request)
    }

    func deleteItem(project: String?, id: String) async throws {
        let url = itemURL(project: project, id: id)
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let _ = try await URLSession.shared.data(for: request)
    }

    // MARK: - URL helpers

    private func itemsURL(project: String?) -> URL {
        if let project {
            return baseURL.appendingPathComponent("api/projects/\(project)/items")
        }
        return baseURL.appendingPathComponent("api/items")
    }

    private func itemURL(project: String?, id: String) -> URL {
        if let project {
            return baseURL.appendingPathComponent("api/projects/\(project)/items/\(id)")
        }
        return baseURL.appendingPathComponent("api/items/\(id)")
    }
}
