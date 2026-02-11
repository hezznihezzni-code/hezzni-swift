//
//  Hezzni_PessengerApp.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/9/25.
//

import SwiftUI
import GoogleMaps

@main
struct Hezzni_PassengerApp: App {
    
    init() {
        GMSServices.provideAPIKey("AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0")
        // Set user type to passenger
        AppUserType.shared.userType = .passenger
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
class AppUserType {
    static let shared = AppUserType()
    var userType: UserType
    
    private init() {
        // Default to passenger, but this can be determined from UserDefaults
        self.userType = .passenger
    }
    
    func getCurrentUser() -> Any? {
        switch userType {
        case .driver:
            return UserDefaults.standard.getDriverUser()
        case .passenger:
            return UserDefaults.standard.getUser()
        }
    }
    
    func hasLoggedInUser() -> Bool {
        return getCurrentUser() != nil
    }
}
