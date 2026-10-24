#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model: CheckoutViewModel
    @ObservedObject var store: StoreViewModel
    init(store: StoreViewModel) {
        self.store = store
        _model = StateObject(wrappedValue: CheckoutViewModel(repository: store.repository, scope: store.scope,
            sellerID: LocalOperator.id))
    }
    var body: some View {
        NavigationStack {
            Group {
                if let receipt = model.receipt {
                    VStack {
                        SaleDetailView(sale: receipt)
                        LuxuryButton(title: "Listo") { dismiss() }.padding(20)
                    }
                } else { checkoutForm }
            }
            .luxuryCanvas().navigationTitle("Nueva venta").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .cancellationAction) {
                Button("Cerrar") { dismiss() }.disabled(model.processing)
            } }
            .interactiveDismissDisabled(model.processing)
            .task { await model.load() }
        }
    }

    private var checkoutForm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LuxurySearchBar(text: $model.search)
                if model.loading { ProgressView("Cargando productos…") }
                if let error = model.error {
                    LuxuryError(message: error)
                    if model.data == nil { LuxuryButton(title: "Reintentar") { Task { await model.load() } } }
                }
                if model.results.isEmpty && !model.loading {
                    LuxuryEmptyState(title: "No hay productos disponibles", message: "Revisa la búsqueda o agrega productos activos a tu catálogo.")
                }
                ForEach(model.results) { item in
                    LuxuryCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(item.product.name).font(.headline)
                            Text(item.variant.title).font(.caption).foregroundStyle(LuxuryTheme.muted)
                            Text(model.money(item.variant.price)).monospacedDigit()
                            HStack {
                                Text("Stock: \(item.stock)").font(.caption)
                                Spacer()
                                Button { model.change(item, by: -1) } label: {
                                    Image(systemName: "minus").frame(width: 44, height: 44)
                                }.disabled(model.quantities[item.id, default: 0] == 0)
                                    .accessibilityLabel("Quitar una unidad de \(item.product.name), \(item.variant.title)")
                                Text("\(model.quantities[item.id, default: 0])").monospacedDigit()
                                Button { model.change(item, by: 1) } label: {
                                    Image(systemName: "plus").frame(width: 44, height: 44)
                                }.disabled(model.quantities[item.id, default: 0] >= item.stock)
                                    .accessibilityLabel("Agregar una unidad de \(item.product.name), \(item.variant.title)")
                            }
                        }
                    }
                }
                LuxurySectionHeader(title: "Tu carrito")
                if model.cart.isEmpty { Text("Selecciona las cantidades de los productos.").foregroundStyle(LuxuryTheme.muted) }
                ForEach(model.cart) { item in
                    Text("\(model.quantities[item.id, default: 0]) × \(item.product.name) · \(item.variant.title)")
                }
                Picker("Cliente", selection: $model.customerID) {
                    Text("Venta sin cliente").tag(Optional<UUID>.none)
                    ForEach(model.data?.customers ?? []) { Text($0.name).tag(Optional($0.id)) }
                }
                LuxuryTextField(title: "Descuento fijo, sin separadores de miles", text: $model.discountText).keyboardType(.decimalPad)
                if model.discount == nil || (model.discount ?? 0) > model.subtotal {
                    LuxuryError(message: "El descuento debe ser un importe entre cero y el subtotal.")
                }
                Picker("Medio de pago", selection: $model.method) {
                    ForEach(PaymentMethod.allCases, id: \.self) { Text($0.title).tag($0) }
                }
                LuxuryCard {
                    VStack(spacing: 12) {
                        LabeledContent("Subtotal", value: model.money(model.subtotal))
                        LabeledContent("Impuesto", value: model.money(model.tax))
                        LabeledContent("Total", value: model.money(model.total)).font(.title3.weight(.semibold))
                    }
                }
                Text("Confirma que recibiste el pago antes de registrar la venta.").font(.footnote).foregroundStyle(LuxuryTheme.muted)
                LuxuryButton(title: "Registrar pago y venta", loading: model.processing) {
                    Task { await model.confirm(); if model.receipt != nil { await store.reload() } }
                }.disabled(!model.valid)
            }.padding(20).disabled(model.processing)
        }
    }
}

#endif
