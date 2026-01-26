import Foundation
internal import Combine

@MainActor
final class CitiesViewModel: ObservableObject {
    @Published var cities: [City] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: APIService

    init(api: APIService = .shared) {
        self.api = api
    }

    func loadCities(force: Bool = false) async {
        // Simple in-memory cache: if we already have cities and not forcing, don't refetch.
        guard force || cities.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            cities = try await api.fetchCities()
                .filter { $0.isActive }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
