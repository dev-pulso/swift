import Foundation
import Combine
import CommerceCore

@MainActor
final class CustomerEditorViewModel: ObservableObject {
    @Published var name = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var address = ""
    @Published var notes = ""
    @Published private(set) var saving = false
    @Published private(set) var error: String?
    private let repository: any CommerceRepository
    private let scope: StoreScope
    init(repository: any CommerceRepository, scope: StoreScope) {
        self.repository = repository; self.scope = scope
    }
    func save() async -> Bool {
        guard !saving else { return false }
        saving = true; error = nil
        defer { saving = false }
        do {
            try await repository.saveCustomer(Customer(businessID: scope.businessID,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                contact: Contact(phone: phone, email: email, address: address), notes: notes), in: scope)
            return true
        } catch { self.error = error.localizedDescription; return false }
    }
}
