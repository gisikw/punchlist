import Foundation

struct Project: Codable, Identifiable, Equatable {
    let slug: String
    let name: String
    let isDefault: Bool

    var id: String { slug }

    enum CodingKeys: String, CodingKey {
        case slug = "tag"
        case isDefault = "is_default"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        slug = try c.decode(String.self, forKey: .slug)
        name = slug
        isDefault = try c.decodeIfPresent(Bool.self, forKey: .isDefault) ?? false
    }

    init(slug: String, name: String? = nil, isDefault: Bool = false) {
        self.slug = slug
        self.name = name ?? slug
        self.isDefault = isDefault
    }
}
