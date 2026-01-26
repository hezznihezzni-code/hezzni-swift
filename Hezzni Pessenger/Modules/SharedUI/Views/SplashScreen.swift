//
//  SplashScreen.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/6/25.
//
import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack{
            Image("hezzni-logo")
                .resizable()
                .frame(width: 200.0, height: 80)
        }
    }
}

#Preview {
    SplashScreen()
}
