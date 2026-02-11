import SwiftUI

struct OnboardingView: View {
    @State private var showCreateAccount = false
    @StateObject private var navigationState = NavigationStateManager()
    @State private var showRootView = false
    
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
                        Text("Join Our \(AppUserType.shared.userType == .driver ? "Driver": "Passenger") Community")
                            .font(.poppins(.semiBold, size: 32))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                        
                        Text("Become part of our expanding network of drivers. Earn on your own schedule and unlock exclusive rewards.")
                            .font(.system(size: 14))
                            .foregroundColor(.black500)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    // Buttons section
                    VStack(spacing: 16) {
                        // Create Account Button
                        PrimaryButton(text:"Create New Account", action: {
                            // Navigate to Create Account screen with animation
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showCreateAccount = true
                            }
                        })
                        
                        // Sign In button
                        Button(action: {
                            // Navigate to Create Account screen with animation
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if AppUserType.shared.hasLoggedInUser() {
                                    showRootView = true
                                }
                                else {
                                    showCreateAccount = true
                                }
                            }
                        }) {
                            Text("Sign In")
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
                        
                        TermsCaption()
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 34)
                .background(Color.white)
            }
            .navigationDestination(isPresented: $showCreateAccount) {
                CreateAccountScreen()
                    .transition(.move(edge: .trailing)) // Slide in from right
            }
            .navigationDestination(isPresented: $showRootView) {
                RootView()
                    .transition(.move(edge: .trailing)) // Slide in from right
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Ensures proper stack behavior
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
