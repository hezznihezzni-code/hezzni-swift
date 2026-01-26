//
//  NoDriverFoundScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/18/25.
//

import SwiftUI

struct NoDriverFoundScreen: View {
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    var onKeepSearching: () -> Void = {}
    var onGoBack: () -> Void = {}
    
    var body: some View {
        ZStack{
            Color(.black.opacity(0.3))
                .ignoresSafeArea()
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    VStack(spacing: 24) {
                        // Top image
                        Image("no_driver_background")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .padding(.top, 24)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0){
                            // Title
                            Text("No drivers nearby")
                                .font(Font.custom("Poppins", size: 20).weight(.medium))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 4)
                            // Subtitle
                            Text("We couldn’t find a ride nearby.\nPlease try again in a few minutes")
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 24)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: onKeepSearching) {
                            Text("Keep Searching")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                                .cornerRadius(12)
                        }
                        Button(action: onGoBack) {
                            Text("Go Back")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 8)
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    NoDriverFoundScreen(
        bottomSheetState: .constant(.findingRide)
    )
}
