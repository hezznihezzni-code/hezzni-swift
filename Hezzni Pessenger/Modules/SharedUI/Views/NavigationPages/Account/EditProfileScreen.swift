////
////  EditProfileScreen.swift
////  Hezzni Pessenger
////
////  Created by Zohaib Ahmed on 9/27/25.
////
//
//import SwiftUI
//import _PhotosUI_SwiftUI
//
//struct EditProfileScreen : View {
//    @State private var isSetupComplete: Bool = false
//    @State private var selectedItem: PhotosPickerItem?
//    @State private var selectedImage: UIImage?
//    
//    // Personal Details Form States
//    @State private var userName: String = ""
//    @State private var emailAddress: String = ""
//    @State private var emailErrorMessage: String?
//    @State private var isEmailVerified = false
//    @State private var selectedCountry = Country.morocco
//    @State private var showCountryPicker = false
//    @State private var phoneNumber = ""
//    @State private var errorMessage: String?
//    @State private var isPhoneNumberValid = false
//    @State private var showValidation = false
//    @State private var selectedGender: Gender = .none
//    @State private var birthDate = Date()
//    
//    enum Gender: String, CaseIterable {
//        case none = ""
//        case male = "Male"
//        case female = "Female"
//    }
//    
//    private let dateFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd"
//        return formatter
//    }()
//    
//    var body: some View {
//        ZStack{
//            VStack{
//                CustomAppBar(title: "Profile")
//                    .padding(.horizontal, 16)
//                ScrollView{
//                    VStack(spacing: 16){
//                        // Profile Picture Card
//                        ZStack() {
//                            VStack(spacing: 12) {
//                                ZStack(alignment: .bottomTrailing) {
//                                    if let selectedImage = selectedImage {
//                                        Image(uiImage: selectedImage)
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 74, height: 74)
//                                            .clipShape(Circle())
//                                    } else {
//                                        Image("profile-icon")
//                                            .resizable()
//                                            .scaledToFill()
//                                            .frame(width: 74, height: 74)
//                                            .clipShape(Circle())
//                                    }
//                                    
//                                    PhotosPicker(selection: $selectedItem, matching: .images) {
//                                        Image(systemName: "camera.fill")
//                                            .foregroundColor(Color(hex:"#3C3C3C"))
//                                            .padding(8)
//                                            .clipShape(Circle())
//                                            .background(
//                                                Circle()
//                                                    .foregroundStyle(.white)
//                                            )
//                                    }
//                                    .offset(x: 5, y: 5)
//                                }
//                                .onChange(of: selectedItem) { newItem in
//                                    Task {
//                                        if let data = try? await newItem?.loadTransferable(type: Data.self),
//                                           let image = UIImage(data: data) {
//                                            selectedImage = image
//                                            validateFields()
//                                        }
//                                    }
//                                }
//                                
//                                Text("Upload Picture")
//                                    .font(.poppins(.medium, size: 14))
//                                    .foregroundColor(.black500)
//                            }
//                            .padding(.top, 40)
//                            .padding(.bottom, 40)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .background(.white)
//                        .cornerRadius(16)
//                        .padding(.horizontal, 16)
//                        .shadow(
//                            color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.05), radius: 30, y: 4
//                        )
//                        
//                        // Personal Details Card
//                        ZStack() {
//                            VStack(alignment: .leading, spacing: 16) {
//                                // Header
//                                HStack {
//                                    Text("Personal Details")
//                                        .font(.poppins(.medium, size: 16))
//                                        .foregroundColor(.black)
//                                    Spacer()
//                                }
//                                
//                                // Full Name Field
//                                VStack(alignment: .leading, spacing: 8) {
//                                    Text("Full Name")
//                                        .font(.poppins(.medium, size: 14))
//                                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
//                                    
//                                    VStack(alignment: .leading, spacing: 5) {
//                                        HStack {
//                                            Image("person_circled_icon")
//                                                .foregroundColor(.hezzniGreen)
//                                                .frame(width: 20)
//                                            TextField("Enter your full name", text: $userName)
//                                        }
//                                        
//                                        Divider()
//                                            .frame(height: 1)
//                                            .background(.blackwhite)
//                                    }
//                                    .onChange(of: userName) { _ in
//                                        validateFields()
//                                    }
//                                }
//                                
//                                VStack(alignment: .leading, spacing: 8) {
//                                    Text("Email Address")
//                                        .font(.poppins(.medium, size: 14))
//                                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
//                                    
//                                    VStack(alignment: .leading, spacing: 20) {
//                                        VStack(alignment: .leading, spacing: 5) {
//                                            HStack {
//                                                Image(systemName: "envelope")
//                                                    .foregroundColor(.hezzniGreen)
//                                                    .frame(width: 20)
//                                                TextField("Enter your email address", text: $emailAddress)
//                                            }
//                                            
//                                            Divider()
//                                                .frame(height: 1)
//                                                .background(emailErrorMessage != nil ? Color.red : .blackwhite)
//                                        }
//                                        
//                                        if let errorMessage = emailErrorMessage {
//                                            HStack {
//                                                Text(errorMessage)
//                                                    .font(.poppins(.regular, size: 14))
//                                                    .foregroundColor(.red)
//                                            }
//                                        }
//                                    }
//                                    .onChange(of: emailAddress) { _ in
//                                        validateFields()
//                                    }
//                                }
//                                
//                                // Phone Number Field (Read-only as it's verified)
////                                VStack(alignment: .leading, spacing: 8) {
////                                    Text("Phone Number")
////                                        .font(.poppins(.medium, size: 14))
////                                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
////                                    
////                                    
////                                    // Phone input section
////                                    VStack(alignment: .leading, spacing: 16) {
////                                        // Phone input field
////                                        VStack(alignment: .leading, spacing: 5) {
////                                            HStack(alignment: .center) {
////                                                // Country code picker
////                                                Button {
////                                                    showCountryPicker = true
////                                                } label: {
////                                                    HStack(spacing: 8) {
////                                                        Text(selectedCountry.flag)
////                                                            .font(.title3)
////                                                        Image(systemName: "arrowtriangle.down.fill")
////                                                            .font(.system(size: 12, weight: .medium))
////                                                            .foregroundColor(.gray)
////                                                        
////                                                        Text(selectedCountry.dialCode)
////                                                            .font(.poppins(.medium, size: 14))
////                                                            .foregroundColor(.primary)
////                                                            .padding(.leading, 8)
////                                                    }
////                                                }
////                                                .frame(width: 100)
////                                                Divider()
////                                                    .frame(width: 2, height: 16)
////                                                    .overlay(.green)
////                                                    .foregroundStyle(.black500)
////                                                
////                                                // Phone number text field
////                                                HStack{
////                                                    TextField("1234567890", text: $phoneNumber)
////                                                        .keyboardType(.numberPad)
////                                                        .font(.poppins(.regular, size: 16))
////                                                        .onChange(of: phoneNumber) { _ in
////                                                            showValidation = true
////                                                            validatePhoneNumber()
////                                                        }
////                                                    Image(isPhoneNumberValid ? "verified_small" : "not_verified")
////                                                        .foregroundStyle(.green)
////                                                        .imageScale(.small)
////                                                        .opacity(!phoneNumber.isEmpty ? 1.0 : 0.0)
////                                                        
////                                                }
////                                            }
////                                            Divider()
////                                                .frame(height: 1)
////                                                .background(isPhoneNumberValid || phoneNumber.isEmpty ? .blackwhite : Color.red)
////                                            
////                                            // Error message
////                                            if let errorMessage = errorMessage {
////                                                HStack(spacing: 4) {
////                                                    Image(systemName: "exclamationmark.triangle.fill")
////                                                        .foregroundColor(.red)
////                                                        .font(.system(size: 12))
////                                                    Text(errorMessage)
////                                                        .font(.poppins(.regular, size: 12))
////                                                        .foregroundColor(.red)
////                                                }
////                                            }
////                                            
////                                            
////                                        }
////                                        // Validation message
////                                        if showValidation && errorMessage == nil {
////                                            if isPhoneNumberValid {
////                                                HStack(spacing: 4) {
////                                                    Image(systemName: "checkmark.circle.fill")
////                                                        .foregroundColor(.green)
////                                                        .font(.system(size: 14))
////                                                    Text("Valid phone number")
////                                                        .font(.poppins(.regular, size: 14))
////                                                        .foregroundColor(.green)
////                                                    Spacer()
////                                                    Button("Verify Now"){
////                                                        
////                                                    }
////                                                    .font(Font.custom("Poppins", size: 14).weight(.medium))
////                                                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
////                                                }
////                                            } else if !phoneNumber.isEmpty {
////                                                HStack(spacing: 4) {
////                                                    Image(systemName: "exclamationmark.triangle.fill")
////                                                        .foregroundColor(.red)
////                                                        .font(.system(size: 14))
////                                                    Text(selectedCountry.placeholder)
////                                                        .font(.poppins(.regular, size: 14))
////                                                        .foregroundColor(.red)
////                                                }
////                                            }
////                                        }
////                                    }
////                                    .frame(maxWidth: .infinity, alignment: .leading)
////                                }
//                                
//                                // Date of Birth Field with Embedded Wheel Picker
//                                VStack(alignment: .leading, spacing: 16) {
//                                    Text("Date of Birth")
//                                        .font(.poppins(.medium, size: 14))
//                                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
//                                    
//                                    // Embedded Wheel Date Picker
//                                    VStack {
//                                        DatePicker("", selection: $birthDate, in: ...Date(), displayedComponents: .date)
//                                            .datePickerStyle(WheelDatePickerStyle())
//                                            .labelsHidden()
//                                            .frame(height: 100)
//                                            .padding(.horizontal, -10)
//                                            .onChange(of: birthDate) { _ in
//                                                validateFields()
//                                            }
//                                        
////                                        // Display selected date
////                                        Text("Selected: \(dateFormatter.string(from: birthDate))")
////                                            .font(.poppins(.regular, size: 14))
////                                            .foregroundColor(.gray)
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                    .padding(.vertical, 16)
//                                }
//                                
//                                // Gender Selection as Rectangle Tabs
//                                VStack(alignment: .leading, spacing: 8) {
//                                    Text("What's your gender, male or female?")
//                                        .font(.poppins(.medium, size: 18))
//                                        .foregroundColor(.black)
//                                    
//                                    HStack(spacing: 8) {
//                                        // Male Button
//                                        Button(action: {
//                                            selectedGender = .male
//                                            validateFields()
//                                        }) {
//                                            Text("Male")
//                                                .font(.poppins(.medium, size: 18))
//                                                .foregroundColor(selectedGender == .male ? .white : Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
//                                                .frame(maxWidth: .infinity)
//                                                .frame(height: 56)
//                                        }
//                                        
//                                        .background(selectedGender == .male ? Color.hezzniGreen : Color(red: 0.96, green: 0.96, blue: 0.96))
//                                        .cornerRadius(8)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .inset(by: 0.50)
//                                                .stroke(selectedGender == .male ? .white : Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
//                                        )
//                                        
//                                        // Female Button
//                                        Button(action: {
//                                            selectedGender = .female
//                                            validateFields()
//                                        }) {
//                                            Text("Female")
//                                                .font(.poppins(.medium, size: 18))
//                                                .foregroundColor(selectedGender == .female ? .white : Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
//                                                .frame(height: 56)
//                                                .frame(maxWidth: .infinity)
//                                        }
//                                        
//                                        
//                                        .background(selectedGender == .female ? Color.hezzniGreen : Color(red: 0.96, green: 0.96, blue: 0.96))
//                                        .cornerRadius(8)
//                                        .overlay(
//                                            RoundedRectangle(cornerRadius: 8)
//                                                .inset(by: 0.50)
//                                                .stroke(selectedGender == .female ? .white : Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
//                                        )
//                                    }
//                                }
//                            }
//                            .padding(16)
//                        }
//                        .frame(maxWidth: .infinity)
//                        .background(.white)
//                        .cornerRadius(8)
//                        .padding(.horizontal, 16)
//                        .shadow(
//                            color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.05), radius: 50, y: 4
//                        )
//                        ProfileLocationView()
//                        PrimaryButton(text: "Save Changes", isEnabled: true, action: {
//                            
//                        })
//                        Spacer()
//                            .frame(height: 30)
//                    }
//                }
//                Spacer()
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//    
//    private func validatePhoneNumber() {
//        let pattern = selectedCountry.pattern
//        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
//        isPhoneNumberValid = predicate.evaluate(with: phoneNumber)
//        errorMessage = nil
//    }
//    
//    private func validateFields() {
//        let isProfilePictureUploaded = selectedImage != nil
//        let isNameValid = !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//        let isEmailValid = emailAddress.isEmpty || isValidEmail(emailAddress)
//        let isGenderSelected = selectedGender != .none
//        
//        isSetupComplete = isProfilePictureUploaded && isNameValid && isEmailValid && isGenderSelected
//    }
//    
//    private func isValidEmail(_ email: String) -> Bool {
//        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
//        return emailPredicate.evaluate(with: email)
//    }
//}
//
//#Preview {
//    EditProfileScreen()
//}
//
//
//extension LocationDataService {
//    func fetchCountriesFromAPI() async {
//        guard let url = URL(string: "https://restcountries.com/v3.1/all") else { return }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            let countryDTOs = try JSONDecoder().decode([CountryDTO].self, from: data)
//            
//            await MainActor.run {
//                self.countries = countryDTOs.map { $0.toCountry() }
//            }
//        } catch {
//            print("Error fetching countries: \(error)")
//        }
//    }
//}
//
//// DTO for API response
//struct CountryDTO: Codable {
//    let cca2: String
//    let name: Name
//    let idd: Idd
//    
//    struct Name: Codable {
//        let common: String
//    }
//    
//    struct Idd: Codable {
//        let root: String
//        let suffixes: [String]?
//    }
//    
//    func toCountry() -> Country {
//        return Country(
//            code: cca2,
//            name: name.common,
//            flag: countryFlag(isoCode: cca2),
//            dialCode: idd.root + (idd.suffixes?.first ?? ""),
//            pattern: "^\\d{8,15}$", // Generic pattern
//            placeholder: "Enter your phone number"
//        )
//    }
//    
//    private func countryFlag(isoCode: String) -> String {
//        let base: UInt32 = 127397
//        var flag = ""
//        for scalar in isoCode.unicodeScalars {
//            flag.unicodeScalars.append(UnicodeScalar(base + scalar.value)!)
//        }
//        return String(flag)
//    }
//}
