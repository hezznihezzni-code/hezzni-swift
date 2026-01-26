import SwiftUI
import Foundation
import OSLog
internal import Combine

@MainActor
final class DriverPreferencesViewModel: ObservableObject {
    @Published var preferences: [DriverPreference] = []
    @Published var selectedPreferenceIds: Set<Int> = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let api: APIService
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.hezzni.app", category: "DriverPreferences")

    init(api: APIService = .shared) {
        self.api = api
    }

    func loadPreferences(force: Bool = false) async {
        guard force || preferences.isEmpty else {
            log.debug("Skipping preferences fetch (cache hit). count=\(self.preferences.count, privacy: .public)")
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        log.info("Fetching driver preferences")
        do {
            let response = try await api.fetchDriverPreferences()
            let prefs = response.data.data.preferences
            preferences = prefs

            // If user hasn't made a local selection yet, initialize from API state.
            if selectedPreferenceIds.isEmpty {
                selectedPreferenceIds = Set(prefs.filter { $0.isActive }.map { $0.id })
            } else {
                // Remove any ids that no longer exist.
                let valid = Set(prefs.map { $0.id })
                selectedPreferenceIds = selectedPreferenceIds.intersection(valid)
            }

            log.info("Fetched driver preferences. count=\(prefs.count, privacy: .public), selected=\(self.selectedPreferenceIds.count, privacy: .public)")
        } catch {
            let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            errorMessage = msg
            log.error("Failed to fetch driver preferences. error=\(msg, privacy: .public)")
        }
    }

    func updateSelected(id: Int, isSelected: Bool) {
        if isSelected {
            selectedPreferenceIds.insert(id)
        } else {
            selectedPreferenceIds.remove(id)
        }
        log.debug("Preference selection changed. id=\(id, privacy: .public) isSelected=\(isSelected, privacy: .public) selectedCount=\(self.selectedPreferenceIds.count, privacy: .public)")
    }

    func isSelected(id: Int) -> Bool {
        selectedPreferenceIds.contains(id)
    }
}
