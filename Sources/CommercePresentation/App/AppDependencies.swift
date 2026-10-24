import Foundation
import CommerceCore

public struct AppDependencies: Sendable {
    public let repository: any CommerceRepository

    public init(repository: any CommerceRepository) { self.repository = repository }

    public static func preview() throws -> AppDependencies {
        AppDependencies(repository: try LocalCommerceRepository(seed: DemoData.make()))
    }

    /// Real local use starts empty. Demo fixtures never contaminate a new business.
    public static func local() throws -> AppDependencies {
        let directory = try FileManager.default.url(for: .applicationSupportDirectory,
            in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("Commerce", isDirectory: true)
        return AppDependencies(repository: try LocalCommerceRepository(
            fileURL: directory.appendingPathComponent("store.json")))
    }
}
