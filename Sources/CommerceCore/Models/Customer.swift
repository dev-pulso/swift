import Foundation

public struct Customer: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let businessID: UUID
    public var name: String
    public var contact: Contact
    public var birthday: Date?
    public var notes: String
    public var tags: [String]
    public let createdAt: Date

    public init(id: UUID = UUID(), businessID: UUID, name: String,
                contact: Contact = Contact(), birthday: Date? = nil,
                notes: String = "", tags: [String] = [], createdAt: Date = Date()) {
        self.id = id; self.businessID = businessID; self.name = name
        self.contact = contact; self.birthday = birthday; self.notes = notes
        self.tags = tags; self.createdAt = createdAt
    }
}
