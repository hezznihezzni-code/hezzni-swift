//
//  Hezzni_DriverApp.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 12/2/25.
//

import SwiftUI
import GoogleMaps

@main
struct Hezzni_DriverApp: App {
    @State var currentTab = 0
    @StateObject var navigationState = NavigationStateManager()
    
    init() {
            GMSServices.provideAPIKey("AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0")
        }
    var body: some Scene {
        
        WindowGroup {
//            BasicInfo(
//                totalTabs: 5,
//                currentTab: $currentTab,
//                onNext: {},
//                onBack: {
//                    if currentTab > 0 {
//                        currentTab -= 1
//                    }
//                }
//            )
            OnboardingView()
                .environmentObject(navigationState)
        }
    }
}
//How to use it
//AppUserType.shared.userType // .driver or .passenger
class AppUserType {
    static let shared = AppUserType()
    let userType: UserType
    private init() {
        self.userType = .driver
    }
}
