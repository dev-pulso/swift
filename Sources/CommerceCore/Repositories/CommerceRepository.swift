import Foundation

public struct StoreSnapshot: Codable, Sendable {
    public var businesses: [Business]
    public var branches: [Branch]
    public var products: [Product]
    public var stock: [StockLevel]
    public var customers: [Customer]
    public var sales: [Sale]
    public var movements: [InventoryMovement]

    public init(businesses: [Business] = [], branches: [Branch] = [], products: [Product] = [],
                stock: [StockLevel] = [], customers: [Customer] = [], sales: [Sale] = [],
                movements: [InventoryMovement] = []) {
        self.businesses = businesses; self.branches = branches; self.products = products
        self.stock = stock; self.customers = customers; self.sales = sales; self.movements = movements
    }
}

public struct BusinessData: Sendable {
    public let business: Business
    public let products: [Product]
    public let stock: [StockLevel]
    public let customers: [Customer]
    public let sales: [Sale]
    public let movements: [InventoryMovement]
}

public enum CommerceError: Error, LocalizedError, Equatable {
    case invalidScope, invalidProduct, duplicateSKU, missingVariant, insufficientStock
    case invalidQuantity, invalidDiscount, invalidCustomer, invalidBusiness, invalidReason

    public var errorDescription: String? {
        switch self {
        case .invalidScope: return "No se encontró la tienda o sucursal seleccionada."
        case .invalidProduct: return "Revisa nombre, variantes, precios y stock mínimo."
        case .duplicateSKU: return "Cada variante debe tener un SKU único en la tienda."
        case .missingVariant: return "Una variante ya no está disponible para la venta."
        case .insufficientStock: return "No hay unidades suficientes para completar la operación."
        case .invalidQuantity: return "Revisa las cantidades de la operación."
        case .invalidDiscount: return "El descuento debe estar entre cero y el subtotal."
        case .invalidCustomer: return "El cliente no pertenece a esta tienda."
        case .invalidBusiness: return "Revisa el nombre, la moneda y la tasa de impuesto."
        case .invalidReason: return "Indica un motivo; las ventas se registran desde el POS."
        }
    }
}

/// Backend adapters implement this boundary. Authorization must be enforced server-side in production.
public protocol CommerceRepository: Sendable {
    func businesses() async throws -> [Business]
    func scopes(businessID: UUID) async throws -> [StoreScope]
    func createBusiness(_ business: Business) async throws -> StoreScope
    func data(in scope: StoreScope) async throws -> BusinessData
    func saveProduct(_ product: Product, in scope: StoreScope) async throws
    func saveCustomer(_ customer: Customer, in scope: StoreScope) async throws
    func adjustStock(variantID: UUID, delta: Int, reason: InventoryReason,
                     note: String, in scope: StoreScope) async throws
    func checkout(_ request: CheckoutRequest) async throws -> Sale
}
