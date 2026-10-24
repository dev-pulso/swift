import Foundation

enum LocalOperator {
    /// Stable local seller identifier until real identity and memberships exist.
    static var id: UUID {
        let key = "commerce.localOperatorID"
        if let saved = UserDefaults.standard.string(forKey: key), let id = UUID(uuidString: saved) { return id }
        let id = UUID()
        UserDefaults.standard.set(id.uuidString, forKey: key)
        return id
    }
}
