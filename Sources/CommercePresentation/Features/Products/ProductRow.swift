#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct ProductRow: View {
    let product: Product
    let currency: String
    var body: some View {
        LuxuryCard {
            HStack(alignment: .top, spacing: 16) {
                ProductImage(url: product.imageURLs.first).frame(width: 64, height: 80).clipped()
                VStack(alignment: .leading, spacing: 8) {
                    LuxuryLabel(text: product.category.isEmpty ? "Producto" : product.category)
                    Text(product.name).font(.headline)
                    if let price = product.variants.map(\.price).min() {
                        Text(Money.formatted(price, currencyCode: currency)).font(.callout).monospacedDigit()
                    }
                    Text("\(product.variants.count) variante(s)").font(.caption).foregroundStyle(LuxuryTheme.muted)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

@MainActor
struct ProductImage: View {
    let url: URL?
    var body: some View {
        AsyncImage(url: url) { phase in
            if let image = phase.image { image.resizable().scaledToFit() }
            else {
                ZStack {
                    LuxuryTheme.canvas
                    Image(systemName: "shippingbox").font(.largeTitle.weight(.ultraLight))
                        .foregroundStyle(LuxuryTheme.muted)
                }
            }
        }.accessibilityHidden(true)
    }
}

#endif
