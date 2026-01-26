//
//  RentalRideWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/21/25.
//

import SwiftUI

struct RentalRideWelcomeScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    
    var body: some View {
        VStack(spacing: -14) {
            ServiceWelcomeScreen(
                image: "rental-service-background",
                title: "Join Our Passenger Community",
                bodyContent: "Rent vehicles by hour or day. Enjoy the freedom of having your own wheels with Hezzni's convenient rental service",
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
    RentalRideWelcomeScreen()
}
