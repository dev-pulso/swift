#if os(iOS)
import SwiftUI

@MainActor
public struct CommerceRootView: View {
    @StateObject private var session = AppSession()
    public init() {}
    public var body: some View {
        Group {
            if let store = session.store {
                CommerceTabs(store: store, leaveDemo: session.leaveDemo).id(store.scope)
            } else if session.loading {
                ProgressView("Preparando tu espacio…")
            } else {
                OnboardingView(session: session)
            }
        }
        .tint(LuxuryTheme.ink).luxuryCanvas()
        .task { await session.start() }
    }
}

@MainActor
private struct CommerceTabs: View {
    @ObservedObject var store: StoreViewModel
    let leaveDemo: () -> Void
    var body: some View {
        TabView {
            NavigationStack { DashboardView(store: store) }
                .tabItem { Label("Inicio", systemImage: "square.grid.2x2") }
            NavigationStack { SalesView(store: store) }
                .tabItem { Label("Ventas", systemImage: "creditcard") }
            NavigationStack { ProductsView(store: store) }
                .tabItem { Label("Productos", systemImage: "shippingbox") }
            NavigationStack { CustomersView(store: store) }
                .tabItem { Label("Clientes", systemImage: "person.2") }
            NavigationStack {
                List {
                    Section("Operación") {
                        NavigationLink(value: InventoryDestination.inventory) {
                            Label("Inventario", systemImage: "archivebox")
                        }
                    }
                    if let business = store.data?.business {
                        Section("Tu negocio") {
                            LabeledContent("Nombre", value: business.name)
                            LabeledContent("Tipo", value: business.kind.title)
                            LabeledContent("Moneda", value: business.currencyCode)
                            LabeledContent("Ciudad", value: business.city)
                            LabeledContent("Impuesto", value: "\(business.taxRate * 100)%")
                        }
                    }
                    Section {
                        Text("Los pagos se registran manualmente. Los datos de tu negocio se guardan en este dispositivo.")
                            .font(.footnote).foregroundStyle(LuxuryTheme.muted)
                    }
                    if store.isDemo {
                        Section { Button("Salir de la demostración", action: leaveDemo) }
                    }
                }
                .navigationTitle("Más")
                .navigationDestination(for: InventoryDestination.self) { _ in
                    InventoryView(store: store)
                }
            }.tabItem { Label("Más", systemImage: "ellipsis") }
        }
        .task { await store.reload() }
        .safeAreaInset(edge: .top, spacing: 0) {
            if store.isDemo {
                Text("DEMOSTRACIÓN · DATOS DE EJEMPLO").font(.caption2.weight(.semibold)).tracking(1)
                    .frame(maxWidth: .infinity).padding(8).background(LuxuryTheme.canvas)
            }
        }
    }
}

#endif
