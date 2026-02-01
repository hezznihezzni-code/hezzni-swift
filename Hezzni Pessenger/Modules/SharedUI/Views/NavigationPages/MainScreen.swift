//
//  MainScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/17/25.
//

import SwiftUI

struct MainScreen: View {
    @State private var selectedTab: BottomNavigationBar.Tab = .home
    @EnvironmentObject private var navigationState: NavigationStateManager
    
    //---------- Components For Home Screen ----------------///
    @State var selectedService: String = "Car"
    @State var isNowSelected: Bool = true
    @State var pickupLocation: String = "From?"
    @State var destinationLocation: String = "Where To?"
    
    @State private var bottomSheetState: BottomSheetState = .initial
    
    var body: some View {
        NavigationView {
            ZStack {
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .home:
                        HomeScreen(
                            selectedService: $selectedService,
                            isNowSelected: $isNowSelected,
                            pickupLocation: $pickupLocation,
                            destinationLocation: $destinationLocation,
                            bottomSheetState: $bottomSheetState
                        )
                    case .services:
                        ServicesHome(
                            selectedTab: $selectedTab,
                            selectedService: $selectedService,
                            isNowSelected: $isNowSelected,
                            pickupLocation: $pickupLocation,
                            destinationLocation: $destinationLocation,
                            bottomSheetState: $bottomSheetState
                        )
                    case .history:
                        HistoryScreen()
                    case .chat:
                        ChatScreen()
                    case .account:
                        AccountScreen()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                if navigationState.isBottomBarVisible {
                    VStack {
                        Spacer()
                        BottomNavigationBar(selectedTab: $selectedTab)
                    }
                    .transition(.move(edge: .bottom))
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .navigationBarHidden(true)
        }
        .animation(.interactiveSpring(duration: 0.3), value: navigationState.isBottomBarVisible)
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
    
    private func applyDarkMode(_ enabled: Bool) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let window = windowScene.windows.first {
                window.overrideUserInterfaceStyle = enabled ? .dark : .light
            }
        }
    }
}



#Preview {
    MainScreen()
        .environmentObject(NavigationStateManager())
}
