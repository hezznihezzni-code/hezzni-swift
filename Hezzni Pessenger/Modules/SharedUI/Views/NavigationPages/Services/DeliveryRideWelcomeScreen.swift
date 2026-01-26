//
//  DeliveryRideWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/21/25.
//

import SwiftUI

struct DeliveryRideWelcomeScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    
    var body: some View {
        VStack(spacing: -14) {
            ServiceWelcomeScreen(
                image: "delivery-service-background",
                title: "Fast and Secure Delivery with Hezzni",
                bodyContent: "Send packages and documents across town. Hezzni's delivery service ensures your items reach safely and on time",
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
    DeliveryRideWelcomeScreen()
}
