import Foundation
import SwiftUI
internal import Combine

@MainActor
final class DriverServicesViewModel: ObservableObject {
    @Published var services: [DriverService] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var selectedServiceId: Int? = nil
    @Published var didSaveSelection: Bool = false

    func loadServices() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            services = try await APIService.shared.fetchDriverServices()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }

    func saveSelection() async {
        guard let selectedServiceId else {
            errorMessage = "Please select a service"
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await APIService.shared.setDriverServiceType(serviceTypeId: selectedServiceId)
            didSaveSelection = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
