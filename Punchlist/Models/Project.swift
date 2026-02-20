import Foundation

struct Project: Codable, Identifiable, Equatable {
    let slug: String
    let name: String
    let isDefault: Bool

    var id: String { slug }

    enum CodingKeys: String, CodingKey {
        case slug, name
        case isDefault = "default"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        slug = try c.decode(String.self, forKey: .slug)
        name = try c.decode(String.self, forKey: .name)
        isDefault = try c.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
    }
}
