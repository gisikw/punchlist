import Foundation

struct Item: Codable, Identifiable, Equatable {
    let id: String
    var text: String
    var done: Bool
    let created: String
    var priority: Int?
    var status: String?
    var hasUnresolvedDep: Bool?
    var description: String?
    var planQuestions: [PlanQuestion]?
    var modified: String?
    var triage: String?

    enum CodingKeys: String, CodingKey {
        case id, created, priority, status, hasUnresolvedDep, description, modified, triage
        case text = "title"
        case planQuestions = "plan-questions"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        text = try c.decode(String.self, forKey: .text)
        created = try c.decode(String.self, forKey: .created)
        priority = try c.decodeIfPresent(Int.self, forKey: .priority)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        hasUnresolvedDep = try c.decodeIfPresent(Bool.self, forKey: .hasUnresolvedDep)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        planQuestions = try c.decodeIfPresent([PlanQuestion].self, forKey: .planQuestions)
        modified = try c.decodeIfPresent(String.self, forKey: .modified)
        triage = try c.decodeIfPresent(String.self, forKey: .triage)
        done = status == "closed"
    }

    /// Manual init for offline temp items
    init(id: String, text: String, done: Bool, created: String,
         priority: Int? = nil, status: String? = nil,
         hasUnresolvedDep: Bool? = nil, description: String? = nil) {
        self.id = id
        self.text = text
        self.done = done
        self.created = created
        self.priority = priority
        self.status = status
        self.hasUnresolvedDep = hasUnresolvedDep
        self.description = description
        self.planQuestions = nil
    }
}
