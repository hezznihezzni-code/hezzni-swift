//
//  OnboardingAgainScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/15/25.
//

import SwiftUI

struct OnboardingAgainScreen: View {
    @State private var showCreateAccount = false
    @StateObject private var navigationState = NavigationStateManager()
    
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
                            Text("Good to see you again! Ready for your next ride? ")
                                .font(.system(size: 14))
                                .foregroundColor(Color("onboarding-text-color"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                            Spacer()
                        }.frame(maxWidth: .infinity)
                    }
//                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    // Buttons section
                    VStack(spacing: 16) {
                        VStack{
                            // Create Account Button
                            PrimaryButton(text:"Continue with +923088877196", action: {
                                // Navigate to Create Account screen with animation
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showCreateAccount = true
                                }
                            })
                            
                            // Sign In button
                            Button(action: {
                                // Handle sign in action
                            }) {
                                Text("Use other phone number")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 30)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    
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
                CreateAccountScreen()
                    .transition(.move(edge: .trailing)) // Slide in from right
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures proper stack behavior
    }
}

#Preview {
    OnboardingAgainScreen()
}
