#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct InventoryView: View {
    @ObservedObject var store: StoreViewModel
    @State private var selected: ProductVariant?
    @State private var lowOnly = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Toggle("Solo stock bajo y agotados", isOn: $lowOnly)
                if let error = store.error {
                    LuxuryError(message: error)
                    LuxuryButton(title: "Reintentar") { Task { await store.reload() } }
                } else if store.loading && store.data == nil { ProgressView() }
                if store.data?.products.isEmpty == true {
                    LuxuryEmptyState(title: "Tu inventario está listo para comenzar", message: "Crea un producto en Productos y registra aquí sus primeras unidades.")
                }
                ForEach((store.data?.products ?? []).filter { $0.status != .archived }) { product in
                    ForEach(product.variants.filter { !lowOnly || store.stock($0.id) <= $0.minimumStock }) { variant in
                        Button { selected = variant } label: {
                            LuxuryCard {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(product.name).font(.headline)
                                    Text(variant.title).font(.caption)
                                    LuxuryLabel(text: variant.sku)
                                    HStack {
                                        Text("\(store.stock(variant.id)) unidades").font(.title3.weight(.semibold))
                                        Spacer()
                                        if store.stock(variant.id) <= variant.minimumStock {
                                            LuxuryBadge(text: store.stock(variant.id) == 0 ? "Agotado" : "Stock bajo")
                                        }
                                    }
                                    Text("Ajustar existencias →").font(.callout)
                                }
                            }
                        }.buttonStyle(.plain)
                    }
                }
                LuxurySectionHeader(title: "Últimos movimientos")
                ForEach(Array((store.data?.movements ?? []).prefix(30))) { movement in
                    LuxuryCard {
                        VStack(alignment: .leading, spacing: 8) {
                            LuxuryLabel(text: store.productLabel(for: movement.variantID))
                            Text(movement.note).font(.headline)
                            Text("\(movement.delta > 0 ? "+" : "")\(movement.delta) unidades · Saldo: \(movement.resultingQuantity)")
                            Text(movement.date.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption).foregroundStyle(LuxuryTheme.muted)
                        }
                    }
                }
            }.padding(20)
        }.luxuryCanvas().navigationTitle("Inventario")
            .refreshable { await store.reload() }
            .sheet(item: $selected) { variant in InventoryAdjustmentView(store: store, variant: variant) }
    }
}

@MainActor
private struct InventoryAdjustmentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: StoreViewModel
    let variant: ProductVariant
    @StateObject private var model: InventoryAdjustmentViewModel
    init(store: StoreViewModel, variant: ProductVariant) {
        self.store = store; self.variant = variant
        _model = StateObject(wrappedValue: InventoryAdjustmentViewModel(repository: store.repository,
            scope: store.scope, variantID: variant.id))
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    LuxuryLabel(text: variant.sku)
                    Text("Disponible: \(store.stock(variant.id)) unidades").font(.title2)
                    LuxuryTextField(title: "Variación de unidades", text: $model.delta)
                    Text("Ejemplo: 10 para ingresar unidades, -2 para retirar. No ingreses el saldo final.")
                        .font(.footnote).foregroundStyle(LuxuryTheme.muted)
                    Picker("Motivo", selection: $model.reason) {
                        Text("Compra").tag(InventoryReason.purchase)
                        Text("Ajuste").tag(InventoryReason.adjustment)
                        Text("Devolución").tag(InventoryReason.customerReturn)
                        Text("Producto dañado").tag(InventoryReason.damaged)
                        Text("Corrección manual").tag(InventoryReason.correction)
                    }
                    LuxuryTextField(title: "Nota obligatoria", text: $model.note)
                    if let error = model.error { LuxuryError(message: error) }
                    LuxuryButton(title: "Guardar movimiento", loading: model.saving) {
                        Task { if await model.save() { await store.reload(); dismiss() } }
                    }
                }.padding(20)
            }.luxuryCanvas().navigationTitle("Ajustar inventario").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
                .interactiveDismissDisabled(model.saving)
        }
    }
}

#endif
