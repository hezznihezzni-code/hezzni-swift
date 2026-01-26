//
//  CityRideWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/21/25.
//

import SwiftUI

struct CityRideWelcomeScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    
    var body: some View {
        VStack(spacing: -14) {
            ServiceWelcomeScreen(
                image: "city-service-background",
                title: "Go Further with Hezzni",
                bodyContent: "Explore the city with reliable and comfortable rides. Hezzni connects you with trusted drivers for all your urban travel needs",
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
    CityRideWelcomeScreen()
}
