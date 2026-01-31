//
//  DocumentScannerView.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 1/31/26.
//
import SwiftUI
import PhotosUI

struct DocumentScannerView: View {
    let title: String
    let documentType: DocumentItem
    let totalTabs: Int
    @Binding var confirmState: Bool
    @Binding var currentTab : Int
    @ObservedObject var authController: AuthController
    let onDismiss: () -> Void

    @Environment(\.dismiss) private var dismiss

    // ID scan images (front/back)
    @State private var idFrontScanImage: UIImage? = nil
    @State private var idBackScanImage: UIImage? = nil

    // Camera presentation + errors
    @State private var isCameraPresented: Bool = false
    @State private var showCameraPermissionAlert: Bool = false

    // National ID specific fields
    @State private var fullName: String = ""
    @State private var nationalIDNumber: String = ""
    @State private var dateOfBirth: String = ""
    @State private var selectedGender: Gender = .male
    @State private var nationalIDExpiryDate: String = ""
    @State private var address: String = ""
    // Driver's License specific fields
    @State private var licenseNumber: String = ""
    @State private var licenseExpiryDate: String = ""
    @State private var issuingAuthority: String = ""

    // Add state variables for vehicle details fields in DocumentScannerView
    @State private var vehicleMake: String = ""
    @State private var vehicleModel: String = ""
    @State private var vehicleYear: String = ""
    @State private var vehicleLicensePlate: String = ""
    @State private var vehicleColor: String = ""
    @State private var vehicleSeats: String = ""
    @State private var vehicleRegion: String = ""
    @State private var vehicleCity: String = ""

    // License plate split into 3 parts
    @State private var licensePlate1: String = ""
    @State private var licensePlate2: String = ""
    @State private var licensePlate3: String = ""
    @State private var showLicensePlateDropdown: Bool = false

    @State private var selectedDOB: Date = Date()
    @State private var showDOBPicker: Bool = false
    @State private var selectedExpiry: Date = Date()
    @State private var showExpiryPicker: Bool = false
    @State private var currentDateField: String = "" // Track which date field is being edited
    @State private var proDriverCardImage: UIImage? = nil
    @State private var vehicleRegistrationImage: UIImage? = nil
    @State private var vehicleInsuranceImage: UIImage? = nil
    
    

    // Formatter for displaying the selected date
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }

    // Add placeholders for multi-image uploads (vehicle photos / face verification)
    @State private var vehicleFrontViewImage: UIImage? = nil
    @State private var vehicleRearViewImage: UIImage? = nil
    @State private var vehicleLeftViewImage: UIImage? = nil
    @State private var vehicleRightViewImage: UIImage? = nil
    @State private var selfieImage: UIImage? = nil

    /// Face verification: we show a confirm/retake prompt after capture.
    @State private var isSelfieCaptured: Bool = false
    /// Only enable final upload confirm after the user explicitly confirms the selfie.
    @State private var isSelfieConfirmed: Bool = false

    // Taxi-specific
    @State private var taxiLicenseImage: UIImage? = nil

    // Uploading state
    @State private var isUploading: Bool = false

    // Validation alert
    @State private var showValidationAlert: Bool = false
    @State private var validationMessage: String = ""

    // Upload state + validation alerts
    @State private var uploadErrorMessage: String? = nil

    // Document upload progress
    @State private var uploadProgress: Double = 0.0

    var body: some View {
        VStack(spacing: 0) {
            OnboardingAppBar(title: title, onBack: {
                if (currentTab > 0) {
                    currentTab -= 1
                    confirmState = false
                } else {
                    onDismiss()
//                    dismiss()
                }
            })
            // Show OnBoardingTabBar only for nationalID and driversLicense
            if documentType == .nationalID || documentType == .driversLicense {
                OnboardingTabBar(totalTabs: totalTabs, currentTab: currentTab)
            }
            Divider()
            Spacer().frame(height: 10)

            // Content based on document type
            ScrollView {
                switch documentType {
                case .nationalID, .driversLicense:
                    documentScannerContent
                case .proDriverCard:
                    proDriverCardContent
                case .vehicleRegistration:
                    vehicleRegistrationContent
                case .vehicleInsurance:
                    vehicleInsuranceContent
                case .vehicleDetails:
                    vehicleDetailsContent
                case .vehiclePhotos:
                    vehiclePhotosContent
                case .faceVerification:
                    faceVerificationContent
                }
            }

            Spacer()

            actionButtons
        }
        .ignoresSafeArea(edges: .bottom)
        .background(.white)
        .sheet(isPresented: $isCameraPresented) {
            CameraCaptureView(
                onImagePicked: { image in
                    if documentType == .faceVerification {
                        selfieImage = image
                        isSelfieCaptured = true
                        isSelfieConfirmed = false
                        isCameraPresented = false
                        withAnimation(.easeOut(duration: 0.35)) {
                            confirmState = true
                        }
                        return
                    }

                    if currentTab == 0 {
                        idFrontScanImage = image
                    } else if currentTab == 1 {
                        idBackScanImage = image
                    }

                    isCameraPresented = false
                    withAnimation(.easeOut(duration: 0.35)) {
                        confirmState = true
                    }
                },
                onCancel: {
                    isCameraPresented = false
                },
                preferredCameraDevice: documentType == .faceVerification ? .front : .rear,
                shouldMirrorForFrontCamera: documentType == .faceVerification
            )
            .ignoresSafeArea()
        }
        .alert("Camera Access Needed", isPresented: $showCameraPermissionAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text("Please allow camera access in Settings to take a photo of your ID.")
        }
        .alert("Missing Information", isPresented: $showValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(validationMessage)
        }
        .alert("Upload Failed", isPresented: Binding(
            get: { uploadErrorMessage != nil },
            set: { if !$0 { uploadErrorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { uploadErrorMessage = nil }
        } message: {
            Text(uploadErrorMessage ?? "")
        }
    }

    private func validateFields() {
        // Simple validation: check if all fields are non-empty
        switch documentType {
        case .nationalID:
            confirmState = !fullName.isEmpty && !nationalIDNumber.isEmpty && !dateOfBirth.isEmpty
        case .driversLicense:
            confirmState = !fullName.isEmpty && !licenseNumber.isEmpty && !dateOfBirth.isEmpty && !licenseExpiryDate.isEmpty
        default:
            confirmState = false
        }
    }

    // MARK: - Upload/Validation Flow

    /// Backend requires ISO-8601 date strings (e.g. 2026-01-17 or 2026-01-17T00:00:00Z).
    /// Our UI fields store friendly strings, so we normalize them before upload.
    private func iso8601DateString(fromDisplayString display: String) -> String {
        let trimmed = display.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return trimmed }

        // Try a couple of possible display formats used in the UI.
        let candidates: [String] = [
            "dd-MMM-yyyy", // e.g. 17-Jan-2024
            "d-MMM-yyyy",
            "dd/MM/yyyy",
            "MM/dd/yyyy"
        ]

        let parser = DateFormatter()
        parser.locale = Locale(identifier: "en_US_POSIX")
        parser.timeZone = TimeZone(secondsFromGMT: 0)

        var parsedDate: Date?
        for f in candidates {
            parser.dateFormat = f
            if let d = parser.date(from: trimmed) {
                parsedDate = d
                break
            }
        }

        guard let date = parsedDate else {
            // If it's already ISO-like, just send it as-is.
            return trimmed
        }

        let out = ISO8601DateFormatter()
        out.timeZone = TimeZone(secondsFromGMT: 0)
        out.formatOptions = [.withFullDate]
        return out.string(from: date)
    }

    @MainActor
    private func handleConfirmTapped() async {
        guard !isUploading else { return }

        switch documentType {
        case .nationalID:
            guard validateFormFields() else {
                validationMessage = "Please fill in all required National ID fields before submitting."
                showValidationAlert = true
                return
            }
            guard let front = idFrontScanImage, let back = idBackScanImage else {
                validationMessage = "Please take both the front and back National ID photos before submitting."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            let payload = NationalIdPayload(
                number: nationalIDNumber,
                fullName: fullName,
                dob: iso8601DateString(fromDisplayString: dateOfBirth),
                gender: selectedGender.rawValue,
                expiry: iso8601DateString(fromDisplayString: nationalIDExpiryDate),
                address: address
            )

            do {
                try await uploadNationalIdForActiveServices(payload: payload, front: front, back: back)
                onDismiss();
//                dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }

        case .driversLicense:
            guard validateFormFields() else {
                validationMessage = "Please fill in all required Driver's License fields before submitting."
                showValidationAlert = true
                return
            }
            guard let front = idFrontScanImage, let back = idBackScanImage else {
                validationMessage = "Please take both the front and back Driver's License photos before submitting."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            let payload = DriverLicensePayload(
                number: licenseNumber,
                fullName: fullName,
                dob: iso8601DateString(fromDisplayString: dateOfBirth),
                expiry: iso8601DateString(fromDisplayString: licenseExpiryDate),
                authority: issuingAuthority,
                address: address
            )

            do {
                try await uploadDriverLicenseForActiveServices(payload: payload, front: front, back: back)
                onDismiss();
//                dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }

        case .proDriverCard:
            guard let img = proDriverCardImage else {
                validationMessage = "Please upload your Pro Driver Card image before confirming."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            do {
                try await uploadProfessionalCardForActiveServices(cardImage: img)
                onDismiss();
//                dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }

        case .vehicleRegistration:
            guard let img = vehicleRegistrationImage else {
                validationMessage = "Please upload your Vehicle Registration image before confirming."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            do {
                try await uploadVehicleRegistrationForActiveServices(registrationImage: img)
                onDismiss();
//                dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }

        case .vehicleInsurance:
            guard let img = vehicleInsuranceImage else {
                validationMessage = "Please upload your Vehicle Insurance image before confirming."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            do {
                try await uploadVehicleInsuranceForActiveServices(insuranceImage: img)
                onDismiss();
//                dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }

        case .vehicleDetails:
            guard validateFormFields() else {
                validationMessage = "Please fill in all required Vehicle Details fields before confirming."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            do {
                try await uploadVehicleDetailsForActiveServices()
                onDismiss();
//                dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }

        case .vehiclePhotos:
            guard let front = vehicleFrontViewImage,
                  let rear = vehicleRearViewImage,
                  let left = vehicleLeftViewImage,
                  let right = vehicleRightViewImage else {
                validationMessage = "Please upload all 4 vehicle photos (front, rear, left, right) before confirming."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            do {
                try await uploadVehiclePhotosForActiveServices(front: front, rear: rear, left: left, right: right)
                onDismiss();
//                dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }

        case .faceVerification:
            guard let selfie = selfieImage else {
                validationMessage = "Please upload your selfie image before confirming."
                showValidationAlert = true
                return
            }

            isUploading = true
            defer { isUploading = false }

            do {
                try await uploadFaceVerificationForActiveServices(selfieImage: selfie)
                onDismiss(); dismiss()
            } catch {
                uploadErrorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Per-service upload helpers

    private func uploadNationalIdForActiveServices(payload: NationalIdPayload, front: UIImage, back: UIImage) async throws {
        guard let user = authController.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }
        var didUpload = false
        print("Status:------------------------------------")
        print(user.motorcycleStatus != nil)
        print(user.carRideStatus != nil)
        print(user.taxiStatus != nil)
        
        if user.motorcycleStatus != nil {
            _ = try await APIService.shared.uploadMotorcycleNationalId(payload, frontImage: front, backImage: back)
            didUpload = true
        }
        if user.carRideStatus != nil {
            _ = try await APIService.shared.uploadCarRidesNationalId(payload, frontImage: front, backImage: back)
            didUpload = true
        }
        if user.taxiStatus != nil {
            _ = try await APIService.shared.uploadTaxiNationalId(payload, frontImage: front, backImage: back)
            didUpload = true
        }
        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload National ID."])
        }
    }

    private func uploadDriverLicenseForActiveServices(payload: DriverLicensePayload, front: UIImage, back: UIImage) async throws {
        guard let user = authController.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }
        var didUpload = false
        if user.motorcycleStatus != nil {
            _ = try await APIService.shared.uploadMotorcycleDriverLicense(payload, frontImage: front, backImage: back)
            didUpload = true
        }
        if user.carRideStatus != nil {
            _ = try await APIService.shared.uploadCarRidesDriverLicense(payload, frontImage: front, backImage: back)
            didUpload = true
        }
        if user.taxiStatus != nil {
            _ = try await APIService.shared.uploadTaxiDriverLicense(payload, frontImage: front, backImage: back)
            didUpload = true
        }
        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload Driver License."])
        }
    }

    private func uploadProfessionalCardForActiveServices(cardImage: UIImage) async throws {
        guard let user = authController.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }
        var didUpload = false
        if user.motorcycleStatus != nil {
            _ = try await APIService.shared.uploadMotorcycleProfessionalCard(cardImage: cardImage)
            didUpload = true
        }
        if user.carRideStatus != nil {
            _ = try await APIService.shared.uploadCarRidesProfessionalCard(cardImage: cardImage)
            didUpload = true
        }
        if user.taxiStatus != nil {
            _ = try await APIService.shared.uploadTaxiProfessionalCard(cardImage: cardImage)
            didUpload = true
        }
        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload Pro Driver Card."])
        }
    }

    private func uploadVehicleRegistrationForActiveServices(registrationImage: UIImage) async throws {
        guard let user = authController.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }
        var didUpload = false
        if user.motorcycleStatus != nil {
            _ = try await APIService.shared.uploadMotorcycleVehicleRegistration(registrationImage: registrationImage)
            didUpload = true
        }
        if user.carRideStatus != nil {
            _ = try await APIService.shared.uploadCarRidesVehicleRegistration(registrationImage: registrationImage)
            didUpload = true
        }
        if user.taxiStatus != nil {
            _ = try await APIService.shared.uploadTaxiVehicleRegistration(registrationImage: registrationImage)
            didUpload = true
        }
        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload Vehicle Registration."])
        }
    }

    private func uploadVehicleInsuranceForActiveServices(insuranceImage: UIImage) async throws {
        guard let user = authController.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }
        var didUpload = false
        if user.motorcycleStatus != nil {
            _ = try await APIService.shared.uploadMotorcycleVehicleInsurance(insuranceImage: insuranceImage)
            didUpload = true
        }
        if user.carRideStatus != nil {
            _ = try await APIService.shared.uploadCarRidesVehicleInsurance(insuranceImage: insuranceImage)
            didUpload = true
        }
        if user.taxiStatus != nil {
            _ = try await APIService.shared.uploadTaxiVehicleInsurance(insuranceImage: insuranceImage)
            didUpload = true
        }
        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload Vehicle Insurance."])
        }
    }

    private func uploadVehicleDetailsForActiveServices() async throws {
        guard let user = authController.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }

        // Convert numeric fields conservatively
        let parsedYear = Int(vehicleYear) ?? 0
        _ = Int(vehicleSeats) ?? 0

        var didUpload = false

        if user.carRideStatus != nil {
            let payload = CarVehicleDetailsPayload(
                make: vehicleMake,
                model: vehicleModel,
                year: parsedYear,
                plateNumber: "\(licensePlate1) \(licensePlate2) \(licensePlate3)",
//                color: vehicleColor,
//                seats: parsedSeats,
//                region: vehicleRegion,
                cityId: 0
            )
            _ = try await APIService.shared.updateCarRidesVehicleDetails(payload)
            didUpload = true
        }

        if user.taxiStatus != nil {
            let payload = CarVehicleDetailsPayload(
                make: vehicleMake,
                model: vehicleModel,
                year: parsedYear,
                plateNumber: "\(licensePlate1) \(licensePlate2) \(licensePlate3)",
//                color: vehicleColor,
//                seats: parsedSeats,
//                region: vehicleRegion,
                cityId: 0
            )
            _ = try await APIService.shared.updateTaxiVehicleDetails(payload)
            didUpload = true
        }

        if user.motorcycleStatus != nil {
            let payload = MotorcycleVehicleDetailsPayload(
                make: vehicleMake,
                model: vehicleModel,
                year: parsedYear,
                plateNumber: licensePlate1,
                plateLetter: licensePlate2,
                plateCode: licensePlate3,
                cityId: 0
            )
            _ = try await APIService.shared.updateMotorcycleVehicleDetails(payload)
            didUpload = true
        }

        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload Vehicle Details."])
        }
    }

    private func uploadVehiclePhotosForActiveServices(front: UIImage, rear: UIImage, left: UIImage, right: UIImage) async throws {
        guard let user = AuthController.shared.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }
        var didUpload = false
        if user.motorcycleStatus != nil {
            _ = try await APIService.shared.uploadMotorcycleVehiclePhotos(frontView: front, rearView: rear, leftView: left, rightView: right)
            didUpload = true
        }
        if user.carRideStatus != nil {
            _ = try await APIService.shared.uploadCarRidesVehiclePhotos(frontView: front, rearView: rear, leftView: left, rightView: right)
            didUpload = true
        }
        if user.taxiStatus != nil {
            _ = try await APIService.shared.uploadTaxiVehiclePhotos(frontView: front, rearView: rear, leftView: left, rightView: right)
            didUpload = true
        }
        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload Vehicle Photos."])
        }
    }

    private func uploadFaceVerificationForActiveServices(selfieImage: UIImage) async throws {
        guard let user = AuthController.shared.currentUser else {
            throw NSError(domain: "DocumentScannerView", code: 1, userInfo: [NSLocalizedDescriptionKey: "No logged-in user found."])
        }
        var didUpload = false
        if user.motorcycleStatus != nil {
            _ = try await APIService.shared.uploadMotorcycleFaceVerification(selfieImage: selfieImage)
            didUpload = true
        }
        if user.carRideStatus != nil {
            _ = try await APIService.shared.uploadCarRidesFaceVerification(selfieImage: selfieImage)
            didUpload = true
        }
        if user.taxiStatus != nil {
            _ = try await APIService.shared.uploadTaxiFaceVerification(selfieImage: selfieImage)
            didUpload = true
        }
        if !didUpload {
            throw NSError(domain: "DocumentScannerView", code: 2, userInfo: [NSLocalizedDescriptionKey: "No active driver service found to upload Face Verification."])
        }
    }

    // MARK: - Common Views
    
    var documentScannerContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(currentTab == 2 ? "Confirm your ID Details" : currentTab < 2 && confirmState ? "Looks Good?" : "Scan the \(currentTab == 0 ? "front" : "back") of ID card")
                        .font(Font.custom("Poppins", size: 20).weight(.bold))
                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                    Text(currentTab == 2 ? "Make sure the details match your ID card exactly. Incorrect information may delay approval." : currentTab < 2 && confirmState ? "Check that the front of your government-issued ID card is clear and readable before continuing." : "Get your government-issued ID card ready to scan.")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                }
                Spacer()
            }
            if currentTab < 2 {
                scanInstructionsView
            } else {
                formFieldsView
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20))
    }
    
    // Helper to check if the primary button should be enabled for other document types
    private func isPrimaryButtonEnabled(for type: DocumentItem) -> Bool {
        switch type {
        case .proDriverCard:
            return proDriverCardImage != nil
        case .vehicleRegistration:
            return vehicleRegistrationImage != nil
        case .vehicleInsurance:
            return vehicleInsuranceImage != nil
        case .vehicleDetails:
            return !vehicleMake.isEmpty && !vehicleModel.isEmpty && !vehicleYear.isEmpty && !licensePlate1.isEmpty && !licensePlate2.isEmpty && !licensePlate3.isEmpty && !vehicleColor.isEmpty && !vehicleSeats.isEmpty && !vehicleRegion.isEmpty && !vehicleCity.isEmpty
        case .vehiclePhotos:
            return vehicleFrontViewImage != nil && vehicleRearViewImage != nil && vehicleLeftViewImage != nil && vehicleRightViewImage != nil
        case .faceVerification:
            return isSelfieConfirmed && selfieImage != nil
        default:
            return false
        }
    }
    
    var actionButtons: some View {
        VStack {
            if documentType == .nationalID || documentType == .driversLicense {
                
                // Sticky take photo button
                VStack {
                    Button {
                        if currentTab < 2 {
                            // Open iPhone camera first, then set confirmState after capture.
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                isCameraPresented = true
                            } else {
                                showCameraPermissionAlert = true
                            }
                        } else if currentTab == 2{
                            Task { await handleConfirmTapped() }
                        } else {
                            withAnimation(.easeOut(duration: 0.35)) {
                                confirmState.toggle()
                            }
                        }

                    } label: {
                        HStack {
                            if currentTab < 2 { Image(systemName: "camera.fill") }
                            Text(currentTab == 2 ? "Confirm" : confirmState ? "Take New Photo" : "Take Photo")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                        }
                        .foregroundColor(confirmState ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(currentTab == 2 ? .hezzniGreen : confirmState ? Color(hex: "#EEEEEE") : Color.black)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, confirmState ? 0 : 30)
                .background(Color.clear)

                // Continue/Submit button
                if confirmState && currentTab != 2{
                    VStack {
                        Button {
                            if currentTab < 2 {
                                if currentTab == 0 {
                                    currentTab = 1
                                    confirmState = false
                                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                        isCameraPresented = true
                                    } else {
                                        showCameraPermissionAlert = true
                                    }
                                } else if currentTab == 1 {
                                    currentTab = 2
                                    confirmState = false
                                }
                            } else {
                                Task { await handleConfirmTapped() }
                            }
                        } label: {
                            Text(currentTab == 2 ? (isUploading ? "Uploading..." : "Submit") : "Continue")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(.hezzniGreen)
                                .cornerRadius(12)
                        }
                        .disabled(currentTab == 2 && (!validateFormFields() || isUploading))
                        .opacity(currentTab == 2 && (!validateFormFields() || isUploading) ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .background(Color.clear)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeOut(duration: 0.35), value: confirmState)
                }
            } else {
//                if documentType != .faceVerification && isSelfieCaptured && selfieImage != nil{
                    PrimaryButton(
                        text: isUploading ? "Uploading..." : "Confirm",
                        isEnabled: !isUploading && isPrimaryButtonEnabled(for: documentType),
                        action: {
                            Task { await handleConfirmTapped() }
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
//                }
            }
        }
    }
    
    private func validateFormFields() -> Bool {
        switch documentType {
        case .nationalID:
            return !fullName.isEmpty && !nationalIDNumber.isEmpty && !dateOfBirth.isEmpty && !nationalIDExpiryDate.isEmpty && !address.isEmpty
        case .driversLicense:
            return !fullName.isEmpty && !licenseNumber.isEmpty && !dateOfBirth.isEmpty && !licenseExpiryDate.isEmpty && !issuingAuthority.isEmpty && !address.isEmpty
        case .vehicleDetails:
            return !vehicleMake.isEmpty && !vehicleModel.isEmpty && !vehicleYear.isEmpty && !licensePlate1.isEmpty && !licensePlate2.isEmpty && !licensePlate3.isEmpty && !vehicleColor.isEmpty && !vehicleSeats.isEmpty && !vehicleRegion.isEmpty && !vehicleCity.isEmpty
        default:
            return false
        }
    }
    
    // MARK: - Placeholder views for other document types
    
    var proDriverCardContent: some View {
        DocumentImageUploader(
            image: $proDriverCardImage,
            label: "Upload your Pro Driver Card",
            description: "Upload a clear photo of your valid professional driver card. Make sure all details are readable.",
            fileTypeDescription: "Max file size: 5 MB · JPG or PNG only"
        )
    }
    
    var vehicleRegistrationContent: some View {
        DocumentImageUploader(
            image: $vehicleRegistrationImage,
            label: "Upload your Vehicle Registration",
            description: "Upload a clear photo of your valid registration. Ensure all details are visible.",
            fileTypeDescription: "Max file size: 5 MB · JPG or PNG only"
        )
    }
    
    var vehicleInsuranceContent: some View {
        DocumentImageUploader(
            image: $vehicleInsuranceImage,
            label: "Upload your Vehicle Insurance",
            description: "Upload a clear photo of your valid insurance certificate. Ensure all details are visible.",
            fileTypeDescription: "Max file size: 5 MB · JPG or PNG only"
        )
        
    }
    
    var vehicleDetailsContent: some View {
        VehicleDetailsForm(
            make: $vehicleMake,
            model: $vehicleModel,
            year: $vehicleYear,
            licensePlate1: $licensePlate1,
            licensePlate2: $licensePlate2,
            licensePlate3: $licensePlate3,
            vehicleColor: $vehicleColor,
            numberOfSeats: $vehicleSeats,
            region: $vehicleRegion,
            city: $vehicleCity,
            onConfirm: { /* handle confirm action for vehicle details */ }
        )
    }

    var vehiclePhotosContent: some View {
        MultiDocumentImageUploader(
            frontImage: $vehicleFrontViewImage,
            rearImage: $vehicleRearViewImage,
            leftSideImage: $vehicleLeftViewImage,
            rightSideImage: $vehicleRightViewImage,
            label: "Upload Your Vehicle Photos",
            description: "Add clear photos of your vehicle from all sides. Make sure your car is clean, well-lit, and the license plate is visible.",
            fileTypeDescription: "Max file size: 5 MB · JPG or PNG only"
        )
    }
    
    var faceVerificationContent: some View {
        faceVerificationView(
            selfieImage: $selfieImage,
            isSelfieCaptured: $isSelfieCaptured,
            isSelfieConfirmed: $isSelfieConfirmed,
            onTakeSelfie: {
                // Open camera (front). Also reset any prior confirmation.
                isSelfieConfirmed = false
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isCameraPresented = true
                } else {
                    showCameraPermissionAlert = true
                }
            },
            onRetake: {
                selfieImage = nil
                isSelfieCaptured = false
                isSelfieConfirmed = false
                confirmState = false

                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isCameraPresented = true
                } else {
                    showCameraPermissionAlert = true
                }
            },
            onConfirmSelfie: {
                isSelfieConfirmed = true
            }
        )
    }
    
    // MARK: - Scan Instructions View
    
    var scanInstructionsView: some View {
        Group {
            scanImagePreview
            if !confirmState {
                scanChecklist
            }
        }
    }

    var scanImagePreview: some View {
        Group {
            if currentTab == 0, let image = idFrontScanImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if currentTab == 1, let image = idBackScanImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(currentTab == 0 ? "id_front_scan" : "id_back_scan")
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 214)
        .clipped()
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .inset(by: 1)
                .stroke(Color.black.opacity(0.20), style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
        )
        .padding(.vertical, 15)
    }

    var scanChecklist: some View {
        VStack(alignment: .leading, spacing: 15) {
            ChecklistRow(text: "Take a clear and in-focus picture")
            ChecklistRow(text: "Only scan original ID")
            ChecklistRow(text: "Try to avoid glare and shadows")
            ChecklistRow(text: "Utilize good lighting")
        }
    }
    
    func expiryDateField(binding: Binding<String>, title: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.poppins(.medium, size: 12))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 5)
            
            Button(action: {
                currentDateField = title
                showExpiryPicker = true
            }) {
                HStack(spacing: 8) {
                    Text(binding.wrappedValue.isEmpty ? "Select \(title.lowercased())" : binding.wrappedValue)
                        .font(.poppins(.regular, size: 14))
                        .foregroundColor(binding.wrappedValue.isEmpty ? Color.black.opacity(0.4) : .black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(10)
                .frame(height: 50)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
            }
        }
        .sheet(isPresented: $showExpiryPicker) {
            DatePickerPopup(
                selectedDate: $selectedExpiry,
                dateOfBirth: binding,
                isPresented: $showExpiryPicker
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.hidden)
        }
    }
    
    var genderSelector: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("Gender")
                    .font(.poppins(.medium, size: 12))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 5)
            
            HStack(spacing: 10) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    Button(action: {
                        selectedGender = gender
                        validateFields()
                    }) {
                        HStack(spacing: 8) {
                            Image(
                                gender == .male ? "male_icon" : "female_icon"
                            )
                                .frame(width: 25, height: 25)
                                .foregroundColor(selectedGender == gender ? .hezzniGreen : .gray)
                            
                            Text(gender.rawValue)
                                .font(.poppins(.regular, size: 14))
                                .foregroundColor(selectedGender == gender ? .hezzniGreen : .gray)
                        
                            Spacer()
                        }
                        .padding(10)
                        .frame(height: 50)
                        .background(selectedGender == gender ? .hezzniGreen.opacity(0.1) : .white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(selectedGender == gender ? .hezzniGreen : Color.black.opacity(0.2), lineWidth: 0.5)
                        )
                        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
                    }
                }
            }
        }
    }

    var dateOfBirthField: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Date of Birth Field
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Date of Birth")
                        .font(.poppins(.medium, size: 12))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 5)
                
                Button(action: {
                    showDOBPicker = true
                }) {
                    HStack(spacing: 8) {
                        Text(dateOfBirth.isEmpty ? "Enter your Date of birth" : dateOfBirth)
                            .font(.poppins(.regular, size: 14))
                            .foregroundColor(dateOfBirth.isEmpty ? Color.black.opacity(0.4) : .black)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .padding(10)
                    .frame(height: 50)
                    .background(.white)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                    )
                    .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
                }
            }
            
            .sheet(isPresented: $showDOBPicker) {
                DatePickerPopup(
                    selectedDate: $selectedDOB,
                    dateOfBirth: $dateOfBirth,
                    isPresented: $showDOBPicker
                )
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.hidden)
            }
        }
    }
    
    var formFieldsView: some View {
        VStack(spacing: 15) {
            if documentType == .nationalID {
                FormField(title: "Full Name", placeholder: "Enter your full name", text: $fullName)
                    .onChange(of: fullName) { validateFields() }

                FormField(title: "National ID Number", placeholder: "Enter your national ID number", text: $nationalIDNumber)
                    .onChange(of: nationalIDNumber) { validateFields() }

                dateOfBirthField
                genderSelector
                expiryDateField(binding: $nationalIDExpiryDate, title: "Expiry Date")

                FormField(title: "Address", placeholder: "Enter your address", text: $address)
                    .onChange(of: address) { validateFields() }
            } else if documentType == .driversLicense {
                FormField(title: "Full Name", placeholder: "Enter your full name", text: $fullName)
                    .onChange(of: fullName) { validateFields() }

                FormField(title: "License Number", placeholder: "Enter your license number", text: $licenseNumber)
                    .onChange(of: licenseNumber) { validateFields() }

                dateOfBirthField
                expiryDateField(binding: $licenseExpiryDate, title: "Expiry Date")

                FormField(title: "Issuing Authority", placeholder: "Enter issuing authority", text: $issuingAuthority)
                    .onChange(of: issuingAuthority) { validateFields() }

                FormField(title: "Address", placeholder: "Enter your address", text: $address)
                    .onChange(of: address) { validateFields() }
            }
        }
    }
}

// MARK: - Face Verification

struct faceVerificationView: View {
    @Binding var selfieImage: UIImage?
    @Binding var isSelfieCaptured: Bool
    @Binding var isSelfieConfirmed: Bool

    let onTakeSelfie: () -> Void
    let onRetake: () -> Void
    let onConfirmSelfie: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Take a verification selfie")
                .font(
                    Font.custom("Poppins", size: 20)
                        .weight(.semibold)
                )
                .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                .frame(maxWidth: .infinity, alignment: .topLeading)

            Text("Take a quick selfie to confirm your identity and match it with your ID card.")
                .font(Font.custom("Poppins", size: 12))
                .foregroundColor(.black.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .topLeading)

            ZStack {
                if let img = selfieImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image("face_verification_background")
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical, 10)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 214)
            .clipped()
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 1)
                    .stroke(Color.black.opacity(0.20), style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
            )
            .padding(.vertical, 15)

            if selfieImage == nil {
                VStack {
                    ChecklistRow(text: " Make sure your face is well lit")
                    ChecklistRow(text: "Remove hats, masks, or sunglasses")
                    ChecklistRow(text: "Keep a neutral expression")
                    ChecklistRow(text: "Hold the phone steady")
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Use this photo?")
                        .font(Font.custom("Poppins", size: 16).weight(.semibold))
                        .foregroundColor(.black)

                    Text("If it\'s clear and centered, confirm it. Otherwise, take another shot.")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(.black.opacity(0.5))

                    HStack(spacing: 12) {
                        Button(action: onRetake) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retake")
                                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                            }
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "#EEEEEE"))
                            .cornerRadius(12)
                        }

                        Button(action: {
                            isSelfieCaptured = true
                            onConfirmSelfie()
                        }) {
                            Text("Use Photo")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.hezzniGreen)
                                .cornerRadius(12)
                        }
                    }
                }
            }

            Spacer()

            if selfieImage == nil {
                Button(action: onTakeSelfie) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Take Selfie")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    faceVerificationView(
        selfieImage: .constant(nil),
        isSelfieCaptured: .constant(false),
        isSelfieConfirmed: .constant(false),
        onTakeSelfie: {},
        onRetake: {},
        onConfirmSelfie: {}
    )
}

struct MultiDocumentImageUploader: View{
    @Binding var frontImage: UIImage?
    @Binding var rearImage: UIImage?
    @Binding var leftSideImage: UIImage?
    @Binding var rightSideImage: UIImage?
    let label: String
    let description: String?
    let fileTypeDescription: String

    private struct PhotoSlot: View {
        let title: String
        @Binding var image: UIImage?
        let label: String
        let fileTypeDescription: String

        var body: some View {
            VStack{
                Text(title)
                  .font(
                    Font.custom("Poppins", size: 13)
                      .weight(.medium)
                  )
                  .foregroundColor(.black)
                  .frame(maxWidth: .infinity, alignment: .topLeading)

                ZStack {
                    if let uiImage = image {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 190)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black.opacity(0.15), lineWidth: 1.5)
                                )
                            HStack(spacing: 10) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(label)
                                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                                        .foregroundColor(.black)
                                    Text("325.50 KB")
                                        .font(Font.custom("Poppins", size: 10))
                                        .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                                }
                                Spacer()
                                VStack(spacing: 10) {
                                    Image("delete_icon")
                                        .foregroundStyle(.red)
                                        .onTapGesture {
                                            image = nil
                                        }
                                }
                                .frame(width: 35, height: 35)
                                .background(Color(red: 0.83, green: 0.18, blue: 0.18).opacity(0.10))
                                .cornerRadius(5)
                            }
                            .padding(EdgeInsets(top: 10, leading: 13, bottom: 10, trailing: 10))
                            .background(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
                            )
                            .shadow(
                                color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
                            )
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .inset(by: 1)
                                .stroke(Color.black.opacity(0.20),style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                        )

                    } else {
                        VStack(spacing: 12) {
                            Image("upload_image")
                                .resizable()
                                .scaledToFit()
                                .opacity(0.6)
                                .frame(width: 90)
                                .foregroundColor(.clear)
                            Text(fileTypeDescription)
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                            HStack(alignment: .top, spacing: 10) {
                                PhotosPicker(
                                    selection: Binding(
                                        get: { nil },
                                        set: { item in
                                            if let item = item {
                                                item.loadTransferable(type: Data.self) { result in
                                                    if case .success(let data?) = result, let img = UIImage(data: data) {
                                                        image = img
                                                    }
                                                }
                                            }
                                        }
                                    ),
                                    matching: .images,
                                    photoLibrary: .shared()) {
                                        HStack {
                                            Image("upload_icon")
                                                .foregroundStyle(.hezzniGreen)
                                            Text("Upload")
                                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                                        }
                                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                        .frame(height: 40)
                                        .background(.white)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .inset(by: 0.50)
                                                .stroke(
                                                    Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                                                )
                                        )
                                        .shadow(
                                            color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
                                        )
                                    }
                                HStack(spacing: 10) {
                                    Image("take_picture_icon")
                                        .foregroundStyle(.black)
                                    Text("Take Photo")
                                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                                        .foregroundColor(.black)
                                }
                                .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                .frame(height: 40)
                                .background(.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.50)
                                        .stroke(
                                            Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                                        )
                                )
                                .shadow(
                                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 214)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .inset(by: 1)
                                .stroke(Color.black.opacity(0.20),style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                        )

                        Spacer()
                    }
                }
            }
            .padding(.vertical, 15)
        }
    }

    var body: some View{
        ScrollView{
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(label)
                            .font(Font.custom("Poppins", size: 18).weight(.semibold))
                            .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                        if let description = description {
                            Text(description)
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                        }
                    }
                    Spacer()
                }

                PhotoSlot(title: "Vehicle Front View", image: $frontImage, label: label, fileTypeDescription: fileTypeDescription)
                PhotoSlot(title: "Vehicle Rear View", image: $rearImage, label: label, fileTypeDescription: fileTypeDescription)
                PhotoSlot(title: "Vehicle Left Side View", image: $leftSideImage, label: label, fileTypeDescription: fileTypeDescription)
                PhotoSlot(title: "Vehicle Right Side View", image: $rightSideImage, label: label, fileTypeDescription: fileTypeDescription)
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))

    }
}

struct DocumentImageUploader: View {
    @Binding var image: UIImage?
    let label: String
    let description: String?
    let fileTypeDescription: String
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(Font.custom("Poppins", size: 18).weight(.semibold))
                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                    if let description = description {
                        Text(description)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                    }
                }
                Spacer()
            }
            ZStack {
                if let uiImage = image {
                    VStack {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1.5)
                            )
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(label)
                                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                                    .foregroundColor(.black)
                                Text("325.50 KB")
                                    .font(Font.custom("Poppins", size: 10))
                                    .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                            }
                            Spacer()
                            VStack(spacing: 10) {
                                Image("delete_icon")
                                    .foregroundStyle(.red)
                                    .onTapGesture {
                                        image = nil
                                    }
                            }
                            .frame(width: 35, height: 35)
                            .background(Color(red: 0.83, green: 0.18, blue: 0.18).opacity(0.10))
                            .cornerRadius(5)
                        }
                        .padding(EdgeInsets(top: 10, leading: 13, bottom: 10, trailing: 10))
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 0.50)
                                .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
                        )
                        .shadow(
                            color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
                        )
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .inset(by: 1)
                            .stroke(Color.black.opacity(0.20),style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                    )
                    .padding(.vertical, 15)
                } else {
                    VStack(spacing: 12) {
                        Image("upload_image")
                            .resizable()
                            .scaledToFit()
                            .opacity(0.6)
                            .frame(width: 90)
                            .foregroundColor(.clear)
                        Text(fileTypeDescription)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        HStack(alignment: .top, spacing: 10) {
                            PhotosPicker(
                                selection: Binding(
                                    get: { nil },
                                    set: { item in
                                        if let item = item {
                                            item.loadTransferable(type: Data.self) { result in
                                                if case .success(let data?) = result, let img = UIImage(data: data) {
                                                    image = img
                                                }
                                            }
                                        }
                                    }
                                ),
                                matching: .images,
                                photoLibrary: .shared()) {
                                HStack {
                                    Image("upload_icon")
                                        .foregroundStyle(.hezzniGreen)
                                    Text("Upload")
                                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                                }
                                .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                .frame(height: 40)
                                .background(.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .inset(by: 0.50)
                                        .stroke(
                                            Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                                        )
                                )
                                .shadow(
                                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
                                )
                            }
                            HStack(spacing: 10) {
                                Image("take_picture_icon")
                                    .foregroundStyle(.black)
                                Text("Take Photo")
                                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                                    .foregroundColor(.black)
                            }
                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                            .frame(height: 40)
                            .background(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.50)
                                    .stroke(
                                        Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                                    )
                            )
                            .shadow(
                                color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 214)
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .inset(by: 1)
                            .stroke(Color.black.opacity(0.20),style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                    )
                    .padding(.vertical, 15)
                    Spacer()
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
    }
}

struct MultiDocumentPreviewer: PreviewProvider {
    static var previews: some View{
        MultiDocumentImageUploader(
            frontImage: .constant(nil),
            rearImage: .constant(nil),
            leftSideImage: .constant(nil),
            rightSideImage: .constant(nil),
            label: "Upload Your Vehicle Photos",
            description: "Add clear photos of your vehicle from all sides. Make sure your car is clean, well-lit, and the license plate is visible.",
            fileTypeDescription: "Max file size: 5 MB · JPG or PNG only"
        )
    }
}
