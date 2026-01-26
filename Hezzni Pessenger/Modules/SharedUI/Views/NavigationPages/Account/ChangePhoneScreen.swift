//
//  ChangePhoneScreen.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/7/25.
//

import SwiftUI
import FlagsKit

struct ChangePhoneScreen: View {
    var onBack: (() -> Void)? = nil
    @State private var selectedCountry = Country.morocco
    @State private var phoneNumber = ""
    @State private var isPhoneNumberValid = false
    @State private var showValidation = false
    @State private var showCountryPicker = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var navigateToOTP = false
    @State private var isImageVisible = false // New state for animation
    @State private var isPhoneFieldInvalid = false
    @StateObject private var navigationState = NavigationStateManager()
    @StateObject private var authController = AuthController.shared
    @FocusState private var isPhoneFieldFocused: Bool
    
    var body: some View {
        ZStack {
            NavigationStack {
//                .frame(minHeight: UIScreen.main.bounds.height * 0.40)
                //Following VStack must have a shadow to be visible on light background
                VStack(spacing: 35) {
                    
                    
                       
                        
                    }
                    VStack(spacing: 4){
                        VStack {
                            CustomAppBar(title: "Change Phone Number", weight: .medium, backButtonAction: {
                                onBack?()
                            })
                            .padding(.horizontal, 16)
                            
                            HStack(spacing: 80) {
                                HStack(spacing: 12) {
                                    Image("phone_icon")
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.gray)
                                    .cornerRadius(8)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Current Phone Number")
                                            .font(Font.custom("Poppins", size: 11))
                                            .lineSpacing(14)
                                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.70))
                                        Text("+212 605884449")
                                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                                            .lineSpacing(16)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: 207)
                                    Spacer()
                                }
                            }
                            .padding(12)
                            .background(.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
                            )
                        Image("change_phone_no")
                            .resizable()
                            .frame(width: 274, height: 274)
                            .opacity(isImageVisible ? 1 : 0)
                            .scaleEffect(isImageVisible ? 1 : 0.5)
                            .animation(.interpolatingSpring(mass: 1.0, stiffness: 100.0, damping: 10, initialVelocity: 0)
                                .delay(0.2), value: isImageVisible)
                        Text("Get started with Hezzni")
                            .font(.poppins(.semiBold, size: 22))
                            .padding(.top, 16)
                        Text("Enter your phone number to continue. We’ll send you a one-time code to verify your number.")
                            .font(.poppins(.regular, size: 13))
                            .foregroundStyle(.black500)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 16)
                    }
                    
                    VStack(spacing: 30){
                        // Phone input section
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                // Flag in colored circle
                                ZStack {
                                    
                                    FlagView(countryCode: selectedCountry.code, style: .circle)
                                        .frame(width: 22, height: 22)
                                }
//                                .frame(width: 32, height: 32)
                                
                                // Country code and chevron
                                Button {
                                    showCountryPicker = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(selectedCountry.dialCode)
                                            .font(.custom("Poppins", size: 14))
                                            .foregroundColor(.black)
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(minWidth: 40)
                                
                                // Divider
                                Rectangle()
                                    .frame(width: 1, height: 56)
                                    .foregroundColor(Color.black.opacity(0.1))
                                    .padding(.horizontal, 4)
                                
                                // Phone number text field
                                ZStack(alignment: .leading) {
                                    if phoneNumber.isEmpty {
                                        Text(selectedCountry.phonePlaceholder)
                                            .font(.custom("Poppins", size: 16))
                                            .foregroundColor(Color.black.opacity(0.4))
                                    }
                                    TextField("", text: $phoneNumber)
                                        .keyboardType(.numberPad)
                                        .font(.custom("Poppins", size: 16))
                                        .foregroundColor(.black)
                                        .focused($isPhoneFieldFocused)
                                        .onChange(of: phoneNumber) { _ in
                                            validatePhoneNumber()
                                            validatePhoneFirstDigit()
                                        }
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 4)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.50)
                                    .stroke(isPhoneFieldInvalid ? Color.red : (isPhoneFieldFocused ? Color.black : Color.black.opacity(0.2)), lineWidth: 0.50)
                            )
                            .shadow(
                            color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.006), radius: 50, y: 4
                            )
                            
                            // Helper text
                            if isPhoneFieldInvalid {
                                Text("Invalid phone number")
                                    .font(.custom("Poppins", size: 12))
                                    .foregroundColor(.red)
                                    .padding(.leading, 5)
                            } else {
                                Text(selectedCountry.placeholder)
                                    .font(.custom("Poppins", size: 12))
                                    .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                                    .padding(.leading, 5)
                            }
                        }
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        PrimaryButton(
                            text: "Continue",
                            isEnabled: isPhoneNumberValid && !isLoading,
                            isLoading: isLoading,
                            action: {
                                handleContinue()
                            }
                        )
                    }
                    Spacer()
                    
                    
                        
                        
                        TermsCaption()
                    
                    
                    
                }
                .padding(.horizontal, 16)
                .background(.white)
                .onChange(of: selectedCountry) { _ in
                    validatePhoneNumber()
                    showValidation = true
                    errorMessage = nil
                }
                .navigationDestination(isPresented: $navigateToOTP) {
                    OTPScreen(phoneNumber: selectedCountry.dialCode + phoneNumber)
                        .transition(.opacity)
                }
                .onAppear {
                    // Trigger the animation when the view appears
                    withAnimation {
                        isImageVisible = true
                    }
                }
            }
            
            // iOS Default Picker Sheet
            if showCountryPicker {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showCountryPicker = false
                    }
                
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Button("Cancel") {
                                showCountryPicker = false
                            }
                            .foregroundColor(.blue)
                            .font(.body)
                            
                            Spacer()
                            
                            Text("Select Country")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Done") {
                                showCountryPicker = false
                            }
                            .foregroundColor(.blue)
                            .font(.body)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        
                        // Picker
                        Picker("Select Country", selection: $selectedCountry) {
                            ForEach(Country.countries) { country in
                                HStack {
                                    FlagView(countryCode: country.code, style: .circle)
                                        .frame(width: 22, height: 22)
                                        
                                    Text(country.name)
                                    Spacer()
                                    Text(country.dialCode)
                                        .foregroundColor(.gray)
                                }
                                .tag(country)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 200)
                        .background(Color.white)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .transition(.move(edge: .bottom))
                .zIndex(2)
            }
        }
    }
    
    private func validatePhoneNumber() {
        let pattern = selectedCountry.pattern
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        isPhoneNumberValid = predicate.evaluate(with: phoneNumber)
        errorMessage = nil
    }
    
    private func validatePhoneFirstDigit() {
        // Extract first digit pattern from selectedCountry.pattern
        // Examples: ^[6-7]\d{8}$, ^3\d{9}$, ^\d{10}$
        let pattern = selectedCountry.pattern
        var validFirstDigits: [Character] = []
        if let match = pattern.range(of: "\\^\\[([0-9])-?([0-9])?\\]", options: .regularExpression) {
            let range = pattern[match]
            let digits = range.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
            validFirstDigits = Array(digits)
        } else if let match = pattern.range(of: "\\^([0-9])", options: .regularExpression) {
            let digit = pattern[match].replacingOccurrences(of: "^", with: "")
            validFirstDigits = [Character(digit)]
        }
        if !validFirstDigits.isEmpty, let first = phoneNumber.first {
            isPhoneFieldInvalid = !validFirstDigits.contains(first)
        } else {
            isPhoneFieldInvalid = false
        }
        // If phone number is empty, do not show error
        if phoneNumber.isEmpty { isPhoneFieldInvalid = false }
    }
    
    private func handleContinue() {
        errorMessage = nil
        let fullNumber = selectedCountry.dialCode + phoneNumber
        
        Task {
            isLoading = true
            let success = await authController.sendOTP(phoneNumber: fullNumber)
            
            await MainActor.run {
                isLoading = false
                if success {
                    navigateToOTP = true
                } else {
                    errorMessage = authController.errorMessage
                }
            }
        }
    }
}

#Preview {
    ChangePhoneScreen()
}
