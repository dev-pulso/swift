import Foundation

public enum Money {
    /// MVP supports COP and USD with two fractional accounting digits.
    /// Add ISO 4217 currency-specific precision before enabling other currencies.
    public static let supportedCurrencies = ["COP", "USD"]
    public static func rounded(_ value: Decimal) -> Decimal {
        var source = value
        var result = Decimal()
        NSDecimalRound(&result, &source, 2, .plain)
        return result
    }

    public static func formatted(_ value: Decimal, currencyCode: String,
                                 locale: Locale = Locale(identifier: "es_CO")) -> String {
        value.formatted(.currency(code: currencyCode).locale(locale))
    }
}
