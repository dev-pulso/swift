import Foundation
import Combine
import CommerceCore

@MainActor
final class InventoryAdjustmentViewModel: ObservableObject {
    @Published var delta = ""
    @Published var note = ""
    @Published var reason = InventoryReason.purchase
    @Published private(set) var saving = false
    @Published private(set) var error: String?
    private let repository: any CommerceRepository
    private let scope: StoreScope
    private let variantID: UUID
    init(repository: any CommerceRepository, scope: StoreScope, variantID: UUID) {
        self.repository = repository; self.scope = scope; self.variantID = variantID
    }
    func save() async -> Bool {
        guard !saving else { return false }
        guard let delta = Int(delta), delta != 0 else { error = "Ingresa una cantidad entera distinta de cero."; return false }
        saving = true; error = nil
        defer { saving = false }
        do {
            try await repository.adjustStock(variantID: variantID, delta: delta, reason: reason, note: note, in: scope)
            return true
        } catch { self.error = error.localizedDescription; return false }
    }
}
