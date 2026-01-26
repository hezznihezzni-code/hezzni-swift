//
//  VerifiedScreen.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/8/25.
//
import SwiftUI

struct VerifiedScreen : View {
    var body: some View {
        VStack(spacing: 24){
            Image("verified")
            VStack(spacing: 6){
                Text("Verification Successful")
                    .font(.poppins(.semiBold, size: 24))
                Text("Your account is verified. Let’s get started!")
                    .font(.poppins(.regular, size: 18))
                    .foregroundStyle(.black500)
            }
            PrimaryButton(text: "Get Started", isEnabled: true, action: {
                //TODO Action
            })
        }
        .padding(16)
    }
}

#Preview {
    VerifiedScreen()
}
