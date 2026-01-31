//
//  ContentView.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/6/25.
//

import SwiftUI
import GoogleMaps

struct ContentView: View {
    @StateObject private var navigationState = NavigationStateManager()
        
    init() {
            GMSServices.provideAPIKey("AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0")
        }
    var body: some View {
        OnboardingView()
            .environmentObject(navigationState)
            
    }
}

#Preview {
    ContentView()
}
