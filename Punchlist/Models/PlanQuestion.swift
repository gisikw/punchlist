import Foundation

struct PlanOption: Identifiable, Codable, Equatable {
    let label: String
    let value: String
    let description: String?

    var id: String { value }
}

struct PlanQuestion: Identifiable, Codable, Equatable {
    let id: String
    let question: String
    let context: String?
    let options: [PlanOption]
}
