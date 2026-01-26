//
//  GroupRideWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/21/25.
//

import SwiftUI

struct GroupRideWelcomeScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    
    var body: some View {
        VStack(spacing: -14) {
            ServiceWelcomeScreen(
                image: "shared-service-background",
                title: "Ride Together, Save Together",
                bodyContent: "Perfect for groups and events. Share rides with friends and split costs easily with Hezzni's group ride feature",
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
    GroupRideWelcomeScreen()
}
