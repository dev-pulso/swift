import Foundation

public enum ProductStatus: String, Codable, CaseIterable, Sendable {
    case active, inactive, archived
}

public struct Product: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let businessID: UUID
    public var name: String
    public var description: String
    public var category: String
    public var brand: String
    public var tags: [String]
    public var imageURLs: [URL]
    public var supplierID: UUID?
    public var status: ProductStatus
    /// Even a product without options has one default variant. Stock has one source of truth.
    public var variants: [ProductVariant]

    public init(id: UUID = UUID(), businessID: UUID, name: String,
                description: String = "", category: String = "", brand: String = "",
                tags: [String] = [], imageURLs: [URL] = [], supplierID: UUID? = nil,
                status: ProductStatus = .active, variants: [ProductVariant]) {
        self.id = id; self.businessID = businessID; self.name = name
        self.description = description; self.category = category; self.brand = brand
        self.tags = tags; self.imageURLs = imageURLs; self.supplierID = supplierID
        self.status = status; self.variants = variants
    }
}

public struct VariantOption: Codable, Equatable, Hashable, Sendable {
    public var name: String
    public var value: String
    public init(name: String, value: String) { self.name = name; self.value = value }
}

public struct ProductVariant: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var sku: String
    public var barcode: String?
    public var options: [VariantOption]
    public var price: Decimal
    public var cost: Decimal
    public var imageURL: URL?
    public var minimumStock: Int
    public var marginPercentage: Decimal? {
        price > 0 ? (price - cost) / price * 100 : nil
    }

    public init(id: UUID = UUID(), sku: String, barcode: String? = nil,
                options: [VariantOption] = [], price: Decimal, cost: Decimal,
                imageURL: URL? = nil, minimumStock: Int = 3) {
        self.id = id; self.sku = sku; self.barcode = barcode; self.options = options
        self.price = price; self.cost = cost; self.imageURL = imageURL
        self.minimumStock = minimumStock
    }
}
