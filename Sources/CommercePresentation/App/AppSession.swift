import Foundation
import Combine
import CommerceCore

@MainActor
final class AppSession: ObservableObject {
    @Published private(set) var store: StoreViewModel?
    @Published private(set) var loading = false
    @Published private(set) var error: String?
    private var local: (any CommerceRepository)?

    func start() async {
        guard local == nil, !loading else { return }
        loading = true; error = nil
        defer { loading = false }
        do {
            let dependencies = try AppDependencies.local()
            let businesses = try await dependencies.repository.businesses()
            if let business = businesses.first,
               let scope = try await dependencies.repository.scopes(businessID: business.id).first {
                store = StoreViewModel(repository: dependencies.repository, scope: scope, isDemo: false)
            }
            local = dependencies.repository
        } catch { self.error = error.localizedDescription }
    }

    func demo() async {
        guard !loading else { return }
        loading = true; error = nil
        defer { loading = false }
        do {
            let repository = try AppDependencies.preview().repository
            guard let business = try await repository.businesses().first,
                  let scope = try await repository.scopes(businessID: business.id).first else {
                throw CommerceError.invalidScope
            }
            store = StoreViewModel(repository: repository, scope: scope, isDemo: true)
        } catch { self.error = error.localizedDescription }
    }

    func create(_ business: Business) async {
        guard !loading else { return }
        loading = true; error = nil
        defer { loading = false }
        do {
            guard let local else { throw CommerceError.invalidScope }
            let scope = try await local.createBusiness(business)
            store = StoreViewModel(repository: local, scope: scope, isDemo: false)
        } catch { self.error = error.localizedDescription }
    }

    func leaveDemo() { store = nil }
}
