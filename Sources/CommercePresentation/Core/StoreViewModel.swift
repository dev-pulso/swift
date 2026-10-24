import Foundation
import Combine
import CommerceCore

@MainActor
final class StoreViewModel: ObservableObject {
    @Published private(set) var data: BusinessData?
    @Published private(set) var error: String?
    @Published private(set) var loading = false
    let repository: any CommerceRepository
    let scope: StoreScope
    let isDemo: Bool
    var dashboard: DashboardSummary? { data.map { DashboardCalculator.calculate($0) } }
    var bestSellers: [BestSeller] { SalesInsights.bestSellers(sales: data?.sales ?? []) }

    init(repository: any CommerceRepository, scope: StoreScope, isDemo: Bool) {
        self.repository = repository; self.scope = scope; self.isDemo = isDemo
    }

    func reload() async {
        guard !loading else { return }
        loading = true; error = nil
        defer { loading = false }
        do { data = try await repository.data(in: scope) }
        catch { self.error = error.localizedDescription }
    }

    func stock(_ variantID: UUID) -> Int {
        data?.stock.first { $0.variantID == variantID }?.quantity ?? 0
    }

    func money(_ value: Decimal) -> String {
        Money.formatted(value, currencyCode: data?.business.currencyCode ?? "COP")
    }

    func productLabel(for variantID: UUID) -> String {
        for product in data?.products ?? [] {
            if let variant = product.variants.first(where: { $0.id == variantID }) {
                return "\(product.name) · \(variant.sku)"
            }
        }
        return "Variante \(variantID.uuidString.prefix(8))"
    }
}
