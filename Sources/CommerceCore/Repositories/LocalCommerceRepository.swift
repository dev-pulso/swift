import Foundation

/// Serialized transactions. Copy -> validate -> persist atomically -> publish.
/// A failed write leaves both stock and sales unchanged in memory.
public actor LocalCommerceRepository: CommerceRepository {
    private var snapshot: StoreSnapshot
    private let fileURL: URL?

    /// nil URL is an ephemeral preview/test repository. A supplied URL enables JSON persistence.
    /// Corrupted persisted data throws; it is never silently replaced with mocks.
    public init(seed: StoreSnapshot = StoreSnapshot(), fileURL: URL? = nil) throws {
        self.fileURL = fileURL
        if let fileURL, FileManager.default.fileExists(atPath: fileURL.path) {
            self.snapshot = try JSONDecoder().decode(StoreSnapshot.self, from: Data(contentsOf: fileURL))
        } else {
            self.snapshot = seed
        }
    }

    public func businesses() async throws -> [Business] { snapshot.businesses }

    public func scopes(businessID: UUID) async throws -> [StoreScope] {
        snapshot.branches.filter { $0.businessID == businessID }.map {
            StoreScope(businessID: businessID, branchID: $0.id)
        }
    }

    public func createBusiness(_ business: Business) async throws -> StoreScope {
        guard !business.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              Money.supportedCurrencies.contains(business.currencyCode),
              business.taxRate >= 0, business.taxRate <= 1,
              !snapshot.businesses.contains(where: { $0.id == business.id }) else {
            throw CommerceError.invalidBusiness
        }
        var next = snapshot
        let branch = Branch(businessID: business.id, name: "Principal")
        next.businesses.append(business); next.branches.append(branch)
        try commit(next)
        return StoreScope(businessID: business.id, branchID: branch.id)
    }

    public func data(in scope: StoreScope) async throws -> BusinessData {
        let business = try validate(scope)
        return BusinessData(business: business,
            products: snapshot.products.filter { $0.businessID == scope.businessID },
            stock: snapshot.stock.filter { $0.scope == scope },
            customers: snapshot.customers.filter { $0.businessID == scope.businessID },
            sales: snapshot.sales.filter { $0.scope == scope }.sorted { $0.date > $1.date },
            movements: snapshot.movements.filter { $0.scope == scope }.sorted { $0.date > $1.date })
    }

    public func saveProduct(_ product: Product, in scope: StoreScope) async throws {
        _ = try validate(scope)
        guard product.businessID == scope.businessID,
              !product.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !product.variants.isEmpty,
              Set(product.variants.map(\.id)).count == product.variants.count,
              product.variants.allSatisfy({ !$0.sku.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                  $0.price >= 0 && $0.cost >= 0 && $0.minimumStock >= 0 &&
                  $0.price == Money.rounded($0.price) && $0.cost == Money.rounded($0.cost) }) else {
            throw CommerceError.invalidProduct
        }
        if let existing = snapshot.products.first(where: { $0.id == product.id }) {
            // Existing variant IDs cannot disappear: they may be referenced by stock and receipts.
            guard existing.businessID == product.businessID,
                  Set(existing.variants.map(\.id)).isSubset(of: Set(product.variants.map(\.id))) else {
                throw CommerceError.invalidProduct
            }
        }
        let others = snapshot.products.filter { $0.id != product.id }
        let otherIDs = Set(others.flatMap { $0.variants.map(\.id) })
        guard product.variants.allSatisfy({ !otherIDs.contains($0.id) }) else {
            throw CommerceError.invalidProduct
        }
        let skus = product.variants.map { $0.sku.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        let existingSKUs = Set(others.filter { $0.businessID == scope.businessID }
            .flatMap { $0.variants.map { $0.sku.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() } })
        guard Set(skus).count == skus.count, Set(skus).isDisjoint(with: existingSKUs) else {
            throw CommerceError.duplicateSKU
        }
        var next = snapshot
        if let index = next.products.firstIndex(where: { $0.id == product.id }) {
            next.products[index] = product
        } else { next.products.append(product) }
        try commit(next)
    }

    public func saveCustomer(_ customer: Customer, in scope: StoreScope) async throws {
        _ = try validate(scope)
        guard customer.businessID == scope.businessID,
              !customer.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CommerceError.invalidCustomer
        }
        var next = snapshot
        if let index = next.customers.firstIndex(where: { $0.id == customer.id }) {
            guard next.customers[index].businessID == scope.businessID else { throw CommerceError.invalidCustomer }
            next.customers[index] = customer
        } else { next.customers.append(customer) }
        try commit(next)
    }

    public func adjustStock(variantID: UUID, delta: Int, reason: InventoryReason,
                            note: String, in scope: StoreScope) async throws {
        _ = try validate(scope)
        guard reason != .sale, !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CommerceError.invalidReason
        }
        guard delta != 0 else { throw CommerceError.invalidQuantity }
        if reason == .purchase || reason == .customerReturn {
            guard delta > 0 else { throw CommerceError.invalidQuantity }
        }
        if reason == .damaged { guard delta < 0 else { throw CommerceError.invalidQuantity } }
        guard snapshot.products.contains(where: { $0.businessID == scope.businessID &&
            $0.variants.contains(where: { $0.id == variantID }) }) else { throw CommerceError.missingVariant }
        var next = snapshot
        try changeStock(&next, scope: scope, variantID: variantID, delta: delta,
                        reason: reason, note: note, saleID: nil, date: Date())
        try commit(next)
    }

    public func checkout(_ request: CheckoutRequest) async throws -> Sale {
        let business = try validate(request.scope)
        if let sale = snapshot.sales.first(where: { $0.id == request.id }) {
            guard sale.scope == request.scope else { throw CommerceError.invalidScope }
            return sale
        }
        guard !request.items.isEmpty else { throw CommerceError.invalidQuantity }
        if let customerID = request.customerID {
            guard snapshot.customers.contains(where: { $0.id == customerID &&
                $0.businessID == request.scope.businessID }) else { throw CommerceError.invalidCustomer }
        }
        var quantities: [UUID: Int] = [:]
        for item in request.items {
            guard item.quantity > 0 else { throw CommerceError.invalidQuantity }
            let (sum, overflow) = (quantities[item.variantID] ?? 0).addingReportingOverflow(item.quantity)
            guard !overflow else { throw CommerceError.invalidQuantity }
            quantities[item.variantID] = sum
        }
        var lines: [SaleLine] = []
        for variantID in quantities.keys.sorted(by: { $0.uuidString < $1.uuidString }) {
            guard let product = snapshot.products.first(where: { $0.businessID == business.id &&
                $0.status == .active && $0.variants.contains(where: { $0.id == variantID }) }),
                let variant = product.variants.first(where: { $0.id == variantID }),
                let quantity = quantities[variantID] else { throw CommerceError.missingVariant }
            lines.append(SaleLine(id: UUID(), variantID: variantID, productName: product.name,
                variantLabel: variant.options.map { "\($0.name): \($0.value)" }.joined(separator: " · "),
                quantity: quantity, unitPrice: variant.price, unitCost: variant.cost))
        }
        let subtotal = lines.reduce(Decimal.zero) { $0 + $1.subtotal }
        guard request.discount >= 0, request.discount <= subtotal,
              request.discount == Money.rounded(request.discount) else { throw CommerceError.invalidDiscount }
        let tax = Money.rounded((subtotal - request.discount) * business.taxRate)
        let date = Date()
        let sale = Sale(id: request.id, scope: request.scope, currencyCode: business.currencyCode,
            lines: lines, subtotal: subtotal, discount: request.discount, tax: tax,
            total: subtotal - request.discount + tax, customerID: request.customerID,
            sellerID: request.sellerID, paymentMethod: request.paymentMethod, date: date)
        var next = snapshot
        for line in lines {
            try changeStock(&next, scope: request.scope, variantID: line.variantID,
                delta: -line.quantity, reason: .sale, note: "Venta registrada", saleID: sale.id, date: date)
        }
        next.sales.append(sale)
        try commit(next)
        return sale
    }

    private func validate(_ scope: StoreScope) throws -> Business {
        guard let business = snapshot.businesses.first(where: { $0.id == scope.businessID }),
              snapshot.branches.contains(where: { $0.id == scope.branchID && $0.businessID == scope.businessID })
        else { throw CommerceError.invalidScope }
        return business
    }

    private func changeStock(_ next: inout StoreSnapshot, scope: StoreScope, variantID: UUID,
                              delta: Int, reason: InventoryReason, note: String,
                              saleID: UUID?, date: Date) throws {
        let index = next.stock.firstIndex { $0.scope == scope && $0.variantID == variantID }
        let current = index.map { next.stock[$0].quantity } ?? 0
        let (quantity, overflow) = current.addingReportingOverflow(delta)
        guard !overflow, quantity >= 0 else { throw CommerceError.insufficientStock }
        if let index { next.stock[index].quantity = quantity }
        else { next.stock.append(StockLevel(scope: scope, variantID: variantID, quantity: quantity)) }
        next.movements.append(InventoryMovement(id: UUID(), scope: scope, variantID: variantID,
            delta: delta, resultingQuantity: quantity, reason: reason, note: note, saleID: saleID, date: date))
    }

    private func commit(_ next: StoreSnapshot) throws {
        if let fileURL {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                     withIntermediateDirectories: true)
            try JSONEncoder().encode(next).write(to: fileURL, options: .atomic)
        }
        snapshot = next
    }
}
