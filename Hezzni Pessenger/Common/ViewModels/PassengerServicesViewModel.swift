import SwiftUI
import Foundation
import OSLog
internal import Combine

@MainActor
final class PassengerServicesViewModel: ObservableObject {
    @Published var services: [PassengerService] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: APIService
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.hezzni.app", category: "PassengerServices")

    init(api: APIService = .shared) {
        self.api = api
    }

    func loadServices(force: Bool = false) async {
        guard force || services.isEmpty else {
            log.debug("Skipping passenger services fetch (cache hit). count=\(self.services.count, privacy: .public)")
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        log.info("Fetching passenger services")
        do {
            let fetched = try await api.fetchPassengerServices()
            services = fetched
            log.info("Fetched passenger services. count=\(fetched.count, privacy: .public)")
        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            errorMessage = msg
            log.error("Failed to fetch passenger services. error=\(msg, privacy: .public)")
        }
    }
}
