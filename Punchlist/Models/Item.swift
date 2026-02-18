import Foundation

struct Item: Codable, Identifiable, Equatable {
    let id: String
    var text: String
    var done: Bool
    let created: String
}
