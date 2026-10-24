import Foundation

public struct DailyRevenue: Identifiable, Sendable {
    public var id: Date { date }
    public let date: Date
    public let total: Decimal
}

public struct DashboardSummary: Sendable {
    public let today: Decimal
    public let week: Decimal
    public let month: Decimal
    public let todayOrderCount: Int
    public let averageTicket: Decimal
    public let grossProfit: Decimal
    public let lowStockVariants: Int
    public let outOfStockVariants: Int
    public let newCustomers: Int
    public let lastSevenDays: [DailyRevenue]
}

public enum DashboardCalculator {
    /// Calendar and clock are injected: never compare date strings or assume every day has 24 hours.
    public static func calculate(_ data: BusinessData, now: Date = Date(),
                                 calendar: Calendar = .current) -> DashboardSummary {
        func sales(in component: Calendar.Component) -> [Sale] {
            guard let interval = calendar.dateInterval(of: component, for: now) else { return [] }
            return data.sales.filter { $0.date >= interval.start && $0.date < interval.end && $0.date <= now }
        }
        func total(_ sales: [Sale]) -> Decimal { sales.reduce(0) { $0 + $1.total } }
        let today = sales(in: .day)
        let week = sales(in: .weekOfYear)
        let month = sales(in: .month)
        let activeVariants = data.products.filter { $0.status == .active }.flatMap(\.variants)
        func stock(for variant: ProductVariant) -> Int {
            data.stock.first { $0.variantID == variant.id }?.quantity ?? 0
        }
        let start = calendar.startOfDay(for: now)
        let series = (-6...0).compactMap { offset -> DailyRevenue? in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start),
                  let end = calendar.date(byAdding: .day, value: 1, to: day) else { return nil }
            return DailyRevenue(date: day, total: total(data.sales.filter {
                $0.date >= day && $0.date < end && $0.date <= now
            }))
        }
        let monthStart = calendar.dateInterval(of: .month, for: now)?.start ?? start
        return DashboardSummary(today: total(today), week: total(week), month: total(month),
            todayOrderCount: today.count,
            averageTicket: today.isEmpty ? 0 : Money.rounded(total(today) / Decimal(today.count)),
            grossProfit: today.reduce(0) { $0 + $1.estimatedGrossProfit },
            lowStockVariants: activeVariants.filter { stock(for: $0) > 0 && stock(for: $0) <= $0.minimumStock }.count,
            outOfStockVariants: activeVariants.filter { stock(for: $0) == 0 }.count,
            newCustomers: data.customers.filter { $0.createdAt >= monthStart && $0.createdAt <= now }.count,
            lastSevenDays: series)
    }
}
