#if os(iOS)
import SwiftUI
import CommerceCore

@MainActor
struct StoreSetupView: View {
    @ObservedObject var session: AppSession
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var kind = BusinessKind.other
    @State private var currency = "COP"
    @State private var city = ""
    @State private var phone = ""
    @State private var email = ""
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Un espacio para\ntu próximo capítulo.").font(.largeTitle.weight(.semibold))
                    Text("Configuración local en este dispositivo. No necesitas crear una cuenta para probar el MVP.")
                        .foregroundStyle(LuxuryTheme.muted)
                    LuxuryTextField(title: "Nombre del negocio", text: $name)
                    Picker("Tipo de negocio", selection: $kind) {
                        ForEach(BusinessKind.allCases, id: \.self) { Text($0.title).tag($0) }
                    }.pickerStyle(.menu)
                    Picker("Moneda", selection: $currency) {
                        ForEach(Money.supportedCurrencies, id: \.self) { Text($0).tag($0) }
                    }
                    LuxuryTextField(title: "Ciudad", text: $city)
                    LuxuryTextField(title: "Teléfono", text: $phone).keyboardType(.phonePad)
                    LuxuryTextField(title: "Email", text: $email).keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    if let error = session.error { LuxuryError(message: error) }
                    LuxuryButton(title: "Crear mi negocio", loading: session.loading) {
                        Task {
                            await session.create(Business(name: name, kind: kind, currencyCode: currency,
                                city: city, contact: Contact(phone: phone, email: email)))
                            if session.store != nil { dismiss() }
                        }
                    }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }.padding(24)
            }.luxuryCanvas().navigationTitle("Tu negocio").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } } }
                .interactiveDismissDisabled(session.loading)
        }
    }
}

#endif
