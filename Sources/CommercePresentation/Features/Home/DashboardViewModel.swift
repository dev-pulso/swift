import Foundation
import Combine
import CommerceCore

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public private(set) var state: LoadState<DashboardSummary> = .idle
    private let repository: any CommerceRepository
    private let scope: StoreScope
    private let calendar: Calendar
    private var isLoading = false

    public init(repository: any CommerceRepository, scope: StoreScope, calendar: Calendar = .current) {
        self.repository = repository; self.scope = scope; self.calendar = calendar
    }

    public func load(now: Date = Date()) async {
        guard !isLoading else { return }
        isLoading = true
        state = .loading
        defer { isLoading = false }
        do {
            let data = try await repository.data(in: scope)
            try Task.checkCancellation()
            // A new business has meaningful zero metrics and an onboarding empty state.
            state = data.products.isEmpty && data.sales.isEmpty ? .empty :
                .success(DashboardCalculator.calculate(data, now: now, calendar: calendar))
        } catch is CancellationError { state = .idle }
        catch { state = .failure(error.localizedDescription) }
    }
}
