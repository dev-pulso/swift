#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct CustomersView: View {
    @ObservedObject var store: StoreViewModel
    @State private var search = ""
    @State private var adding = false
    private var results: [Customer] {
        (store.data?.customers ?? []).filter { search.isEmpty ||
            $0.name.localizedStandardContains(search) || $0.contact.email.localizedStandardContains(search) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LuxurySearchBar(text: $search)
                LuxuryLabel(text: "RELACIONES QUE HACEN CRECER TU NEGOCIO")
                if let error = store.error {
                    LuxuryError(message: error)
                    LuxuryButton(title: "Reintentar") { Task { await store.reload() } }
                } else if store.loading && store.data == nil { ProgressView() }
                if results.isEmpty && store.data != nil {
                    LuxuryEmptyState(title: search.isEmpty ? "Conoce a tu próximo cliente" : "Sin resultados",
                        message: search.isEmpty ? "Agrega un cliente y vincula sus próximas compras." : "Prueba otro nombre o email.", symbol: "person.2")
                }
                ForEach(results) { customer in
                    NavigationLink(value: customer) {
                        LuxuryCard {
                            HStack(alignment: .top, spacing: 16) {
                                LuxuryAvatar(name: customer.name)
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(customer.name).font(.headline)
                                    Text(customer.contact.email).font(.caption).foregroundStyle(LuxuryTheme.muted)
                                    ForEach(customer.tags, id: \.self) { LuxuryBadge(text: $0) }
                                }
                            }
                        }
                    }.buttonStyle(.plain)
                }
            }.padding(20)
        }.luxuryCanvas().navigationTitle("Clientes")
            .navigationDestination(for: Customer.self) { customer in
                CustomerDetailView(customer: customer, store: store)
            }
            .navigationDestination(for: Sale.self) { sale in
                SaleDetailView(sale: sale)
            }
            .toolbar { ToolbarItem(placement: .primaryAction) {
                Button { adding = true } label: { Image(systemName: "plus").frame(minWidth: 44, minHeight: 44) }
                    .accessibilityLabel("Agregar cliente")
            } }
            .sheet(isPresented: $adding) { CustomerFormView(store: store) }
            .refreshable { await store.reload() }
    }
}

@MainActor
private struct CustomerDetailView: View {
    let customer: Customer
    @ObservedObject var store: StoreViewModel
    private var metrics: CustomerMetrics { CustomerMetrics(customerID: customer.id, sales: store.data?.sales ?? []) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                LuxuryAvatar(name: customer.name)
                Text(customer.name).font(.largeTitle.weight(.semibold))
                LuxuryMetricCard(title: "Total comprado en esta sucursal", value: store.money(metrics.totalSpent))
                LuxuryMetricCard(title: "Compras", value: "\(metrics.purchases.count)")
                LuxuryCard {
                    VStack(alignment: .leading, spacing: 12) {
                        LabeledContent("Teléfono", value: customer.contact.phone)
                        LabeledContent("Email", value: customer.contact.email)
                        LabeledContent("Dirección", value: customer.contact.address)
                        LabeledContent("Cliente desde", value: customer.createdAt.formatted(date: .abbreviated, time: .omitted))
                        if let date = metrics.lastPurchase {
                            LabeledContent("Última compra", value: date.formatted(date: .abbreviated, time: .omitted))
                        }
                        if !customer.notes.isEmpty { Text(customer.notes) }
                    }.textSelection(.enabled)
                }
                LuxurySectionHeader(title: "Historial de compras")
                if metrics.purchases.isEmpty { Text("Todavía no tiene compras registradas.").foregroundStyle(LuxuryTheme.muted) }
                ForEach(metrics.purchases) { sale in
                    NavigationLink(value: sale) { SaleRow(sale: sale) }.buttonStyle(.plain)
                }
            }.padding(20)
        }.luxuryCanvas().navigationTitle("Cliente").navigationBarTitleDisplayMode(.inline)
    }
}

@MainActor
private struct CustomerFormView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: StoreViewModel
    @StateObject private var model: CustomerEditorViewModel
    init(store: StoreViewModel) {
        self.store = store
        _model = StateObject(wrappedValue: CustomerEditorViewModel(repository: store.repository, scope: store.scope))
    }
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    LuxuryTextField(title: "Nombre", text: $model.name)
                    LuxuryTextField(title: "Teléfono", text: $model.phone).keyboardType(.phonePad)
                    LuxuryTextField(title: "Email", text: $model.email).keyboardType(.emailAddress).textInputAutocapitalization(.never)
                    LuxuryTextField(title: "Dirección", text: $model.address)
                    LuxuryTextField(title: "Notas", text: $model.notes)
                    if let error = model.error { LuxuryError(message: error) }
                    LuxuryButton(title: "Guardar cliente", loading: model.saving) {
                        Task { if await model.save() { await store.reload(); dismiss() } }
                    }
                }.padding(20)
            }.luxuryCanvas().navigationTitle("Nuevo cliente").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
                .interactiveDismissDisabled(model.saving)
        }
    }
}

#endif
