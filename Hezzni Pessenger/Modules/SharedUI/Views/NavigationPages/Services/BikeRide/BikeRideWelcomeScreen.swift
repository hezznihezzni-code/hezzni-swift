//
//  BikeRideWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/11/25.
//

import SwiftUI

struct BikeRideWelcomeScreen : View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    var body: some View {
        VStack (spacing: -14){
            ServiceWelcomeScreen(image: "bike-ride-background", title: "Your Trusted Motorcycle Ride", bodyContent: "Fast and safe motorcycle rides with trusted drivers, Hezzni gets you where you need to go quick and easy", onGetStarted: {
                
            })
            
        }
        .onAppear{
            navigationState.hideBottomBar()
        }
    }
}


#Preview {
    BikeRideWelcomeScreen()
}
