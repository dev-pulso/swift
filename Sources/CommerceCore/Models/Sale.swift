import Foundation

public enum PaymentMethod: String, Codable, CaseIterable, Sendable {
    case cash, card, transfer, nequi, daviplata, other
}

public struct CartItem: Codable, Equatable, Sendable {
    public let variantID: UUID
    public let quantity: Int
    public init(variantID: UUID, quantity: Int) {
        self.variantID = variantID; self.quantity = quantity
    }
}

public struct CheckoutRequest: Sendable {
    /// Reuse the same ID when retrying a checkout; local repository is idempotent.
    public let id: UUID
    public let scope: StoreScope
    public let items: [CartItem]
    public let discount: Decimal
    public let customerID: UUID?
    public let sellerID: UUID
    public let paymentMethod: PaymentMethod
    public init(id: UUID = UUID(), scope: StoreScope, items: [CartItem],
                discount: Decimal = 0, customerID: UUID? = nil,
                sellerID: UUID, paymentMethod: PaymentMethod) {
        self.id = id; self.scope = scope; self.items = items; self.discount = discount
        self.customerID = customerID; self.sellerID = sellerID; self.paymentMethod = paymentMethod
    }
}

/// Immutable price and cost snapshots preserve historical reports after product edits.
public struct SaleLine: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let variantID: UUID
    public let productName: String
    public let variantLabel: String
    public let quantity: Int
    public let unitPrice: Decimal
    public let unitCost: Decimal
    public var subtotal: Decimal { unitPrice * Decimal(quantity) }
}

public struct Sale: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public let scope: StoreScope
    public let currencyCode: String
    public let lines: [SaleLine]
    public let subtotal: Decimal
    public let discount: Decimal
    public let tax: Decimal
    public let total: Decimal
    public let customerID: UUID?
    public let sellerID: UUID
    public let paymentMethod: PaymentMethod
    public let date: Date
    /// Gross profit only; expenses are a future module.
    public var estimatedGrossProfit: Decimal {
        subtotal - discount - lines.reduce(0) { $0 + $1.unitCost * Decimal($1.quantity) }
    }
}
