#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct SalesView: View {
    @ObservedObject var store: StoreViewModel
    @State private var checkout = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LuxuryButton(title: "Registrar venta") { checkout = true }
                if let error = store.error {
                    LuxuryError(message: error)
                    LuxuryButton(title: "Reintentar") { Task { await store.reload() } }
                } else if store.loading && store.data == nil { ProgressView() }
                LuxurySectionHeader(title: "Historial de ventas")
                if store.data?.sales.isEmpty == true {
                    LuxuryEmptyState(title: "Tu primera venta está por llegar", message: "Agrega productos y existencias antes de registrar una venta.", symbol: "creditcard")
                }
                ForEach(store.data?.sales ?? []) { sale in
                    NavigationLink(value: sale) {
                        SaleRow(sale: sale)
                    }.buttonStyle(.plain)
                }
            }.padding(20)
        }.luxuryCanvas().navigationTitle("Ventas")
            .navigationDestination(for: Sale.self) { sale in
                SaleDetailView(sale: sale)
            }
            .sheet(isPresented: $checkout, onDismiss: { Task { await store.reload() } }) { CheckoutView(store: store) }
            .refreshable { await store.reload() }
    }
}

@MainActor
struct SaleRow: View {
    let sale: Sale
    var body: some View {
        LuxuryCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(Money.formatted(sale.total, currencyCode: sale.currencyCode)).font(.title3.weight(.semibold)).monospacedDigit()
                Text(sale.date.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(LuxuryTheme.muted)
                LuxuryBadge(text: sale.paymentMethod.title)
            }
        }
    }
}

@MainActor
struct SaleDetailView: View {
    let sale: Sale
    private func money(_ value: Decimal) -> String { Money.formatted(value, currencyCode: sale.currencyCode) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LuxuryLabel(text: "VENTA REGISTRADA")
                Text(money(sale.total)).font(.largeTitle.weight(.semibold)).monospacedDigit()
                Text(sale.date.formatted(date: .long, time: .shortened)).foregroundStyle(LuxuryTheme.muted)
                Text("Referencia: \(sale.id.uuidString)").font(.caption).textSelection(.enabled)
                ForEach(sale.lines) { line in
                    LuxuryCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(line.productName).font(.headline)
                            Text(line.variantLabel).font(.caption)
                            Text("\(line.quantity) × \(money(line.unitPrice))")
                        }
                    }
                }
                LuxuryCard {
                    VStack(spacing: 12) {
                        LabeledContent("Subtotal", value: money(sale.subtotal))
                        LabeledContent("Descuento", value: money(sale.discount))
                        LabeledContent("Impuesto", value: money(sale.tax))
                        Divider()
                        LabeledContent("Total", value: money(sale.total)).font(.headline)
                        LabeledContent("Medio de pago", value: sale.paymentMethod.title)
                    }
                }
                Text("Registro interno. No constituye factura electrónica ni confirmación de un pago procesado.")
                    .font(.footnote).foregroundStyle(LuxuryTheme.muted)
            }.padding(20)
        }.luxuryCanvas().navigationTitle("Detalle de venta").navigationBarTitleDisplayMode(.inline)
    }
}

#endif
