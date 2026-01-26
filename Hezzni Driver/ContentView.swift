//
//  ContentView.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 12/2/25.
//

import SwiftUI
//import GoogleMaps

struct ContentView: View {
    @StateObject private var navigationState = NavigationStateManager()
//    init() {
//            GMSServices.provideAPIKey("AIzaSyCKQRNFJSSSsLlVW2dDwT1E91iTX_9yf1w")
//        }
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .environmentObject(navigationState)
    }
}

#Preview {
    ContentView()
}
