//
//  CompleteProfile.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/9/25.
//

import SwiftUI
import PhotosUI

enum Gender: String, CaseIterable {
    case male = "MALE"
    case female = "FEMALE"
}

struct CompleteProfile: View {
    var isUpdateProfile: Bool = false
    var onBack: (() -> Void)? = nil
    var onProfileUpdated: ((String) -> Void)? = nil
    @StateObject private var authController = AuthController.shared
    @StateObject private var citiesVM = CitiesViewModel()
    @State private var userName: String = ""
    @State private var phoneNumber: String? = nil
    @State private var emailAddress: String = ""
    @State private var dateOfBirth: String = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedCity: Int = -1
    @State private var isSetupComplete: Bool = false
    @State private var navigateToHome = false
    @State private var emailErrorMessage: String?
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showDatePicker: Bool = false
    @State private var showCityPicker: Bool = false
    @State private var selectedDate = Date()
    @Environment(\.dismiss) var dismiss

    // Track whether we've already prefilled once
    @State private var didPrefillFromCurrentUser = false

    // Show overlay loader while registration/update is in progress
    @State private var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()

                VStack {
                    CustomAppBar(title: isUpdateProfile ? "Update profile" : "Account Setup",
                                 backButtonAction: {
                        onBack?()
                    })
                    .padding(.horizontal, 16)

                    ScrollView {
                        ProfileSetupView(
                            userName: $userName,
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
                            isUpdateProfile: isUpdateProfile,
                            cities: cityNames
                        )
                    }

                    Spacer()

                    // Continue Setup Button
                    VStack {
                        Button(action: {
                            if isSetupComplete {
                                saveProfileAndNavigate()
                            }
                        }) {
                            HStack {
                                Text(isUpdateProfile ? "Update Profile" : "Continue Setup")
                                    .font(.poppins(.medium, size: 14))
                                    .foregroundColor(isSetupComplete ? .white : Color(red: 0.67, green: 0.67, blue: 0.67))
                            }
                            .padding(10)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(isSetupComplete ? .hezzniGreen : Color(red: 0.93, green: 0.93, blue: 0.93))
                            .cornerRadius(10)
                        }
                        .disabled(!isSetupComplete)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)
                }
                .blur(radius: isLoading ? 6 : 0)
                .animation(.easeInOut(duration: 0.15), value: isLoading)

                if isLoading {
                    Color.black.opacity(0.05)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    VStack(spacing: 10) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .hezzniGreen))

                        Text(isUpdateProfile ? "Updating…" : "Saving…")
                            .font(.poppins(.medium, size: 12))
                            .foregroundColor(.black.opacity(0.8))
                    }
                    .frame(width: 100, height: 100)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                    .transition(.scale.combined(with: .opacity))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(isUpdateProfile ? "Updating profile" : "Completing registration")
                }
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MainScreen()
                    .navigationBarBackButtonHidden(true)
            }
//            .navigationDestionation(isPresented: $navigateTo)
        }
        .task {
            await citiesVM.loadCities()
            await MainActor.run {
                prefillFromCurrentUserIfNeeded()
            }
        }
        .onAppear {
            prefillFromCurrentUserIfNeeded()
        }
        .onChange(of: authController.currentUser?.id) {
            prefillFromCurrentUserIfNeeded(force: true)
        }
        .onChange(of: citiesVM.cities.count) {
            // If cities arrive after user, resolve selectedCity -> index.
            prefillFromCurrentUserIfNeeded()
        }
    }
    
    private var cityNames: [String] {
        citiesVM.cities.map { $0.name }
    }

    private func saveProfileAndNavigate() {
        Task {
            await MainActor.run { isLoading = true }
            defer {
                Task { @MainActor in
                    isLoading = false
                }
            }

            let selectedCityId: Int? = {
                guard selectedCity >= 0, selectedCity < citiesVM.cities.count else { return nil }
                return citiesVM.cities[selectedCity].id
            }()

            // Convert UI date string (e.g. "Dec 31, 2025") -> yyyy-MM-dd for backend.
            let dobForAPI: String? = {
                let trimmed = dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }

                if let parsed = parseDOBToDate(trimmed) {
                    let f = DateFormatter()
                    f.locale = Locale(identifier: "en_US_POSIX")
                    f.dateFormat = "yyyy-MM-dd"
                    return f.string(from: parsed)
                }

                return trimmed
            }()

            if isUpdateProfile {
                guard let phone = phoneNumber, !phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                      let cityId = selectedCityId,
                      let dob = dobForAPI, !dob.isEmpty,
                      selectedImage != nil,
                      !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    await MainActor.run { isSetupComplete = computeIsSetupComplete() }
                    return
                }

                let success = await authController.updateProfile(
                    name: userName,
                    email: emailAddress.isEmpty ? nil : emailAddress,
                    phone: phone,
                    image: selectedImage,
                    dob: dob,
                    gender: selectedGender.rawValue,
                    cityId: cityId
                )

                await MainActor.run {
                    if success {
                        // Dismiss update screen, then let AccountScreen show the toast.
                        dismiss()
                        onProfileUpdated?("Profile Updated Successfully")
                    }
                }
                return
            }

            let success = await authController.completeRegistration(
                name: userName,
                email: emailAddress.isEmpty ? nil : emailAddress,
                image: selectedImage,
                dob: dobForAPI,
                gender: selectedGender.rawValue,
                cityId: selectedCityId
            )

            await MainActor.run {
                if success {
                    navigateToHome = true
                }
            }
        }
    }

    private func prefillFromCurrentUserIfNeeded(force: Bool = false) {
        guard force || !didPrefillFromCurrentUser else { return }
        guard let user = authController.currentUser else { return }

        // Prefill simple fields
        if let name = user.name, !name.isEmpty { userName = name }
        phoneNumber = user.phone
        emailAddress = user.email ?? ""
        dateOfBirth = user.dob ?? ""

        if let gender = user.gender?.lowercased() {
            if gender == "female" { selectedGender = .female }
            else if gender == "male" { selectedGender = .male }
        }

        // Resolve cityId to picker index when cities are available
        if let cityId = user.cityId, !citiesVM.cities.isEmpty {
            if let idx = citiesVM.cities.firstIndex(where: { $0.id == cityId }) {
                selectedCity = idx
            }
        }

        // Try parsing dob into Date so the picker opens on the right day.
        if let dob = user.dob, let parsed = parseDOBToDate(dob) {
            selectedDate = parsed
        }

        // Preload profile image if available
        if let imagePath = user.imageUrl, !imagePath.isEmpty, selectedImage == nil {
            if let url = URLEnvironment.imageURL(for: imagePath) {
                Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        if let image = UIImage(data: data) {
                            await MainActor.run {
                                selectedImage = image
                            }
                        }
                    } catch {
                        // Optionally handle error (e.g., log or show placeholder)
                    }
                }
            }
        }

        didPrefillFromCurrentUser = true
        isSetupComplete = computeIsSetupComplete()
    }

    private func computeIsSetupComplete() -> Bool {
        let isNameValid = userName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2

        var isEmailValid = true
        if !emailAddress.isEmpty {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            isEmailValid = emailPredicate.evaluate(with: emailAddress)
        }

        let isProfilePictureUploaded = selectedImage != nil

        if isUpdateProfile {
            let isPhoneValid = (phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
            let isDOBValid = !dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let isCityValid = selectedCity >= 0 && selectedCity < citiesVM.cities.count
            return isNameValid && isPhoneValid && isDOBValid && isCityValid && isProfilePictureUploaded && (emailAddress.isEmpty || isEmailValid)
        }

        return isNameValid && isProfilePictureUploaded && (emailAddress.isEmpty || isEmailValid)
    }

    private func parseDOBToDate(_ dob: String) -> Date? {
        let trimmed = dob.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")

        // Common backend formats
        formatter.dateFormat = "yyyy-MM-dd"
        if let d = formatter.date(from: trimmed) { return d }

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let d = formatter.date(from: trimmed) { return d }

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let d = formatter.date(from: trimmed) { return d }

        // Current UI format
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        if let d = formatter.date(from: trimmed) { return d }

        return nil
    }
}

struct ProfileSetupView: View {
    @Binding var userName: String
    @Binding var phoneNumber: String?
    @Binding var emailAddress: String
    @Binding var dateOfBirth: String
    @Binding var selectedGender: Gender
    @Binding var selectedCity: Int
    @Binding var isSetupComplete: Bool
    @Binding var emailErrorMessage: String?
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var selectedImage: UIImage?
    @Binding var showDatePicker: Bool
    @Binding var showCityPicker: Bool
    @Binding var selectedDate: Date
    var isUpdateProfile: Bool = false
    let cities: [String]

    private var isCitySelected: Bool {
        selectedCity >= 0 && selectedCity < cities.count
    }

    private var cityButtonTitle: String {
        isCitySelected ? cities[selectedCity] : "Select your city"
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack{
                // Profile Image Section
                ZStack(alignment: .bottomTrailing) {
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    } else {
                        Image("profile-icon")
                           .resizable()
                           .scaledToFill()
                           .frame(width: 90, height: 90)
                           .clipShape(Circle())
                    }
                    
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Circle()
                            .fill(.black)
                            .frame(width: 25, height: 25)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 1)
                            )
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    
                            )
                    }
                    .offset(x: -3, y: -3)
                }
                .onChange(of: selectedItem) {
                    Task {
                        if let data = try? await selectedItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            selectedImage = image
                            validateFields()
                        }
                    }
                }
                
            }
            
            VStack(spacing: 15) {
                if phoneNumber != nil && !isUpdateProfile {
                    // Phone Number Field
                    FormField(
                        title: "Phone Number",
                        placeholder: "+212 1234 567 890",
                        text: Binding(
                            get: { phoneNumber ?? "" },
                            set: { phoneNumber = $0 }
                        ),
                        icon: "mobile_icon"
                    )
                    .disabled(true)
//                    .onChange(of: phoneNumber) {
//                        validateFields()
//                    }
                }
                // Full Name Field
                FormField(
                    title: "Full Name",
                    placeholder: "Enter your Full name",
                    text: $userName,
                    icon: "username_icon"
                )
                .onChange(of: userName) {
                    validateFields()
                }
                
                
                // Email Field
                FormField(
                    title: "Email Address",
                    placeholder: "Enter your email address (Optional)",
                    text: $emailAddress,
                    icon: "email_icon",
                    errorMessage: emailErrorMessage
                )
                .onChange(of: emailAddress) {
                    validateFields()
                }
                
                // Date of Birth Field
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("Date of Birth")
                            .font(.poppins(.medium, size: 12))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 5)
                    
                    Button(action: {
                        showDatePicker = true
                    }) {
                        HStack(spacing: 8) {
                            Image( "dob_icon")
                                .frame(width: 25, height: 25)
                                .foregroundColor(.gray)
                            
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
                
                // Gender Selection
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
                
                // City Selection
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("City")
                            .font(.poppins(.medium, size: 12))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 5)
                    
                    Button(action: {
                        showCityPicker = true
                    }) {
                        HStack(spacing: 8) {
                            Text(cityButtonTitle)
                                .font(.poppins(.regular, size: 14))
                                .foregroundColor(selectedCity == -1 ? Color.black.opacity(0.4) : .black)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .frame(width: 20, height: 20)
                                .foregroundColor(.gray)
                        }
                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
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
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerPopup(
                selectedDate: $selectedDate,
                dateOfBirth: $dateOfBirth,
                isPresented: $showDatePicker
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.hidden)
        }
        .sheet(isPresented: $showCityPicker) {
            PickerPopup(
                title: "Select City",
                currentSelected: $selectedCity,
                list: cities,
                isPresented: $showCityPicker
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func validateFields() {
        // Validate name or phone based on which is displayed
        let isNameOrPhoneValid: Bool
        if phoneNumber != nil {
            isNameOrPhoneValid = !(phoneNumber ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        } else {
            isNameOrPhoneValid = userName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
        }

        // Validate profile picture is uploaded
        let isProfilePictureUploaded = selectedImage != nil

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

        // Required fields for update profile
        let isDOBValid = !dateOfBirth.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let isCityValid = selectedCity >= 0 && selectedCity < cities.count

        // Enable button only if required fields are filled and email is either empty or valid
        isSetupComplete = isNameOrPhoneValid && isProfilePictureUploaded && isDOBValid && isCityValid && (emailAddress.isEmpty || isEmailValid)
    }
}

import SwiftUI

struct FormField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var icon: String? = nil
    var errorMessage: String? = nil
    var isMultiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(title)
                    .font(.poppins(.medium, size: 12))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 5)
            
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(icon)
                        .frame(width: 25, height: 25)
                        .foregroundColor(.gray)
                }
                if isMultiline {
                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text(placeholder)
                                .font(.poppins(.regular, size: 14))
                                .foregroundColor(Color.black.opacity(0.4))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $text)
                            .font(.poppins(.regular, size: 14))
                            .frame(height: 80) // ~3 lines
                            .padding(4)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .font(.poppins(.regular, size: 14))
                }
            }
            .padding(10)
            .frame(height: isMultiline ? 90 : 50)
            .background(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorMessage != nil ? .red : Color.black.opacity(0.2), lineWidth: 0.5)
            )
            .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.poppins(.regular, size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 5)
            }
        }
    }
}

struct DatePickerPopup: View {
    @Binding var selectedDate: Date
    @Binding var dateOfBirth: String
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                Text("Date of Birth")
                    .font(.poppins(.semiBold, size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button("Done") {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    dateOfBirth = formatter.string(from: selectedDate)
                    isPresented = false
                }
                .foregroundColor(.hezzniGreen)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            DatePicker("", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.white)
    }
}


#Preview {
    CompleteProfile()
}
