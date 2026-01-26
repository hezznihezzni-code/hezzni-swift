import Foundation
import SwiftUI
internal import Combine

/// Owns the logic for loading onboarding status (car rides / motorcycle / taxi)
/// and mapping the backend boolean flags into per-document UI statuses.
@MainActor
final class DriverDocumentsStatusViewModel: ObservableObject {
    @Published private(set) var statuses: [DocumentItem: DocumentStatus] = [:]
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    func status(for item: DocumentItem) -> DocumentStatus {
        statuses[item] ?? .pending
    }

    func reset() {
        statuses = [:]
        errorMessage = nil
        isLoading = false
    }

    func refresh(using currentUser: User?) async {
        // Decide which endpoint to hit based on the service status objects.
        // The backend returns a non-null status object per service that the driver has.
        guard let user = currentUser else {
            statuses = [:]
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Priority as requested: motorcycle > car rides > taxi (only one should be non-null in most cases).
            if user.motorcycleStatus != nil {
                let response = try await APIService.shared.fetchMotorcycleOnboardingStatus()
                apply(MotorcycleResponse: response)
                return
            }

            if user.carRideStatus != nil {
                let response = try await APIService.shared.fetchCarRidesOnboardingStatus()
                apply(carOrMotorcycleResponse: response)
                return
            }

            if user.taxiStatus != nil {
                let response = try await APIService.shared.fetchTaxiOnboardingStatus()
                apply(taxiResponse: response)
                return
            }

            // If none is present, default everything to pending.
            statuses = [:]
        } catch {
            errorMessage = error.localizedDescription
            // keep previous statuses on error
        }
    }

    private func apply(carOrMotorcycleResponse response: CarRidesOnboardingStatusResponse) {
        statuses = [
            .nationalID: (response.data.isNationalIdCompleted ?? false) ? .approved : .pending,
            .driversLicense: (response.data.isDriverLicenseCompleted ?? false) ? .approved : .pending,
            .proDriverCard: (response.data.isProfessionalCardCompleted ?? false) ? .approved : .pending,
            .vehicleRegistration: (response.data.isVehicleRegistrationCompleted ?? false) ? .approved : .pending,
            .vehicleInsurance: (response.data.isVehicleInsuranceCompleted ?? false) ? .approved : .pending,
            .vehicleDetails: (response.data.isVehicleDetailsCompleted ?? false) ? .approved : .pending,
            .vehiclePhotos: (response.data.isVehiclePhotosCompleted ?? false) ? .approved : .pending,
            .faceVerification: (response.data.isFaceVerificationCompleted ?? false) ? .approved : .pending
        ]
    }
    private func apply(MotorcycleResponse response: MotorcycleOnboardingStatusResponse) {
        statuses = [
            .nationalID: (response.data.isNationalIdCompleted ?? false) ? .approved : .pending,
            .driversLicense: (response.data.isDriverLicenseCompleted ?? false) ? .approved : .pending,
            .proDriverCard: (response.data.isProfessionalCardCompleted ?? false) ? .approved : .pending,
            .vehicleRegistration: (response.data.isVehicleRegistrationCompleted ?? false) ? .approved : .pending,
            .vehicleInsurance: (response.data.isVehicleInsuranceCompleted ?? false) ? .approved : .pending,
            .vehicleDetails: (response.data.isVehicleDetailsCompleted ?? false) ? .approved : .pending,
            .vehiclePhotos: (response.data.isVehiclePhotosCompleted ?? false) ? .approved : .pending,
            .faceVerification: (response.data.isFaceVerificationCompleted ?? false) ? .approved : .pending
        ]
    }

    private func apply(taxiResponse response: TaxiOnboardingStatusResponse) {
        statuses = [
            .nationalID: (response.data.isNationalIdCompleted ?? false) ? .approved : .pending,
            .driversLicense: (response.data.isDriverLicenseCompleted ?? false) ? .approved : .pending,
            .proDriverCard: (response.data.isProfessionalCardCompleted ?? false) ? .approved : .pending,
            .vehicleRegistration: (response.data.isVehicleRegistrationCompleted ?? false) ? .approved : .pending,
            .vehicleInsurance: (response.data.isVehicleInsuranceCompleted ?? false) ? .approved : .pending,
            .vehicleDetails: (response.data.isVehicleDetailsCompleted ?? false) ? .approved : .pending,
            .vehiclePhotos: (response.data.isVehiclePhotosCompleted ?? false) ? .approved : .pending,
            .faceVerification: (response.data.isFaceVerificationCompleted ?? false) ? .approved : .pending
        ]
        // NOTE: taxi has an extra isTaxiLicenseCompleted flag which currently has no matching DocumentItem.
        // If a taxi-license document is later added to the UI, map it here.
    }
}
