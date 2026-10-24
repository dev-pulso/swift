import CommerceCore

extension BusinessKind {
    var title: String {
        switch self {
        case .clothing: return "Ropa"
        case .shoes: return "Zapatos"
        case .fragrance: return "Perfumes"
        case .makeup: return "Maquillaje"
        case .accessories: return "Accesorios"
        case .jewelry: return "Joyería"
        case .bags: return "Bolsos"
        case .sports: return "Deportes"
        case .electronics: return "Electrónica"
        case .gifts: return "Regalos"
        case .handmade: return "Artesanías"
        case .other: return "Otro"
        }
    }
}

extension PaymentMethod {
    var title: String {
        switch self {
        case .cash: return "Efectivo"
        case .card: return "Tarjeta"
        case .transfer: return "Transferencia"
        case .nequi: return "Nequi"
        case .daviplata: return "Daviplata"
        case .other: return "Otro"
        }
    }
}

extension ProductVariant {
    var title: String { options.isEmpty ? "Única" : options.map { "\($0.name): \($0.value)" }.joined(separator: " · ") }
}
