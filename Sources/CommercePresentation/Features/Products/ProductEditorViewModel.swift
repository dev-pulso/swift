import Foundation
import Combine
import CommerceCore

struct VariantDraft: Identifiable {
    let id: UUID
    var sku: String
    var price: String
    var cost: String
    var minimum: String
    var options: String
    init(variant: ProductVariant? = nil) {
        id = variant?.id ?? UUID(); sku = variant?.sku ?? ""
        price = variant.map { "\($0.price)" } ?? ""; cost = variant.map { "\($0.cost)" } ?? ""
        minimum = variant.map { "\($0.minimumStock)" } ?? "3"
        options = variant?.options.map { "\($0.name)=\($0.value)" }.joined(separator: "; ") ?? ""
    }
}

@MainActor
final class ProductEditorViewModel: ObservableObject {
    @Published var name: String
    @Published var description: String
    @Published var category: String
    @Published var brand: String
    @Published var status: ProductStatus
    @Published var variants: [VariantDraft]
    @Published private(set) var saving = false
    @Published private(set) var error: String?
    private let original: Product?
    private let repository: any CommerceRepository
    private let scope: StoreScope

    init(repository: any CommerceRepository, scope: StoreScope, product: Product? = nil) {
        self.repository = repository; self.scope = scope; original = product
        name = product?.name ?? ""; description = product?.description ?? ""
        category = product?.category ?? ""; brand = product?.brand ?? ""; status = product?.status ?? .active
        variants = product?.variants.map { VariantDraft(variant: $0) } ?? [VariantDraft()]
    }

    func save() async -> Bool {
        guard !saving else { return false }
        saving = true; error = nil
        defer { saving = false }
        do {
            let mapped = try variants.map { draft -> ProductVariant in
                guard let price = decimal(draft.price), let cost = decimal(draft.cost),
                      let minimum = Int(draft.minimum), minimum >= 0 else { throw CommerceError.invalidProduct }
                var options: [VariantOption] = []
                if !draft.options.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    for pair in draft.options.split(separator: ";", omittingEmptySubsequences: false) {
                        let parts = pair.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
                        guard parts.count == 2 else { throw CommerceError.invalidProduct }
                        let key = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        let value = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !key.isEmpty, !value.isEmpty,
                              !options.contains(where: { $0.name.lowercased() == key.lowercased() }) else {
                            throw CommerceError.invalidProduct
                        }
                        options.append(VariantOption(name: key, value: value))
                    }
                }
                let previous = original?.variants.first { $0.id == draft.id }
                return ProductVariant(id: draft.id, sku: draft.sku.trimmingCharacters(in: .whitespacesAndNewlines),
                    barcode: previous?.barcode, options: options, price: price, cost: cost,
                    imageURL: previous?.imageURL, minimumStock: minimum)
            }
            let product = Product(id: original?.id ?? UUID(), businessID: scope.businessID,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines), description: description,
                category: category, brand: brand, tags: original?.tags ?? [], imageURLs: original?.imageURLs ?? [],
                supplierID: original?.supplierID, status: status, variants: mapped)
            try await repository.saveProduct(product, in: scope)
            return true
        } catch { self.error = error.localizedDescription; return false }
    }

    private func decimal(_ text: String) -> Decimal? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
        guard normalized.range(of: "^[0-9]+(?:\\.[0-9]{1,2})?$", options: .regularExpression) != nil else { return nil }
        return Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX"))
    }
}
