//  BasicInfo.swift
//  Hezzni Driver
//
//  Created by GitHub Copilot on 12/4/25.
//

import SwiftUI
import PhotosUI
internal import Combine


// Service model matching API response
//struct Service: Identifiable, Decodable {
//    let id: Int
//    let name: String
//    let displayName: String
//    let description: String?
//    let isActive: Bool
//}

// ViewModel for fetching services
class ServicesViewModel: ObservableObject {
    @Published var services: [DriverService] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    func fetchServices() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: [DriverService] = try await APIService.shared.fetchDriverServices()
            self.services = response.filter { $0.isActive ?? false }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func setService(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await APIService.shared.setDriverServiceType(serviceTypeId: id)
            // Optionally update local state or UserDefaults if needed
            print(response.data.user)
             UserDefaults.standard.saveDriverUser(response.data.user)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

//// Response model for services API
//struct ServicesResponse: Decodable {
//    let status: String
//    let message: String
//    let data: ServicesData
//    let timestamp: String
//}
//struct ServicesData: Decodable {
//    let status: String
//    let data: [Service]
//}

enum DocumentItem{
    case nationalID
    case driversLicense
    case proDriverCard
    case vehicleRegistration
    case vehicleInsurance
    case vehicleDetails
    case vehiclePhotos
    case faceVerification
}

struct OnboardingAppBar: View {
    let title: String
    let onBack: (() -> Void)?
    var body: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.black)
                    .font(.system(size: 20, weight: .medium))
            }
            Spacer()
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)
            Spacer()
            Color.clear.frame(width: 24)
        }
        .frame(height: 50)
        .padding(.horizontal, 16)
    }
}

struct OnboardingTabBar: View {
    let totalTabs: Int
    let currentTab: Int
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalTabs, id: \.self) { idx in
                
                Capsule()
                    .fill(idx <= currentTab ? .hezzniGreen : Color.gray.opacity(0.2))
                    .frame(height: 6)
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 15)
    }
}

// Identifiable wrapper for presenting a document scanner
struct DocumentSelection: Identifiable, Equatable {
    let id: String
    let title: String
    let type: DocumentItem
    static func == (lhs: DocumentSelection, rhs: DocumentSelection) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.type == rhs.type
    }
}


struct BasicInfo: View {

    @State var phoneNumber: String? = ""
//    var phoneNumber: String
    @State private var userName: String = ""
    @State private var fullName: String = ""
    @State private var emailAddress: String = ""
    @State private var dateOfBirth: String = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedCity: Int = -1
    @State private var isSetupComplete: Bool = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showDatePicker: Bool = false
    @State private var showCityPicker: Bool = false
    @State private var emailErrorMessage: String? = nil
    @State private var selectedDate = Date()
    @State private var selectedEarningOption: String? = nil
    @State private var selectedServiceId: Int? = nil
    // Replace previous flags with an Identifiable activeDocument
    // don't reference other instance properties during initialization
    @State private var activeDocument: DocumentSelection? = nil
    @State private var pendingDocumentSelection: DocumentSelection? = nil
    // Change activeDocumentType to optional
    @State private var activeDocumentType: DocumentItem? = nil
    // confirm state for document scanner (passed as a binding)
    @State private var documentConfirmState: Bool = false
    @State private var isLoading: Bool = false
    @State private var showDriverHomeComplete = false

    @StateObject private var citiesVM = CitiesViewModel()
    @StateObject private var servicesVM = ServicesViewModel()
    @StateObject var authController = AuthController.shared
    @StateObject private var documentsStatusVM = DriverDocumentsStatusViewModel() // Add this line

    private var cityNames: [String] {
        citiesVM.cities.map { $0.name }
    }

    // Define your base URL for images
    private let baseURL = "https://api.hezzni.com/"

    // Helper to download UIImage from URL string
    private func downloadImage(from urlString: String?) async -> UIImage? {
        guard var urlString = urlString, !urlString.isEmpty else { return nil }
        // Prepend baseURL if urlString is not absolute
        if !urlString.lowercased().hasPrefix("http") {
            urlString = baseURL + urlString
        }
        guard let url = URL(string: urlString) else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Failed to download image: \(error)")
            return nil
        }
    }

    let documents = [
        ("National ID Card (CIN)", "Government-issued identification.", DocumentItem.nationalID),
        ("Driver’s License", "Valid and current driver’s license.",DocumentItem.driversLicense),
        ("Pro Driver Card", "Professional permit required for commercial drivers.", DocumentItem.proDriverCard),
        ("Vehicle Registration", "Proof of vehicle ownership.", DocumentItem.vehicleRegistration),
        ("Vehicle Insurance", "Add current vehicle insurance details.", DocumentItem.vehicleInsurance),
        ("Vehicle Details", "Provide make, model, and plate number.", DocumentItem.vehicleDetails),
        ("Vehicle Photos", "Upload clear exterior photos of your vehicle.", DocumentItem.vehiclePhotos),
        ("Face Verification", "Take a selfie to confirm your identity.", DocumentItem.faceVerification)
    ]

     let totalTabs: Int
     @Binding var currentTab: Int
     @State private var subCurrentTab: Int = 0

     let onNext: () -> Void
     let onBack: (() -> Void)?

    var body: some View {
        ZStack {
            // Main onboarding content
            VStack(spacing: 0) {
                OnboardingAppBar(title: currentTab == 0 ? "Choose Service" : "Basic Info", onBack: onBack)
                OnboardingTabBar(totalTabs: totalTabs, currentTab: currentTab)
                Divider()
                Spacer()
                    .frame(height: 10)
                ScrollView{
                    switch (currentTab) {
                    case 0:
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Choose how you want to earn with Hezzni \(selectedEarningOption != nil ? "as a \(servicesVM.services.first(where: { String($0.id) == selectedEarningOption })?.displayName ?? "")" : "")")
                                .font(.poppins(.semiBold, size: 18 ))
                                .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                            if servicesVM.isLoading {
                                ProgressView("Loading services...")
                                    .padding()
                            } else if let error = servicesVM.errorMessage {
                                Text(error)
                                    .foregroundColor(.red)
                                    .padding()
                            } else {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(servicesVM.services) { service in
                                        EarningOptionView(
                                            image: iconForService(service),
                                            title: service.displayName,
                                            description: service.description ?? "",
                                            isSelected: selectedEarningOption == String(service.id),
                                            onSelect: {
                                                selectedEarningOption = String(service.id)
                                                selectedServiceId = service.id
                                                validateForm()
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .task {
                            if servicesVM.services.isEmpty && !servicesVM.isLoading {
                                await servicesVM.fetchServices()
                            }
                        }
                    case 1:
                        ProfileSetupView(
                            userName: $fullName,
                            phoneNumber: $phoneNumber,
                            emailAddress: $emailAddress,
                            dateOfBirth: $dateOfBirth,
                            selectedGender: $selectedGender,
                            selectedCity: $selectedCity,
                            isSetupComplete: $isSetupComplete,
                            emailErrorMessage: $emailErrorMessage,
                            selectedItem: $selectedItem,
                            selectedImage: $selectedImage,
                            showDatePicker: $showDatePicker,
                            showCityPicker: $showCityPicker,
                            selectedDate: $selectedDate,
                            cities: cityNames,
                            
                            
                        )
                        
                        
                    case 2:
                        VStack(alignment: .leading, spacing: 18) {
                            Text("Upload all required documents to activate your account.")
                                .font(Font.custom("Poppins", size: 18).weight(.semibold))
                                .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                            
                            if documentsStatusVM.isLoading {
                                ProgressView("Loading documents status...")
                                    .padding(.vertical, 8)
                            } else if let error = documentsStatusVM.errorMessage {
                                Text(error)
                                    .font(.poppins(.regular, size: 12))
                                    .foregroundColor(.red)
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(documents, id: \.0) { document in
                                    DocumentItemView(
                                        title: document.0,
                                        description: document.1,
                                        status: documentsStatusVM.status(for: document.2)
                                    ) {
                                        pendingDocumentSelection = DocumentSelection(id: document.0, title: document.0, type: document.2)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                    default:
                        Text("Something went wrong")
                    }
                }
                NavigationLink(
                    destination: DriverHomeComplete(),
                    isActive: $showDriverHomeComplete
                ) {
                    EmptyView()
                }
                Spacer()
                
                // Continue Setup Button
                VStack {
                    Button {
                        if (currentTab==0), let serviceId = selectedServiceId {
                            Task {
                                await servicesVM.setService(id: serviceId)
                                
                            }
                        }
                        if isSetupComplete {
                            saveProfileAndNavigate()
                            
                        }
                        //JUST FOR TESTING
                        if (currentTab == 2){
                            showDriverHomeComplete = true
                        }
                    } label: {
                        HStack {
                            Text(currentTab == 2 ? "Submit" : "Continue")
                                .font(.poppins(.medium, size: 14))
                                .foregroundColor(isSetupComplete ? .white : Color(red: 0.67, green: 0.67, blue: 0.67))
                        }
                        .padding(10)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(isSetupComplete ? .hezzniGreen : Color(red: 0.93, green: 0.93, blue: 0.93))
                        .cornerRadius(10)
                    }
//                    .disabled(!isSetupComplete)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 5)
                
            }
            .task {
                await citiesVM.loadCities()
            }
            .onAppear {
                // Check registration status and set currentTab accordingly
                if authController.isUserRegistered() {
                    currentTab = 2
                    fullName = authController.currentUser?.name ?? ""
                    emailAddress = authController.currentUser?.email ?? ""
                    dateOfBirth = authController.currentUser?.dob ?? ""
                    if let gender = authController.currentUser?.gender, let g = Gender(rawValue: gender) { selectedGender = g }
                    selectedCity = authController.currentUser?.cityId ?? -1
                    if let imageUrl = authController.currentUser?.imageUrl {
                        Task {
                            if let img = await downloadImage(from: imageUrl) {
                                await MainActor.run { selectedImage = img }
                            }
                        }
                    }
                } else {
                    currentTab = 0
                }
            }
            .task(id: currentTab) {
                guard currentTab == 2 else { return }
                await documentsStatusVM.refresh(using: authController.currentUser)
            }
            .onChange(of: pendingDocumentSelection) {
                if let selection = pendingDocumentSelection {
                    // Set activeDocument to trigger navigation
                    activeDocument = selection
                    pendingDocumentSelection = nil
                }
            }
            // Full-screen overlay for document scanner (no sheet/fullScreenCover/navigationDestination)
            if let doc = activeDocument {
                DocumentScannerView(
                    title: doc.title,
                    documentType: doc.type,
                    totalTabs: 3,
                    confirmState: $documentConfirmState,
                    currentTab: $subCurrentTab,
                    authController: authController,
                    onDismiss: {
                        activeDocument = nil
                    }
                )
                .zIndex(1000)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .onDisappear {
                    Task { await documentsStatusVM.refresh(using: authController.currentUser) }
                }
            }
        }
        .animation(.easeOut(duration: 0.25), value: activeDocument != nil)
    }

    private func saveProfileAndNavigate() {
        if currentTab == 1 {
            // Show loader
            isLoading = true
            defer { isLoading = false }

            // Validate fields
            let isProfilePictureUploaded = selectedImage != nil
            let isNameValid = fullName.count >= 2
            emailErrorMessage = nil
            
            guard isProfilePictureUploaded && isNameValid else {
                isSetupComplete = false
                print("SOmething went wrong 1 \(isProfilePictureUploaded) \(isNameValid)");
                return
            }

            // Prepare API payload
            let dobForAPI: String? = {
                let trimmed = dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                if let parsed = parseDOBToDate(trimmed) {
                    let f = DateFormatter()
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.dateFormat = "yyyy-MM-dd"
                    return f.string(from: parsed)
                }
                print("SOmething went wrong 2");
                return trimmed
            }()
            let selectedCityId: Int? = {
                guard selectedCity >= 0, selectedCity < citiesVM.cities.count else { return nil }
                return citiesVM.cities[selectedCity].id
                
            }()

            // Call driver complete registration API
            Task {
                do {
                    let response = try await APIService.shared.completeDriverProfile(
                        name: fullName,
                        email: emailAddress.isEmpty ? nil : emailAddress,
                        dob: dobForAPI,
                        gender: selectedGender.rawValue,
                        cityId: selectedCityId,
                        image: selectedImage
                    )
                    // Save user to UserDefaults
                    let user = response.data.user
                    if let driverUser = DriverUser.fromUser(user) {
                        UserDefaults.standard.saveDriverUser(driverUser)
                    }
                    // Mark setup complete and navigate
                    await MainActor.run {
                        isSetupComplete = true
                        currentTab += 1
                    }
                } catch {
                    await MainActor.run {
                        emailErrorMessage = error.localizedDescription
                        isSetupComplete = false
                        print("SOmething went wrong ");
                    }
                }
            }
        } else {
            // Default: just update tab and setup state
            currentTab += 1
            isSetupComplete = !isSetupComplete
        }
    }
    /// Parses a date string (e.g. "Dec 31, 2025" or "2025-12-31") to Date. Returns nil if parsing fails.
    private func parseDOBToDate(_ dob: String) -> Date? {
        let formats = ["yyyy-MM-dd", "MMM dd, yyyy", "dd/MM/yyyy", "MM/dd/yyyy"]
        for format in formats {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            if let date = formatter.date(from: dob) {
                return date
            }
        }
        return nil
    }
    private func validateForm() {
        if currentTab == 1 {
            // Phone number must not be empty if provided
            let isPhoneValid = phoneNumber == nil || !(phoneNumber!.isEmpty)
            // Validate profile picture is uploaded
            let isProfilePictureUploaded = selectedImage != nil

            // Full name must be at least 2 characters
            let isNameValid = fullName.count >= 2

            // Validate email (if provided, it should be valid format)
            var isEmailValid = true
            emailErrorMessage = nil

            if !emailAddress.isEmpty {
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                isEmailValid = emailPredicate.evaluate(with: emailAddress)

                if !isEmailValid {
                    emailErrorMessage = "Please enter a valid email address"
                }
            }

            // Update isSetupComplete
            isSetupComplete = isPhoneValid && isProfilePictureUploaded && isNameValid && isEmailValid
        } else if currentTab == 0 {
            isSetupComplete = selectedEarningOption != nil
        } else if currentTab == 2 {
            isSetupComplete = documents.allSatisfy { document in
                // Here you can add your own logic to check if the document is uploaded or not
                // For now, we will just return true for all documents
                true
            }
        }
    }
}

#Preview {
    BasicInfo_Preview()
}

struct BasicInfo_Preview: View {
    @State var currentTab = 0

    var body: some View {
        BasicInfo(
            totalTabs: 5,
            currentTab: $currentTab,
            onNext: {},
            onBack: {
                if currentTab > 0 {
                    currentTab -= 1
                }
            }
        )
    }
}

struct EarningOptionView: View {
    let image: String
    let title: String
    let description: String
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipped()
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(Font.custom("Poppins", size: 15).weight(.medium))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                Text(description)
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 20))
        .frame(height: 96)
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.50)
                .stroke(isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
        )
        .shadow(
            color: isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33, opacity: 0.25) : Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: isSelected ? 5 : 50, y: isSelected ? 0 : 4
        )
        .onTapGesture {
            onSelect()
        }
    }
}

struct DocumentItemView: View {
    let title: String
    let description: String
    var status : DocumentStatus = .pending
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(spacing: 80) {
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 4) {
                        if status == .approved {
                            Image(systemName: "checkmark.circle.fill")
                                .font(Font.custom("Poppins", size: 8).weight(.medium))
                                .foregroundColor(status == .pending ? Color(red: 0, green: 0, blue: 0).opacity(0.50): .white)
                        }
                        Text(status == .approved ? "COMPLETED" : status.rawValue)
                            .font(Font.custom("Poppins", size: 8).weight(.medium))
                            .foregroundColor(status == .pending ? Color(red: 0, green: 0, blue: 0).opacity(0.50): .white)
                    }
                    .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                    .background(status.color)
                    .cornerRadius(5)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.black)
                        Text(description)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.70))
                    }
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .inset(by: 0.50)
                    .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
            )
        }
        .buttonStyle(.plain)
    }
}

// DocumentScannerView accepts a Binding for confirmState so the caller can observe changes
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
                    dismiss()
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
                }
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
                onDismiss(); dismiss()
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
                onDismiss(); dismiss()
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
                onDismiss(); dismiss()
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
                onDismiss(); dismiss()
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
                onDismiss(); dismiss()
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
                onDismiss(); dismiss()
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
                onDismiss(); dismiss()
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
        let parsedSeats = Int(vehicleSeats) ?? 0

        var didUpload = false

        if user.carRideStatus != nil {
            let payload = CarVehicleDetailsPayload(
                make: vehicleMake,
                model: vehicleModel,
                year: parsedYear,
                plateNumber: "\(licensePlate1) \(licensePlate2) \(licensePlate3)",
                color: vehicleColor,
                seats: parsedSeats,
                region: vehicleRegion,
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
                color: vehicleColor,
                seats: parsedSeats,
                region: vehicleRegion,
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
        case .vehiclePhotos, .faceVerification:
            return false // Implement as needed
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
                PrimaryButton(
                    text: isUploading ? "Uploading..." : "Confirm",
                    isEnabled: !isUploading && isPrimaryButtonEnabled(for: documentType),
                    action: {
                        Task { await handleConfirmTapped() }
                    }
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
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
            label: "Upload your Vehicle Insurance",
            description: "Upload a clear photo of your valid insurance certificate. Ensure all details are visible.",
            fileTypeDescription: "Max file size: 5 MB · JPG or PNG only"
        )
    }
    
    var vehicleInsuranceContent: some View {
        VStack {
            Text("Vehicle Details Screen")
                .font(.title)
            Text("This screen will be implemented later")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
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
        VStack {
            Text("Vehicle Photos Screen")
                .font(.title)
            Text("This screen will be implemented later")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var faceVerificationContent: some View {
        VStack {
            Text("Face Verification Screen")
                .font(.title)
            Text("This screen will be implemented later")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// Reusable checklist row component used in the scanner view
struct ChecklistRow: View {
    let text: String


    var body: some View {
        HStack(alignment: .top, spacing: 10) {

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.hezzniGreen)
                    .padding(.top, 2)
            

            Text(text)
                .font(Font.custom("Poppins", size: 13))
                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))

            Spacer()
        }
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

struct VehicleDetailsForm: View {
    @Binding var make: String
    @Binding var model: String
    @Binding var year: String
    @Binding var licensePlate1: String
    @Binding var licensePlate2: String
    @Binding var licensePlate3: String
    @Binding var vehicleColor: String
    @Binding var numberOfSeats: String
    @Binding var region: String
    @Binding var city: String
    var onConfirm: (() -> Void)? = nil
    
    let licensePlateNumbers = Array(1...100).map { String($0) }
    
    @State private var showLicensePlateSheet: Bool = false
    @State private var tempLicensePlate3: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            VStack(spacing: 22) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Text("Add Vehicle Details")
                            .font(Font.custom("Poppins", size: 18).weight(.semibold))
                            .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                        Spacer()
                    }
                    Text("Provide accurate information about your vehicle for verification and registration.")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                }
                VStack(spacing: 15) {
                    FormField(title: "Make", placeholder: "Select vehicle make", text: $make)
                    FormField(title: "Model", placeholder: "Select vehicle model", text: $model)
                    FormField(title: "Year", placeholder: "Select year of manufacture", text: $year)
                    
                    // License Plate Number (3 fields)
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("License Plate Number")
                                .font(.poppins(.medium, size: 12))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 5)
                        
                        HStack(spacing: 10) {
                            // First field (letters/numbers) with placeholder
                            TextField("123456", text: $licensePlate1)
                                .font(.poppins(.regular, size: 14))
                                .padding(10)
                                .frame(height: 50)
                                .background(.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                                .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
                            
                            // Second field (letters/numbers)
                            TextField("أ", text: $licensePlate2)
                                .font(.poppins(.regular, size: 14))
                                .padding(10)
                                .frame(height: 50)
                                .background(.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                                )
                                .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
                            
                            // Third field (bottom sheet wheel picker)
                            Button(action: {
                                tempLicensePlate3 = licensePlate3.isEmpty ? licensePlateNumbers.first! : licensePlate3
                                showLicensePlateSheet = true
                            }) {
                                HStack(spacing: 8) {
                                    Text(licensePlate3.isEmpty ? "Select" : licensePlate3)
                                        .font(.poppins(.regular, size: 14))
                                        .foregroundColor(licensePlate3.isEmpty ? Color.black.opacity(0.4) : .black)
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
                            .sheet(isPresented: $showLicensePlateSheet) {
                                VStack(spacing: 0) {
                                    Text("Select Number")
                                        .font(.poppins(.medium, size: 16))
                                        .padding(.top, 16)
                                    Divider()
                                    Picker("Select Number", selection: $tempLicensePlate3) {
                                        ForEach(licensePlateNumbers, id: \ .self) { number in
                                            Text(number).tag(number)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                    Divider()
                                    Button("Done") {
                                        licensePlate3 = tempLicensePlate3
                                        showLicensePlateSheet = false
                                    }
                                    .font(.poppins(.medium, size: 16))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                }
                                .presentationDetents([.height(300)])
                                .presentationDragIndicator(.visible)
                            }
                        }
                    }
                    
                    FormField(title: "Vehicle Color", placeholder: "Select color", text: $vehicleColor)
                    FormField(title: "Number of Seats", placeholder: "Select number of seats", text: $numberOfSeats)
                    FormField(title: "Region", placeholder: "Select your region", text: $region)
                    FormField(title: "City", placeholder: "Select your city", text: $city)
                }
            }
            Spacer(minLength: 20)
            
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 5, trailing: 20))
    }
}

// Helper to map service to icon name
func iconForService(_ service: DriverService) -> String {
    switch service.name {
    case "MOTORCYCLE": return "motorcycle-service-icon"
    case "CAR_RIDES": return "car-service-comfort-icon"
    case "TAXI": return "taxi-service-icon"
    case "RENTAL_CARS": return "rental-service-icon"
    default: return "car-service-comfort-icon"
    }
}
