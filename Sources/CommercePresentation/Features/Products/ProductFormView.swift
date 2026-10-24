#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct ProductFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: StoreViewModel
    @StateObject private var model: ProductEditorViewModel
    init(store: StoreViewModel, product: Product? = nil) {
        self.store = store
        _model = StateObject(wrappedValue: ProductEditorViewModel(repository: store.repository,
                                                                 scope: store.scope, product: product))
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    LuxuryLabel(text: "INFORMACIÓN DEL PRODUCTO")
                    LuxuryTextField(title: "Nombre", text: $model.name)
                    LuxuryTextField(title: "Descripción", text: $model.description)
                    LuxuryTextField(title: "Categoría", text: $model.category)
                    LuxuryTextField(title: "Marca", text: $model.brand)
                    Picker("Estado", selection: $model.status) {
                        Text("Activo").tag(ProductStatus.active)
                        Text("Inactivo").tag(ProductStatus.inactive)
                        Text("Archivado").tag(ProductStatus.archived)
                    }
                    LuxurySectionHeader(title: "Variantes")
                    Text("Precios sin separadores de miles. Opciones: Color=Negro; Talla=M. Deja las opciones vacías para una variante única.")
                        .font(.footnote).foregroundStyle(LuxuryTheme.muted)
                    ForEach($model.variants) { $draft in
                        LuxuryCard {
                            VStack(spacing: 16) {
                                LuxuryTextField(title: "SKU", text: $draft.sku).textInputAutocapitalization(.characters)
                                LuxuryTextField(title: "Opciones", text: $draft.options)
                                LuxuryTextField(title: "Precio", text: $draft.price).keyboardType(.decimalPad)
                                LuxuryTextField(title: "Costo", text: $draft.cost).keyboardType(.decimalPad)
                                LuxuryTextField(title: "Stock mínimo", text: $draft.minimum).keyboardType(.numberPad)
                            }
                        }
                    }
                    LuxuryButton(title: "Agregar variante", secondary: true) { model.variants.append(VariantDraft()) }
                    Text("Las existencias se registran desde Inventario, con su motivo e historial.")
                        .font(.footnote).foregroundStyle(LuxuryTheme.muted)
                    if let error = model.error { LuxuryError(message: error) }
                    LuxuryButton(title: "Guardar producto", loading: model.saving) {
                        Task { if await model.save() { await store.reload(); dismiss() } }
                    }
                }.padding(20)
            }.luxuryCanvas().navigationTitle("Producto").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
                .interactiveDismissDisabled(model.saving)
        }
    }
}

#endif
