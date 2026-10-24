import Foundation

public enum DemoData {
    /// Dates are relative to a supplied clock so previews remain useful over time.
    public static func make(now: Date = Date(), calendar: Calendar = .current) -> StoreSnapshot {
        let business = Business(name: "Luxury Perfumes", kind: .fragrance, city: "Bogotá")
        let branch = Branch(businessID: business.id, name: "Principal")
        let scope = StoreScope(businessID: business.id, branchID: branch.id)
        let products = [
            Product(businessID: business.id, name: "Coco Mademoiselle", category: "Perfumes", brand: "Chanel",
                variants: [ProductVariant(sku: "CHA-CM-50", options: [.init(name: "Contenido", value: "50 ml")],
                    price: 580000, cost: 390000, minimumStock: 5),
                    ProductVariant(sku: "CHA-CM-100", options: [.init(name: "Contenido", value: "100 ml")],
                    price: 790000, cost: 530000)]),
            Product(businessID: business.id, name: "Sauvage", category: "Perfumes", brand: "Dior",
                variants: [ProductVariant(sku: "DIO-SAU-100", options: [.init(name: "Contenido", value: "100 ml")],
                    price: 650000, cost: 420000)]),
            Product(businessID: business.id, name: "Kit de viaje", category: "Accesorios",
                variants: [ProductVariant(sku: "ACC-KIT", price: 45000, cost: 18000)]),
            Product(businessID: business.id, name: "Atomizador recargable", category: "Accesorios",
                variants: [ProductVariant(sku: "ACC-ATO-NEG", options: [.init(name: "Color", value: "Negro")],
                    price: 25000, cost: 9000)])
        ]
        let customers = ["María Gómez", "Laura Torres", "Carlos Rodríguez"].enumerated().map { index, name in
            Customer(businessID: business.id, name: name,
                contact: Contact(email: "cliente\(index + 1)@example.com"),
                tags: index == 0 ? ["VIP"] : [],
                createdAt: calendar.date(byAdding: .day, value: -index * 35, to: now) ?? now)
        }
        let variants = products.flatMap(\.variants)
        let quantities = [3, 8, 12, 24, 0]
        let stock = zip(variants, quantities).map { StockLevel(scope: scope, variantID: $0.0.id, quantity: $0.1) }
        let sellerID = UUID()
        var sales: [Sale] = []
        var movements: [InventoryMovement] = []
        for day in 0..<14 {
            let product = products[day % 3]
            guard let variant = product.variants.first,
                  let date = calendar.date(byAdding: .day, value: -day, to: now) else { continue }
            let quantity = day % 3 + 1
            let line = SaleLine(id: UUID(), variantID: variant.id, productName: product.name,
                variantLabel: variant.options.map(\.value).joined(separator: " · "), quantity: quantity,
                unitPrice: variant.price, unitCost: variant.cost)
            let sale = Sale(id: UUID(), scope: scope, currencyCode: business.currencyCode,
                lines: [line], subtotal: line.subtotal, discount: 0, tax: 0, total: line.subtotal,
                customerID: customers[day % customers.count].id, sellerID: sellerID,
                paymentMethod: day.isMultiple(of: 2) ? .cash : .nequi, date: date)
            sales.append(sale)
        }
        // Opening stock + historical sales reconcile to the current quantities.
        for level in stock {
            let historicalSales = sales.sorted { $0.date < $1.date }
            let sold = historicalSales.flatMap(\.lines).filter { $0.variantID == level.variantID }
                .reduce(0) { $0 + $1.quantity }
            var balance = level.quantity + sold
            let openingDate = calendar.date(byAdding: .day, value: -15, to: now) ?? now
            movements.append(InventoryMovement(id: UUID(), scope: scope, variantID: level.variantID,
                delta: balance, resultingQuantity: balance, reason: .purchase,
                note: "Carga inicial de demostración", saleID: nil, date: openingDate))
            for sale in historicalSales {
                for line in sale.lines where line.variantID == level.variantID {
                    balance -= line.quantity
                    movements.append(InventoryMovement(id: UUID(), scope: scope, variantID: level.variantID,
                        delta: -line.quantity, resultingQuantity: balance, reason: .sale,
                        note: "Venta de demostración", saleID: sale.id, date: sale.date))
                }
            }
        }
        return StoreSnapshot(businesses: [business], branches: [branch], products: products,
                             stock: stock, customers: customers, sales: sales, movements: movements)
    }
}
