import Foundation

public struct StockLevel: Identifiable, Codable, Equatable, Sendable {
    public var id: String { "\(scope.branchID)-\(variantID)" }
    public let scope: StoreScope
    public let variantID: UUID
    public var quantity: Int
    public init(scope: StoreScope, variantID: UUID, quantity: Int) {
        self.scope = scope; self.variantID = variantID; self.quantity = quantity
    }
}

public enum InventoryReason: String, Codable, CaseIterable, Sendable {
    case sale, purchase, adjustment, customerReturn, damaged, correction
}

public struct InventoryMovement: Identifiable, Codable, Sendable {
    public let id: UUID
    public let scope: StoreScope
    public let variantID: UUID
    public let delta: Int
    public let resultingQuantity: Int
    public let reason: InventoryReason
    public let note: String
    public let saleID: UUID?
    public let date: Date
}
