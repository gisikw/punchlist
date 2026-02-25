import Foundation

struct PlanOption: Identifiable, Codable {
    let label: String
    let value: String
    let description: String?

    var id: String { value }

    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case value = "Value"
        case description = "Description"
    }
}

struct PlanQuestion: Identifiable, Codable {
    let id: String
    let question: String
    let context: String?
    let options: [PlanOption]

    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case question = "Question"
        case context = "Context"
        case options = "Options"
    }
}
