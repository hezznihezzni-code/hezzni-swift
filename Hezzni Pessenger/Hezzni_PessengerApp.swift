//
//  Hezzni_PessengerApp.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/9/25.
//

import SwiftUI
import GoogleMaps

@main
struct Hezzni_PessengerApp: App {
    init() {
            GMSServices.provideAPIKey("AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0")
        }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppUserType {
    static let shared = AppUserType()
    let userType: UserType
    private init() {
        self.userType = .passenger
    }
}
