//
//  OnBoardingDriver.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/4/25.
//

import SwiftUI

struct OnBoardingDriver: View {
    var phoneNumber: String
    @State private var showError: Bool = false
    @State private var selectedError: ErrorType? = nil
    @State private var showBasicInfoScreen: Bool = false
    @State var currentTab = 0
    
    var body: some View {
        VStack {
            OnBoardingDriverView(
                image: "get_onboard",
                title: "Let's Get You Onboard",
                bodyContent: "Rent vehicles by hour or day. Enjoy the freedom of having your own wheels with Hezzni's convenient rental service",
                onGetStarted: {
                    selectedError = .driverVerification
                    showError = true
                }
            )
        }
        .sheet(isPresented: $showError, onDismiss: { selectedError = nil }) {
            if let error = selectedError {
                ErrorSheet(
                    imageName: error.imageName,
                    title: error.title,
                    message: error.message,
                    buttonText: error.buttonText,
                    onButtonTap: {
                        showBasicInfoScreen = true
                        showError = false
                    },
                    onClose: { showError = false },
                    extraView: nil
                )
                .presentationDragIndicator(.hidden)
            }
            
        }
        
        .onChange(of: selectedError) { _, newValue in
            showError = newValue != nil
        }
        
        .navigationDestination(isPresented: $showBasicInfoScreen){
            BasicInfo(
                phoneNumber: phoneNumber,
                totalTabs: 5,
                currentTab: $currentTab,
                onNext: {},
                onBack: {
                    if currentTab > 0 {
                        currentTab -= 1
                    }
                }
            )
            .navigationBarBackButtonHidden(true)
        }
    }
    
}

struct OnBoardingDriverView : View {
    let image: String
    let title: String
    let bodyContent: String
    let onGetStarted: () -> Void
    
    var body: some View {
        VStack (alignment: .center, spacing: 0){
            Spacer(minLength: 90)
            
//            // Background image
            ZStack(alignment: .top){
                
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding()
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
            
                Spacer()
                // Bottom content section
            VStack(spacing:24) {
//                Image("hezzni-logo")
//                    .resizable()
//                    .frame(width: 110.0, height: 40)
//                    .padding(.top, 10)
                    VStack(spacing:4) {
                        HStack(){
                            Spacer()
                            Text(title)
                                .font(Font.custom("Poppins", size: 22).weight(.semibold))
                                .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                            Spacer()
                        }
                        
                        HStack{
                            Spacer()
                            Text(bodyContent)
                                .font(Font.custom("Poppins", size: 13))
                                .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 11)
                
                    // Buttons section
                    VStack(spacing: 16) {
                        
                        
                        // Create Account Button
                        PrimaryButton(text:"Get Started", action: onGetStarted)
                        Spacer()
                        TermsCaption()
                            
                    }
                    .padding(.horizontal, 16)
                    
                }
                
                .background(
                    Color.white
                )
            
        }
    }
}


//#Preview {
//    OnBoardingDriver()
//}
