#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct ProductDetailView: View {
    let product: Product
    @ObservedObject var store: StoreViewModel
    @State private var editing = false
    private var current: Product { store.data?.products.first { $0.id == product.id } ?? product }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ProductImage(url: current.imageURLs.first).frame(height: 240)
                LuxuryLabel(text: current.category)
                Text(current.name).font(.largeTitle.weight(.semibold))
                if !current.description.isEmpty { Text(current.description).foregroundStyle(LuxuryTheme.muted) }
                LuxuryBadge(text: current.status == .active ? "Activo" : current.status == .archived ? "Archivado" : "Inactivo")
                LuxurySectionHeader(title: "Variantes")
                ForEach(current.variants) { variant in
                    LuxuryCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(variant.title).font(.headline)
                            LuxuryLabel(text: variant.sku)
                            LabeledContent("Precio", value: store.money(variant.price))
                            LabeledContent("Costo", value: store.money(variant.cost))
                            LabeledContent("Disponible", value: "\(store.stock(variant.id)) unidades")
                            if let margin = variant.marginPercentage {
                                LabeledContent("Margen bruto", value: "\(Money.rounded(margin))%")
                            }
                        }
                    }
                }
                NavigationLink(value: InventoryDestination.inventory) { Text("Administrar inventario →") }
            }.padding(20)
        }.luxuryCanvas().navigationTitle("Producto").navigationBarTitleDisplayMode(.inline)
            .toolbar { Button("Editar") { editing = true } }
            .sheet(isPresented: $editing) { ProductFormView(store: store, product: current) }
    }
}

#endif
