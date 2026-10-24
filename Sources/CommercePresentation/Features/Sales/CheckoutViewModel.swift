import Foundation
import Combine
import CommerceCore

struct SellableVariant: Identifiable {
    var id: UUID { variant.id }
    let product: Product
    let variant: ProductVariant
    let stock: Int
}

@MainActor
final class CheckoutViewModel: ObservableObject {
    @Published private(set) var data: BusinessData?
    @Published private(set) var quantities: [UUID: Int] = [:]
    @Published var search = ""
    @Published var discountText = "0"
    @Published var customerID: UUID?
    @Published var method = PaymentMethod.cash
    @Published private(set) var processing = false
    @Published private(set) var loading = false
    @Published private(set) var error: String?
    @Published private(set) var receipt: Sale?
    private let repository: any CommerceRepository
    private let scope: StoreScope
    private let sellerID: UUID
    private var requestID = UUID()

    init(repository: any CommerceRepository, scope: StoreScope, sellerID: UUID) {
        self.repository = repository; self.scope = scope; self.sellerID = sellerID
    }
    var catalog: [SellableVariant] {
        (data?.products ?? []).filter { $0.status == .active }.flatMap { product in
            product.variants.map { variant in
                SellableVariant(product: product, variant: variant,
                    stock: data?.stock.first { $0.variantID == variant.id }?.quantity ?? 0)
            }
        }
    }
    var results: [SellableVariant] {
        catalog.filter { search.isEmpty || $0.product.name.localizedStandardContains(search) ||
            $0.variant.sku.localizedStandardContains(search) }
    }
    var cart: [SellableVariant] { catalog.filter { quantities[$0.id, default: 0] > 0 } }
    var subtotal: Decimal { cart.reduce(0) { $0 + $1.variant.price * Decimal(quantities[$1.id, default: 0]) } }
    var discount: Decimal? {
        let normalized = discountText.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard normalized.range(of: "^[0-9]+(?:\\.[0-9]{1,2})?$", options: .regularExpression) != nil else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }
    var tax: Decimal { Money.rounded((subtotal - (discount ?? 0)) * (data?.business.taxRate ?? 0)) }
    var total: Decimal { subtotal - (discount ?? 0) + tax }
    var valid: Bool { !cart.isEmpty && discount.map { $0 >= 0 && $0 <= subtotal } == true && receipt == nil }
    func money(_ value: Decimal) -> String { Money.formatted(value, currencyCode: data?.business.currencyCode ?? "COP") }

    func load() async {
        loading = true; error = nil
        defer { loading = false }
        do { data = try await repository.data(in: scope) }
        catch { self.error = error.localizedDescription }
    }
    func change(_ item: SellableVariant, by delta: Int) {
        guard !processing, receipt == nil else { return }
        let old = quantities[item.id, default: 0]
        let (next, overflow) = old.addingReportingOverflow(delta)
        guard !overflow, next >= 0, next <= item.stock else { return }
        quantities[item.id] = next
        requestID = UUID()
    }
    func confirm() async {
        guard !processing, valid, let discount else { return }
        processing = true; error = nil
        defer { processing = false }
        do {
            receipt = try await repository.checkout(CheckoutRequest(id: requestID, scope: scope,
                items: cart.map { CartItem(variantID: $0.id, quantity: quantities[$0.id, default: 0]) },
                discount: discount, customerID: customerID, sellerID: sellerID, paymentMethod: method))
        } catch { self.error = error.localizedDescription }
    }
}
