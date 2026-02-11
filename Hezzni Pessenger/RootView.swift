//
//  RootView.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/11/26.
//

import SwiftUI

struct RootView: View {
    @StateObject private var navigationState = NavigationStateManager()
    @State private var isCheckingUser = true
    @State private var hasExistingUser = false
    
    var body: some View {
        Group {
            if isCheckingUser {
                // Loading/Splash screen while checking
                SplashView()
            } else if hasExistingUser {
                // User exists, show welcome back screen
                OnboardingAgainScreen()
                    .environmentObject(navigationState)
                    .navigationBarBackButtonHidden(true)
            } else {
                // No user, show regular onboarding
                OnboardingView()
                    .environmentObject(navigationState)
                    .navigationBarBackButtonHidden(true)
            }
        }
        .onAppear {
            checkForExistingUser()
        }
    }
    
    private func checkForExistingUser() {
        // Simulate a brief check (you can remove delay if not needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            hasExistingUser = AppUserType.shared.hasLoggedInUser()
            isCheckingUser = false
        }
    }
}

// Simple splash view while checking
struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(1.5)
        }
    }
}
