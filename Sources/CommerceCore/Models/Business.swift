import Foundation

public enum BusinessKind: String, Codable, CaseIterable, Sendable {
    case clothing, shoes, fragrance, makeup, accessories, jewelry, bags
    case sports, electronics, gifts, handmade, other
}

public enum MemberRole: String, Codable, Sendable {
    case owner, manager, seller, inventoryManager
}

public struct Business: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public var name: String
    public var kind: BusinessKind
    public var currencyCode: String
    public var countryCode: String
    public var city: String
    public var contact: Contact
    public var logoURL: URL?
    public var accentHex: String?
    /// Fraction: 0.19 means 19%. Prices exclude tax in the initial MVP.
    public var taxRate: Decimal

    public init(id: UUID = UUID(), name: String, kind: BusinessKind,
                currencyCode: String = "COP", countryCode: String = "CO",
                city: String = "", contact: Contact = Contact(),
                logoURL: URL? = nil, accentHex: String? = nil, taxRate: Decimal = 0) {
        self.id = id; self.name = name; self.kind = kind
        self.currencyCode = currencyCode; self.countryCode = countryCode
        self.city = city; self.contact = contact; self.logoURL = logoURL
        self.accentHex = accentHex; self.taxRate = taxRate
    }
}

public struct Contact: Codable, Equatable, Hashable, Sendable {
    public var phone: String
    public var email: String
    public var address: String
    public init(phone: String = "", email: String = "", address: String = "") {
        self.phone = phone; self.email = email; self.address = address
    }
}

public struct Branch: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let businessID: UUID
    public var name: String
    public init(id: UUID = UUID(), businessID: UUID, name: String) {
        self.id = id; self.businessID = businessID; self.name = name
    }
}

/// Explicit scope for every repository call; never inferred from a global singleton.
public struct StoreScope: Codable, Equatable, Hashable, Sendable {
    public let businessID: UUID
    public let branchID: UUID
    public init(businessID: UUID, branchID: UUID) {
        self.businessID = businessID; self.branchID = branchID
    }
}

public struct Membership: Identifiable, Codable, Sendable {
    public let id: UUID
    public let userID: UUID
    public let businessID: UUID
    public var role: MemberRole
}
