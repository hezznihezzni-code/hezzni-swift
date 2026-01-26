//
//  AirportRideWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/21/25.
//

import SwiftUI

struct AirportRideWelcomeScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    
    var body: some View {
        VStack(spacing: -14) {
            ServiceWelcomeScreen(
                image: "airport-service-background",
                title: "Getting to the Airport is Easy with Hezzni",
                bodyContent: "Reliable airport rides with flight tracking. Never miss a flight with Hezzni's punctual airport transfer service",
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
    AirportRideWelcomeScreen()
}
