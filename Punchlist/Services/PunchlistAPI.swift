import Foundation

struct PunchlistAPI {
    let baseURL: URL

    init(baseURL: URL = URL(string: "https://PUNCH_API_HOST_REDACTED")!) {
        self.baseURL = baseURL
    }

    func fetchItems() async throws -> [Item] {
        let url = baseURL.appendingPathComponent("api/items")
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode([Item].self, from: data)
    }

    func addItem(text: String) async throws {
        let url = baseURL.appendingPathComponent("api/items")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["text": text])
        let _ = try await URLSession.shared.data(for: request)
    }

    func toggleItem(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/items/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        let _ = try await URLSession.shared.data(for: request)
    }

    func bumpItem(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/items/\(id)/bump")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let _ = try await URLSession.shared.data(for: request)
    }

    func deleteItem(id: String) async throws {
        let url = baseURL.appendingPathComponent("api/items/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        let _ = try await URLSession.shared.data(for: request)
    }
}
