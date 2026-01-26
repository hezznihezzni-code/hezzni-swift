//
//  OTPScreen.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/7/25.
//

import SwiftUI

struct OTPScreen: View {
    let phoneNumber: String
    @State private var otpDigits: [String] = Array(repeating: "", count: 6)
    @FocusState private var focusedField: Int?
    @State private var timerSeconds = 30
    @State private var isTimerActive = true
    @State private var showErrorAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // New state variables for error handling
    @State private var showInvalidOTP = false
    @State private var shouldShake = false
    
    @StateObject private var authController = AuthController.shared
    @Environment(\.dismiss) private var dismiss
    @StateObject private var navigationState = NavigationStateManager()
    
    var body: some View {
        NavigationStack {
            mainContent
            // Update the navigation destination to check registration status
            .navigationDestination(isPresented: $authController.shouldNavigateToNextScreen) {
                if authController.isUserRegistered() {
                    // User is already registered, go to main screen
                    if AppUserType.shared.userType == .passenger {
                        MainScreen()
                            .navigationBarBackButtonHidden(true)
                    } else {
                        if authController.isServiceTypeExists(){
                            DriverHomeComplete()
                                .navigationBarBackButtonHidden(true)
                        }
                        else {
                            OnBoardingDriver(phoneNumber: phoneNumber)
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                    
                } else {
                    // User needs to complete registration
                    if AppUserType.shared.userType == .passenger{
                        CompleteProfile()
                            .navigationBarBackButtonHidden(true)
                    } else {
                        OnBoardingDriver(phoneNumber: phoneNumber)
                            .navigationBarBackButtonHidden(true)
                    }
                }
            }
                .alert(alertTitle, isPresented: $showErrorAlert) {
                    Button("Try Again", role: .cancel) {
                        // Clear error after dismissal
                        authController.errorMessage = nil
                    }
                } message: {
                    Text(alertMessage)
                        .font(.poppins(.regular, size: 16))
                }
                .onChange(of: authController.errorMessage) { _, errorMessage in
                    if let errorMessage = errorMessage {
                        if errorMessage.lowercased().contains("invalid otp") {
                            handleInvalidOTP()
                        } else {
                            showUserFriendlyAlert(errorMessage)
                        }
                    }
                }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = 0
            }
            startTimer()
        }
        .onDisappear {
            authController.resetState()
        }
    }
    
    private var mainContent: some View {
        VStack {
            
            headerSection
            
            otpInputSection
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image("phone_verify_background")
                .resizable()
                .frame(width: 270, height: 270)
            
            Text("Verify Your Number")
                .font(.poppins(.semiBold, size: 24))
                .foregroundColor(.primary)
            
            VStack(spacing: 0){
                Text("We sent a 6-digit code to \(phoneNumber).")
                    .font(.poppins(.regular, size: 13))
                    .foregroundStyle(.black500)

                Text("Please check your WhatsApp for the code.")
                    .font(.poppins(.regular, size: 13))
                    .foregroundStyle(.black500)
            }
        }
        .padding(.top, 40)
    }
    
    private var otpInputSection: some View {
        VStack(spacing: 30) {
            otpFields
            if showInvalidOTP {
                Text("Incorrect code. Please try again.")
                    .foregroundStyle(Color(hex: "#D32F2F"))
                
            }
            resendSection
            verifyButtonSection
            
        }
    }
    
    private var otpFields: some View {
        VStack(spacing: 0){
            HStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { index in
                    OTPTextField(
                        text: $otpDigits[index],
                        isFocused: focusedField == index,
                        onCommit: {
                            if index < 6 && !otpDigits[index].isEmpty {
                                focusedField = index + 1
                            } else if index == 5 && !otpDigits[index].isEmpty {
                                submitOTP()
                            }
                        },
                        onBackspace: {
                            if index > 0 && otpDigits[index].isEmpty {
                                focusedField = index - 1
                            }
                        },
                        disabled: authController.isLoading,
                        isError: showInvalidOTP // Pass error state
                    )
                    .focused($focusedField, equals: index)
                    .onChange(of: otpDigits[index]) { _, newValue in
                        handleOTPChange(at: index, newValue: newValue)
                    }
                    .modifier(ShakeEffect(animatableData: shouldShake ? 1 : 0))
                }
            }
            .padding(.top, 32)
           
            
        }
    }
    
    private var tryAgainButton: some View {
        Button(action: clearFieldsAndRetry) {
            HStack {
                Image(systemName: "arrow.clockwise")
                Text("Try Again")
                    .font(.poppins(.semiBold, size: 14))
            }
        }
        .controlSize(.large)
        .buttonStyle(.borderedProminent)
        .tint(.hezzniGreen)
        .disabled(authController.isLoading)
    }
    
    private var resendSection: some View {
        VStack(spacing: 15) {
            HStack(spacing:0){
                Text("Didn't receive the code? ")
                    .font(.poppins(.regular, size: 13))
                    .foregroundStyle(.black500)
                Text(isTimerActive ? "Resend in 0:\(timerSeconds.leadingZero)" : "Resend")
                    .font(.poppins(.medium, size: 13))
                    .foregroundStyle(.hezzniGreen)
                    .onTapGesture {
                        if !isTimerActive {
                            resendCode()
                        }
                    }
            }
        }
    }
    
    private var verifyButtonSection: some View {
        VStack {
            PrimaryButton(
                text: "Verify",
                isEnabled: isOTPComplete && !authController.isLoading,
                isLoading: authController.isLoading,
                action: submitOTP
            )
            .disabled(!isOTPComplete || authController.isLoading)
            Spacer()
            TermsCaption()
        }
    }
}

// MARK: - Helper Methods
extension OTPScreen {
    private var isOTPComplete: Bool {
        otpDigits.allSatisfy { !$0.isEmpty }
    }
    
    private func handleOTPChange(at index: Int, newValue: String) {
        // Limit to single digit
        if newValue.count > 1 {
            otpDigits[index] = String(newValue.prefix(1))
        }
        
        // Auto-move to next field
        if !newValue.isEmpty && index < 5 {
            focusedField = index + 1
        }
        
        // Auto-submit when last digit is entered
        if index == 5 && !newValue.isEmpty {
            submitOTP()
        }
    }
    
    private func submitOTP() {
        authController.errorMessage = nil
        showInvalidOTP = false
        
        let otpCode = otpDigits.joined()
        print("OTP Submitted: \(otpCode)")
        
        Task {
            let success = await authController.verifyOTP(phoneNumber: phoneNumber, otp: otpCode)
            if !success {
                // Clear OTP fields on failure for security
                otpDigits = Array(repeating: "", count: 6)
                focusedField = 0
            }
        }
    }
    
    private func startTimer() {
        isTimerActive = true
        timerSeconds = 30
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if timerSeconds > 0 {
                timerSeconds -= 1
            } else {
                timer.invalidate()
                isTimerActive = false
            }
        }
    }
    
    private func resendCode() {
        authController.errorMessage = nil
        showInvalidOTP = false
        
        Task {
            let success = await authController.resendOTP()
            if success {
                startTimer()
                // Clear previous OTP
                otpDigits = Array(repeating: "", count: 6)
                focusedField = 0
            }
        }
    }
    
    private func handleInvalidOTP() {
        showInvalidOTP = true
        triggerHapticFeedback()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.2, blendDuration: 0.5)) {
            shouldShake = true
        }
        
        // Reset shake animation for next time
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            shouldShake = false
        }
    }
    
    private func clearFieldsAndRetry() {
        showInvalidOTP = false
        otpDigits = Array(repeating: "", count: 6)
        focusedField = 0
        authController.errorMessage = nil
    }
    
    private func triggerHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    private func showUserFriendlyAlert(_ errorMessage: String) {
        // Map specific error messages to user-friendly versions
        switch errorMessage.lowercased() {
        case let msg where msg.contains("expired"):
            alertTitle = "Code Expired"
            alertMessage = "This verification code has expired. Please request a new code."
            
        case let msg where msg.contains("too many attempts"):
            alertTitle = "Too Many Attempts"
            alertMessage = "You've entered incorrect codes too many times. Please request a new verification code."
            
        case let msg where msg.contains("not found"):
            alertTitle = "Code Not Found"
            alertMessage = "This verification code is no longer valid. Please request a new code."
            
        case let msg where msg.contains("network") || msg.contains("connection"):
            alertTitle = "Connection Issue"
            alertMessage = "Unable to connect to the server. Please check your internet connection and try again."
            
        case let msg where msg.contains("server"):
            alertTitle = "Server Error"
            alertMessage = "We're experiencing technical difficulties. Please try again in a few moments."
            
        default:
            alertTitle = "Something Went Wrong"
            alertMessage = errorMessage
        }
        
        showErrorAlert = true
    }
}

// MARK: - Shake Effect Modifier
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit),
            y: 0))
    }
}


#Preview {
    OTPScreen(phoneNumber: "+923088877196")
}



// MARK: - Updated OTPTextField with error state
struct OTPTextField: View {
    @Binding var text: String
    var isFocused: Bool
    var onCommit: () -> Void
    var onBackspace: () -> Void
    var disabled: Bool = false
    var isError: Bool = false
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .font(.poppins(.semiBold, size: 20))
            .frame(width: 50, height: 57)
            .background(createOverlay2())
            .overlay(createCursor())
            .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification)) { _ in
                if text.isEmpty {
                    onBackspace()
                }
            }
            
            .disabled(disabled)
    }
    
    private func createOverlay() -> some View {
        Group{
            if isFocused || !text.isEmpty {
                RoundedRectangle(cornerRadius: 9)
                    .stroke(isError ? Color.red : Color.hezzniGreen, lineWidth: isFocused ? 2 : 1)
                    .fill(.white)
                    .frame(width: 61, height: 70)
                    
            }
        }
    }
    
    private func createOverlay2() -> some View {
        Group{
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isError ? Color.red :
                    (isFocused || !text.isEmpty ? Color.hezzniGreen : Color.gray),
                    lineWidth: isFocused ? 3 : 2
                )
                .fill(.white)
                .shadow(
                    color: isFocused || !text.isEmpty ? isError ? Color.red : .hezzniGreen.opacity(0.2) : Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 20, y: 4
                )
        }
    }
    
    private func createCursor() -> some View {
        Group {
            if isFocused && text.isEmpty {
                Rectangle()
                    .fill(isError ? Color.red : Color.hezzniGreen)
                    .frame(width: 2, height: 20)
                    .opacity(0.6)
            }
        }
    }
}


// MARK: - Message Views
struct ErrorMessageView: View {
    let message: String?
    
    var body: some View {
        if let message = message {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
                Text(message)
                    .font(.poppins(.regular, size: 14))
                    .foregroundColor(.red)
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}

struct SuccessMessageView: View {
    let message: String?
    
    var body: some View {
        if let message = message {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(message)
                    .font(.poppins(.regular, size: 14))
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
        }
    }
}

// MARK: - Timer/Resend View
struct ResendView: View {
    let isTimerActive: Bool
    let timerSeconds: Int
    let isLoading: Bool
    let onResend: () -> Void
    
    var body: some View {
        VStack {
            if isTimerActive {
                timerView
            } else {
                resendButton
            }
        }
    }
    
    private var timerView: some View {
        Group {
            Text("Resend available in")
                .font(.poppins(.regular, size: 14))
            Text("0:\(timerSeconds.leadingZero)")
                .font(.poppins(.semiBold, size: 24))
                .foregroundColor(.white950)
        }
    }
    
    private var resendButton: some View {
        Button(action: onResend) {
            HStack {
                Image(systemName: "arrow.trianglehead.counterclockwise.rotate.90")
                Text("Resend Code")
                    .font(.poppins(.semiBold, size: 14))
            }
        }
        .controlSize(.large)
        .buttonStyle(.borderedProminent)
        .tint(.hezzniGreen)
        .disabled(isLoading)
    }
}

// MARK: - Header View
struct OTPHeaderView: View {
    let phoneNumber: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image("otp-verify-logo")
                .resizable()
                .frame(width: 78, height: 78)
            
            Text("Enter verification code")
                .font(.poppins(.semiBold, size: 24))
            
            Text("We sent a 6-digit code to")
                .font(.poppins(.regular, size: 16))
                .foregroundStyle(.black500)
            
            Text(phoneNumber)
                .font(.poppins(.medium, size: 18))
                .foregroundStyle(.hezzniGreen)
        }
        .padding(.top, 40)
    }
}

// MARK: - WhatsApp Info View
struct WhatsAppInfoView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Check WhatsApp")
                .font(.poppins(.semiBold, size: 16))
            Text("This verification code was sent to your WhatsApp messages.")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.poppins(.regular, size: 14))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 10)
//                .stroke(.white200, lineWidth: 0.0)
                .shadow(color: Color(hex: "#04060F").opacity(0.06), radius: 50)
                .foregroundStyle(.white)
                
                
        )
    }
}
