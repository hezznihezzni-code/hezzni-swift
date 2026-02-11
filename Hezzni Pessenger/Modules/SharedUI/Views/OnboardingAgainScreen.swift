//
//  OnboardingAgainScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/15/25.
//
import SwiftUI

struct OnboardingAgainScreen: View {
    @State private var showCreateAccount = false
    @State private var loginUserIfExist = false
    @StateObject private var navigationState = NavigationStateManager()
    @State private var phoneNumber: String = ""
    @StateObject private var authController = AuthController.shared
    
    var body: some View {
        NavigationStack {
            VStack (spacing: -14){
                // Background image
                Image("onboarding-background-image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    
                // Bottom content section
                VStack(spacing:32) {
                    VStack(alignment: .leading, spacing:16) {
                        Text("Welcome back!")
                            .font(.poppins(.semiBold, size: 32))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        HStack{
                            Text("Wherever you’re going Hezzni is here for you")
                                .font(.system(size: 14))
                                .foregroundColor(Color("onboarding-text-color"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                            Spacer()
                        }.frame(maxWidth: .infinity)
                    }
                    .padding(.top, 10)
                    
                    // Buttons section
                    VStack(spacing: 16) {
                        VStack{
                            // Continue with saved number
                            PrimaryButton(
                                text: "Continue with \(phoneNumber)",
                                action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        // Navigate to main app
                                        loginUserIfExist = true
                                    }
                                }
                            )
                            // Sign In button
                            Button(action: {
                                // Navigate to Create Account screen with animation
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showCreateAccount = true
                                }
                            }) {
                                Text("Use other phone number")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        
                        TermsCaption()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .background(Color.white)
            }
            .navigationDestination(isPresented: $showCreateAccount) {
                OnboardingView()
                            .navigationBarBackButtonHidden(true)

            }
            .navigationDestination(isPresented: $loginUserIfExist) {
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
        }
        .onAppear {
            loadUserPhoneNumber()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func loadUserPhoneNumber() {
        if AppUserType.shared.userType == .driver {
            if let driver = UserDefaults.standard.getDriverUser() {
                phoneNumber = driver.phone ?? "+92XXXXXXXXXX"
            }
        } else {
            if let user = UserDefaults.standard.getUser() {
                phoneNumber = user.phone ?? "+92XXXXXXXXXX"
            }
        }
    }
    
}
