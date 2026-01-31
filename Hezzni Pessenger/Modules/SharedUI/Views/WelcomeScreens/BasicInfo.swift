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
