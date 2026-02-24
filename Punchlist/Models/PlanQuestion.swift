import Foundation

struct PlanOption: Identifiable {
    let id: String
    let label: String
    let value: String
    let description: String

    init(label: String, value: String, description: String) {
        self.id = value
        self.label = label
        self.value = value
        self.description = description
    }
}

struct PlanQuestion: Identifiable {
    let id: String
    let question: String
    let context: String?
    let options: [PlanOption]
}
