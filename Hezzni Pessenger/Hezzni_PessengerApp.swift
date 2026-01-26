//
//  Hezzni_PessengerApp.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/9/25.
//

import SwiftUI

@main
struct Hezzni_PessengerApp: App {
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
