//
//  TaxiRideWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/21/25.
//

import SwiftUI

struct TaxiRideWelcomeScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    
    var body: some View {
        VStack(spacing: -14) {
            ServiceWelcomeScreen(
                image: "taxi-service-background",
                title: "Your Taxi, Anytime!",
                bodyContent: "Traditional taxi service with modern convenience. Book licensed taxis instantly through the Hezzni app",
                onGetStarted: {
                    // Handle get started action
                }
            )
        }
        .onAppear {
            navigationState.hideBottomBar()
        }
    }
}

#Preview {
    TaxiRideWelcomeScreen()
}
