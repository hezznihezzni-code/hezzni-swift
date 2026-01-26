//
//  LanguageSettingsScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/26/25.
//

import SwiftUI

struct LanguageSettingsScreen : View {
    var onBack: (() -> Void)? = nil
    @State private var selectedLanguage: String = "EN" // Default selected
    @EnvironmentObject private var navigationState: NavigationStateManager
    var body: some View {
        ZStack{
            VStack{
                CustomAppBar(title: "Language Settings", backButtonAction: {
                    onBack?()
                })
                    .padding(.horizontal, 16)
                
                ScrollView{
                    VStack{
                        Spacer()
                            .frame(height: 24)
                        HStack(spacing: 16) {
                            HStack(spacing: 11) {
                                ZStack() {
                                    VStack(spacing: 0) {
                                        Text("EN")
                                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                                    }
                                    .frame(width: 45, height: 45)
                                    .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.10))
                                    .cornerRadius(8)
                                    
                                    .offset(x: -1.50, y: 1.39)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Language")
                                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                                        .foregroundColor(.black)
                                    Text("English (US)")
                                        .font(Font.custom("Poppins", size: 13))
                                        .lineSpacing(13)
                                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.70))
                                }
                            }
                            Spacer()
                            HStack(spacing: 10) {
                                Text("current")
                                    .font(Font.custom("Poppins", size: 9).weight(.medium))
                                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                            }
                            .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.10))
                            .cornerRadius(100)
                        }
                        .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
                        .frame(height: 100)
                        .background(.white)
                        .cornerRadius(16)
                        .overlay(
                        RoundedRectangle(cornerRadius: 15)
                        .inset(by: 0.50)
                        .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 0.50)
                        )
                        .shadow(
                        color: Color(red: 0.22, green: 0.65, blue: 0.33, opacity: 0.60), radius: 4
                        )
                        .padding(.horizontal, 16)
                        
                        
                    }
                    Spacer()
                        .frame(height: 24)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Available Languages")
                            .font(.poppins(.medium, size: 16))
                            .foregroundColor(.black)
                        
                        LanguageToggleCard(
                            languageCode: "EN",
                            languageName: "English",
                            nativeName: "English (US)",
                            isSelected: selectedLanguage == "EN"
                        ) {
                            selectedLanguage = "EN"
                        }
                        
                        LanguageToggleCard(
                            languageCode: "AR",
                            languageName: "Arabic",
                            nativeName: "العربية",
                            isSelected: selectedLanguage == "AR"
                        ) {
                            selectedLanguage = "AR"
                        }
                        
                        LanguageToggleCard(
                            languageCode: "FR",
                            languageName: "French",
                            nativeName: "Français",
                            isSelected: selectedLanguage == "FR"
                        ) {
                            selectedLanguage = "FR"
                        }
                    }
                    .padding(.horizontal, 16)
                    
                }
                Spacer()
                PrimaryButton(text: "Save Changes", action: {
                    
                })
                .padding(.horizontal, 16)
            }
        }
        .onAppear{
            navigationState.hideBottomBar()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct LanguageToggleCard: View {
    let languageCode: String
    let languageName: String
    let nativeName: String
    let isSelected: Bool
    let action: () -> Void
    
    init(languageCode: String, languageName: String, nativeName: String, isSelected: Bool, action: @escaping () -> Void) {
        self.languageCode = languageCode
        self.languageName = languageName
        self.nativeName = nativeName
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Language Info
                HStack(spacing: 11) {
                    // Language Code Badge
                    ZStack {
                        VStack(spacing: 0) {
                            Text(languageCode)
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0, green: 0, blue: 0).opacity(0.60))
                        }
                        .frame(width: 45, height: 45)
                        .background(isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.10) : Color(red: 0, green: 0, blue: 0).opacity(0.05))
                        .cornerRadius(8)
                    }
                    
                    // Language Details
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageName)
                            .font(.poppins(.medium, size: 16))
                            .foregroundColor(.black)
                        Text(nativeName)
                            .font(.poppins(size: 13))
                            .foregroundColor(Color.black.opacity(0.7))
                    }
                    
                    Spacer()
                }
                
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.86, green: 0.86, blue: 0.86), lineWidth: 0.47)
                        .frame(width: 23, height: 23)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(EdgeInsets(top: 24, leading: 20, bottom: 24, trailing: 20))
            .frame(height: 100)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                !isSelected ?
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.5)
                :
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 0.50)
                    
                
            )
            .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.06), radius: 50, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview{
    LanguageSettingsScreen()
}
