#if os(iOS)
import SwiftUI

private struct OnboardingPage: Identifiable {
    let id: Int
    let title: String
    let message: String
    let symbol: String
    static let pages = [
        Self(id: 0, title: "Tu negocio.\nEn tus manos.", message: "Administra tu negocio desde un solo lugar.", symbol: "square.grid.2x2"),
        Self(id: 1, title: "Cada venta.\nCada detalle.", message: "Controla ventas e inventario con claridad.", symbol: "shippingbox"),
        Self(id: 2, title: "Más cerca de\ntus clientes.", message: "Conoce sus compras y construye relaciones duraderas.", symbol: "person.2"),
        Self(id: 3, title: "Decisiones que\nhacen crecer.", message: "Convierte tus números en el siguiente paso de tu negocio.", symbol: "chart.xyaxis.line")
    ]
}

@MainActor
struct OnboardingView: View {
    @ObservedObject var session: AppSession
    @State private var page = 0
    @State private var setup = false
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 12) {
                    LuxuryLogo(size: 28, style: .monolith)
                    LuxuryLabel(text: "COMMERCE / TU ESPACIO DE TRABAJO")
                }
                .padding(.horizontal, 24)
                TabView(selection: $page) {
                    ForEach(OnboardingPage.pages) { item in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 32) {
                                Image(systemName: item.symbol).font(.system(size: 72, weight: .ultraLight))
                                    .frame(maxWidth: .infinity, minHeight: 180).background(LuxuryTheme.surface)
                                    .overlay(Rectangle().stroke(LuxuryTheme.border)).accessibilityHidden(true)
                                Text(item.title).font(.largeTitle.weight(.semibold)).tracking(-1)
                                Text(item.message).font(.title3).foregroundStyle(LuxuryTheme.muted)
                                LuxuryLabel(text: "0\(item.id + 1) / 04")
                            }.padding(24)
                        }.tag(item.id)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never))
                VStack(spacing: 12) {
                    if let error = session.error {
                        LuxuryError(message: error)
                        Button("Reintentar apertura local") { Task { await session.start() } }
                    }
                    LuxuryButton(title: page < 3 ? "Continuar" : "Configurar mi negocio") {
                        if page < 3 { page += 1 } else { setup = true }
                    }
                    LuxuryButton(title: "Explorar demostración", secondary: true, loading: session.loading) {
                        Task { await session.demo() }
                    }
                }.padding(.horizontal, 24).padding(.bottom, 16)
            }
            .padding(.top, 24).luxuryCanvas()
            .sheet(isPresented: $setup) { StoreSetupView(session: session) }
        }
    }
}

#endif
