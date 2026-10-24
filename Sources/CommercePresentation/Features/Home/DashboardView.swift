#if os(iOS)
import SwiftUI
import Charts
import CommerceCore

@MainActor
struct DashboardView: View {
    @ObservedObject var store: StoreViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LuxuryTheme.sectionGap) {
                VStack(alignment: .leading, spacing: 8) {
                    LuxuryLabel(text: "TU NEGOCIO, DE UN VISTAZO")
                    Text(store.data?.business.name ?? "Bienvenido").font(.largeTitle.weight(.semibold))
                }
                if let error = store.error {
                    LuxuryError(message: error)
                    LuxuryButton(title: "Reintentar") { Task { await store.reload() } }
                } else if store.loading && store.data == nil { ProgressView("Cargando resumen…") }
                if let summary = store.dashboard {
                    revenue(summary)
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        LuxuryMetricCard(title: "Pedidos hoy", value: "\(summary.todayOrderCount)")
                        LuxuryMetricCard(title: "Ticket promedio", value: store.money(summary.averageTicket))
                        LuxuryMetricCard(title: "Margen bruto hoy", value: store.money(summary.grossProfit))
                        LuxuryMetricCard(title: "Clientes nuevos / mes", value: "\(summary.newCustomers)")
                    }
                    LuxuryCard {
                        VStack(alignment: .leading, spacing: 24) {
                            LuxuryLabel(text: "VENTAS / ÚLTIMOS 7 DÍAS")
                            Chart(summary.lastSevenDays) { day in
                                BarMark(x: .value("Día", day.date, unit: .day),
                                        y: .value("Ventas", NSDecimalNumber(decimal: day.total).doubleValue))
                                    .foregroundStyle(LuxuryTheme.ink)
                                    .accessibilityLabel(day.date.formatted(date: .abbreviated, time: .omitted))
                                    .accessibilityValue(store.money(day.total))
                            }.frame(height: 180)
                            // The Double conversion above is exclusively a rendering coordinate.
                            DisclosureGroup("Consultar valores") {
                                ForEach(summary.lastSevenDays) { day in
                                    LabeledContent(day.date.formatted(.dateTime.weekday(.wide)), value: store.money(day.total))
                                }
                            }.font(.caption)
                        }
                    }
                    NavigationLink(value: InventoryDestination.inventory) {
                        LuxuryCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Tu inventario requiere atención", systemImage: "shippingbox")
                                    .font(.headline)
                                Text("\(summary.lowStockVariants) variantes con stock bajo · \(summary.outOfStockVariants) agotadas")
                                Text("Revisar inventario →").font(.callout.weight(.semibold))
                            }
                        }
                    }.buttonStyle(.plain)
                    if store.data?.products.isEmpty == true {
                        LuxuryEmptyState(title: "Tu negocio comienza aquí", message: "Crea tu primer producto en la pestaña Productos y registra una entrada de inventario.")
                    }
                    LuxurySectionHeader(title: "Últimas ventas")
                    if store.data?.sales.isEmpty == true {
                        Text("Tus ventas aparecerán aquí.").foregroundStyle(LuxuryTheme.muted)
                    }
                    ForEach(Array((store.data?.sales ?? []).prefix(5))) { sale in
                        NavigationLink(value: sale) { SaleRow(sale: sale) }
                            .buttonStyle(.plain)
                    }
                    if !store.bestSellers.isEmpty {
                        LuxurySectionHeader(title: "Productos más vendidos")
                        ForEach(store.bestSellers) { item in
                            LuxuryCard { LabeledContent(item.productName, value: "\(item.quantity) unidades") }
                        }
                    }
                }
            }.padding(LuxuryTheme.gutter)
        }.luxuryCanvas().navigationTitle("Inicio").navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Sale.self) { sale in
                SaleDetailView(sale: sale)
            }
            .navigationDestination(for: InventoryDestination.self) { _ in
                InventoryView(store: store)
            }
            .refreshable { await store.reload() }
    }

    private func revenue(_ summary: DashboardSummary) -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("VENTAS HOY").font(.caption.weight(.semibold)).tracking(1.4)
            Text(store.money(summary.today)).font(.largeTitle.weight(.semibold))
                .monospacedDigit().fixedSize(horizontal: false, vertical: true)
            Divider().overlay(Color.white.opacity(0.3))
            VStack(alignment: .leading, spacing: 8) {
                Text("Semana · \(store.money(summary.week))")
                Text("Mes · \(store.money(summary.month))")
            }.font(.callout)
        }.padding(24).frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(Color.white).background(Color.black)
    }
}

#endif
