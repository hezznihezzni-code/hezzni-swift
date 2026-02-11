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
    
    init() {
        GMSServices.provideAPIKey("AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0")
        // Set user type to driver
        AppUserType.shared.userType = .driver
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
//How to use it
//AppUserType.shared.userType // .driver or .passenger
class AppUserType {
    static let shared = AppUserType()
    var userType: UserType
    
    private init() {
        // Default to driver, but this can be determined from UserDefaults
        self.userType = .driver
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
