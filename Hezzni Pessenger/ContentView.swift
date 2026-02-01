//
//  ContentView.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/6/25.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var navigationState = NavigationStateManager()
        
//    init() {
//            GMSServices.provideAPIKey("AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0")
//        }
    var body: some View {
        OnboardingView()
            .environmentObject(navigationState)
//        ServiceWelcomeScreen(
//            image: "airport-service-background",
//            title: "Getting to Airport is Easy with Hezzni",
//            bodyContent: "Table airport rides with ease. Enjoy seamless booking, real-time updates, and reliable service to make your journey stress-free.",
//            onGetStarted: {}
//        )
            
    }
}

#Preview {
    ContentView()
}
