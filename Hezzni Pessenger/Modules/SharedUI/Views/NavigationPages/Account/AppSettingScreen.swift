////
////  AppSettingScreen.swift
////  Hezzni Pessenger
////
////  Created by Zohaib Ahmed on 9/26/25.
////
//
//import SwiftUI
//
//struct AppSettingScreen : View {
//    @EnvironmentObject private var navigationState: NavigationStateManager
//    @State private var isDarkModeEnabled = false
//    @State private var navigateToEditProfile = false
//    
//    // Dark mode state using AppStorage to persist across app launches
//    @AppStorage("isDarkModeEnabled") private var storedDarkModeEnabled = false
//    
//    
//    
//    var body: some View {
//        
//            ZStack{
//                VStack{
//                    CustomAppBar(title: "Settings")
//                        .padding(.horizontal, 16)
//                    ScrollView{
//                        VStack{
//                            NewProfileCard(
//                                person: Person(
//                                    id: "C-0003",
//                                    name: "Zohaib Ahmed",
//                                    phoneNumber: "+212 666 666 6666",
//                                    rating: 4.8,
//                                    tripCount: 2847,
//                                    imageUrl: "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
//                                )
//                            )
//                            
//                            VStack(alignment: .leading, spacing: 16) {
//                                
//                                
//                                VStack(alignment: .leading, spacing: 12) {
//                                    
//                                    
////                                AccountListTile(
////                                    iconName: "person_icon",
////                                    title: "Personal Information",
////                                    subtitle: "Update your personal information",
////                                    includeShadow: true,
////                                    isSystemImage: false,
////                                    action: {
////                                        navigateToEditProfile = true
////                                    }
////                                )
////
//
//                                    AccountListTile(
//                                        iconName: "darkmode_icon",
//                                        title: "Dark Mode",
//                                        subtitle: "Switch app appearance",
//                                        showChevron: false,
//                                        showToggle: true,
//                                        includeShadow: true,
//                                        isSystemImage: false,
//                                        isOn: isDarkModeEnabled,
//                                        toggleAction: { newValue in
//                                            isDarkModeEnabled = newValue
//                                            storedDarkModeEnabled = newValue
//                                            toggleDarkMode(newValue)
//                                        }
//                                    )
//                                    
//                                    AccountListTile(
//                                        iconName: "globe_icon",
//                                        title: "Language & Region",
//                                        trailingText: "English (US)",
//                                        includeShadow: true,
//                                        isSystemImage: false,
//                                    )
//                                }
//                                
//                                SectionTitle(title: "Security & Privacy")
//                                
//                                VStack(alignment: .leading, spacing: 12) {
//                                    AccountListTile(
//                                        iconName: "sheild_icon",
//                                        title: "Safety Center",
//                                        subtitle: "Emergency contacts and safety features information",
//                                        includeShadow: true,
//                                        isSystemImage: false
//                                    )
//                                    
//                                    AccountListTile(
//                                        iconName: "delete_person_icon",
//                                        title: "Delete Account",
//                                        subtitle: "Delete of your account",
//                                        includeShadow: true,
//                                        isSystemImage: false
//                                    )
//                                    
//                                    
//                                }
//                            }
//                            
//                        }
//                        .padding(.horizontal, 16)
//                    }
//                }
//                
//            }
//            .onAppear {
//                navigationState.hideBottomBar()
//                // Initialize dark mode state from stored value
//                isDarkModeEnabled = storedDarkModeEnabled
//                
//            }
//            
//        
//        .navigationBarBackButtonHidden(true)
//        
//    }
//    
//    private func toggleDarkMode(_ enabled: Bool) {
//        // Update the app's color scheme
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            if let window = windowScene.windows.first {
//                window.overrideUserInterfaceStyle = enabled ? .dark : .light
//            }
//        }
//        
//        // You can also use Environment values if you have a theme manager
//        // For example, if you have a @EnvironmentObject for theme management:
//        // themeManager.isDarkMode = enabled
//    }
//    
//    
//}
//
//#Preview {
//    AppSettingScreen()
//        .environmentObject(NavigationStateManager())
//}
