//
//  ServiceWelcomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/11/25.
//

import SwiftUI

struct ServiceWelcomeScreen : View {
    let image: String
    let title: String
    let bodyContent: String
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack (spacing: -14){
//            // Background image
            ZStack(alignment: .top){
                
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
//                HStack{
//                    Button(action: {
//                        
//                    }){
//                        Image(systemName: "arrow.left")
//                            .foregroundStyle(.white)
//                    }
//                    Spacer()
//                }.padding(36)
            }
                
                // Bottom content section
            VStack(spacing:24) {
//                Image("hezzni-logo")
//                    .resizable()
//                    .frame(width: 110.0, height: 40)
//                    .padding(.top, 10)
                    VStack(alignment: .leading, spacing:16) {
                        HStack{
                            Text(title)
                                .font(.poppins(.semiBold, size: 32))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        
                        HStack{
                            Text(bodyContent)
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#161616"))
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    // Buttons section
                    VStack(spacing: 16) {
                        TermsCaption()
                        
                        // Create Account Button
                        PrimaryButton(text:"Get Started", action: onGetStarted)
                        
                        
                            
                    }
                    .padding(.horizontal, 16)
                    
                }
                .padding(.bottom, 34)
                .background(
                    Color.white
                )
            
        }
    }
}


#Preview {
    ServiceWelcomeScreen(
        image: "bike-ride-background",
        title: "Your Trusted Ride",
        bodyContent: "Fast and safe motorcycle ride",
        onGetStarted: {}
    )
}
