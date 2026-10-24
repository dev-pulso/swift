import Foundation

public struct CustomerMetrics: Sendable {
    public let purchases: [Sale]
    public var totalSpent: Decimal { purchases.reduce(0) { $0 + $1.total } }
    public var lastPurchase: Date? { purchases.first?.date }
    public init(customerID: UUID, sales: [Sale]) {
        purchases = sales.filter { $0.customerID == customerID }.sorted { $0.date > $1.date }
    }
}

public struct BestSeller: Identifiable, Sendable {
    public var id: String { productName }
    public let productName: String
    public let quantity: Int
}

public enum SalesInsights {
    /// Historical names intentionally group receipts by name; IDs remain in individual receipts.
    public static func bestSellers(sales: [Sale], limit: Int = 5) -> [BestSeller] {
        var totals: [String: Int] = [:]
        for line in sales.flatMap(\.lines) {
            totals[line.productName, default: 0] += line.quantity
        }
        return totals.map { BestSeller(productName: $0.key, quantity: $0.value) }
            .sorted { $0.quantity == $1.quantity ? $0.productName < $1.productName : $0.quantity > $1.quantity }
            .prefix(max(0, limit)).map { $0 }
    }
}
