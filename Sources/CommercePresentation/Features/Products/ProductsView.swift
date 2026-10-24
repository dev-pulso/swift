#if os(iOS)
import SwiftUI

@MainActor
struct ProductsView: View {
    @ObservedObject var store: StoreViewModel
    @StateObject private var model: ProductsViewModel
    @State private var adding = false
    init(store: StoreViewModel) {
        self.store = store
        _model = StateObject(wrappedValue: ProductsViewModel(repository: store.repository, scope: store.scope))
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LuxuryLabel(text: "EL CATÁLOGO DE TU NEGOCIO")
                LuxurySearchBar(text: $model.searchText)
                switch model.state {
                case .idle, .loading: ProgressView("Cargando catálogo…")
                case .failure(let message):
                    LuxuryError(message: message)
                    LuxuryButton(title: "Reintentar") { Task { await model.load() } }
                case .empty:
                    LuxuryEmptyState(title: "Agrega tu primer producto", message: "Empieza con un nombre, precio y SKU. Las variantes se adaptan a lo que vendes.")
                    LuxuryButton(title: "Crear producto") { adding = true }
                case .success:
                    if model.filteredProducts.isEmpty {
                        LuxuryEmptyState(title: "Sin resultados", message: "Prueba otro nombre o SKU.", symbol: "magnifyingglass")
                    }
                    LazyVStack(spacing: 12) {
                        ForEach(model.filteredProducts) { product in
                            NavigationLink(value: product) {
                                ProductRow(product: product, currency: store.data?.business.currencyCode ?? "COP")
                            }.buttonStyle(.plain)
                        }
                    }
                }
            }.padding(LuxuryTheme.gutter)
        }.luxuryCanvas().navigationTitle("Productos")
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product, store: store)
            }
            .navigationDestination(for: InventoryDestination.self) { _ in
                InventoryView(store: store)
            }
            .toolbar { ToolbarItem(placement: .primaryAction) {
                Button { adding = true } label: { Image(systemName: "plus").frame(minWidth: 44, minHeight: 44) }
                    .accessibilityLabel("Crear producto")
            } }
            .sheet(isPresented: $adding, onDismiss: { Task { await model.load() } }) {
                ProductFormView(store: store)
            }
            .task { await model.load() }
            .onReceive(store.$data) { _ in Task { await model.load() } }
            .refreshable { await model.load() }
    }
}

#endif
