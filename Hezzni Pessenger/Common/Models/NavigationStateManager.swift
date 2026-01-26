//
//  NavigationStateManager.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/21/25.
//

import SwiftUI
internal import Combine

class NavigationStateManager: ObservableObject {
    @Published var isBottomBarVisible: Bool = true
    @Published var path = NavigationPath()
        
        
        func navigateToSchedulePicker() {
            path.append(NavigationRoutes.schedulePicker)
        }
        
        func navigateToReservationDetail() {
            path.append(NavigationRoutes.reservationDetail)
        }
        
        func navigateToNotificationScreen() {
            path.append(NavigationRoutes.notificationScreen)
        }
        
        func popToRoot() {
            path.removeLast(path.count)
        }
    func hideBottomBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isBottomBarVisible = false
        }
    }
    
    func showBottomBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isBottomBarVisible = true
        }
    }
}

enum NavigationRoutes: Hashable {
    case schedulePicker
    case reservationDetail
    case notificationScreen // Added for NotificationScreen navigation
}
