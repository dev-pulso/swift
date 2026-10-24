import Foundation
import Combine
import CommerceCore

@MainActor
public final class ProductsViewModel: ObservableObject {
    @Published public private(set) var state: LoadState<[Product]> = .idle
    @Published public var searchText = ""
    @Published public private(set) var saveError: String?
    @Published public private(set) var isSaving = false
    private let repository: any CommerceRepository
    private let scope: StoreScope
    private var products: [Product] = []
    private var isLoading = false

    public var filteredProducts: [Product] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return products.filter { product in
            product.status != .archived && (query.isEmpty ||
                product.name.localizedStandardContains(query) ||
                product.variants.contains { $0.sku.localizedStandardContains(query) })
        }
    }

    public init(repository: any CommerceRepository, scope: StoreScope) {
        self.repository = repository; self.scope = scope
    }

    public func load() async {
        guard !isLoading else { return }
        isLoading = true; state = .loading
        defer { isLoading = false }
        do {
            let data = try await repository.data(in: scope)
            try Task.checkCancellation()
            products = data.products.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
            state = products.filter { $0.status != .archived }.isEmpty ? .empty : .success(products)
        } catch is CancellationError { state = .idle }
        catch { state = .failure(error.localizedDescription) }
    }

    /// True only after durable repository save. The form decides whether to dismiss.
    public func save(_ product: Product) async -> Bool {
        guard !isSaving else { return false }
        isSaving = true; saveError = nil
        defer { isSaving = false }
        do {
            try await repository.saveProduct(product, in: scope)
            await load()
            return true
        } catch { saveError = error.localizedDescription; return false }
    }
}
