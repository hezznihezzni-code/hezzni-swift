//
//  RentalMainScreen.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/21/25.
//

import SwiftUI

struct RentalMainScreen: View {
    @State private var selectedTab: RentalBottomNavigationBar.Tab = .home
    @EnvironmentObject private var navigationState: NavigationStateManager
   
    
    var body: some View {
        NavigationView {
            ZStack {
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case .home:
                        RentalHome()
                    case .myVehicles:
                        MyVehiclesScreen()
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
                        RentalBottomNavigationBar(selectedTab: $selectedTab)
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
    
   
}



#Preview {
    @Previewable @StateObject var navigationState = NavigationStateManager()
    
    RentalMainScreen()
        .environmentObject(navigationState)
}
