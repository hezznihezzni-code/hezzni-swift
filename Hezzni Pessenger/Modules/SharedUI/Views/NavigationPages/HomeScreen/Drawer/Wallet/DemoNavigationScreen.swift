//
//  DemoNavigationScreen.swift
//  Hezzni Driver
//
//  Demo screen to navigate to all screens
//

import SwiftUI

struct DemoNavigationScreen: View {
    @State private var showEarnings = false
    @State private var showWalletHome = false
    @State private var showWalletHistory = false
    @State private var showVehicleDetails = false
    @State private var showVehicleChange = false
    @State private var showInviteFriends = false
    @State private var showHelpSupport = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Hezzni Driver")
                        .font(Font.custom("Poppins", size: 28).weight(.bold))
                        .foregroundColor(.hezzniGreen)
                        .padding(.top, 20)
                    
                    Text("Screen Demo")
                        .font(Font.custom("Poppins", size: 16))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 12) {
                        DemoSectionHeader(title: "Wallet & Earnings")
                        
                        DemoNavigationButton(
                            icon: "chart.bar.fill",
                            title: "Earnings Screen",
                            subtitle: "View earnings, stats, and withdraw funds",
                            color: .hezzniGreen
                        ) {
                            showEarnings = true
                        }
                        
                        DemoNavigationButton(
                            icon: "wallet.pass.fill",
                            title: "Wallet Home",
                            subtitle: "Wallet balance and quick actions",
                            color: .hezzniGreen
                        ) {
                            showWalletHome = true
                        }
                        
                        DemoNavigationButton(
                            icon: "clock.arrow.circlepath",
                            title: "Wallet History",
                            subtitle: "Transaction history with filters",
                            color: .hezzniGreen
                        ) {
                            showWalletHistory = true
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        DemoSectionHeader(title: "Vehicle Management")
                        
                        DemoNavigationButton(
                            icon: "car.fill",
                            title: "Vehicle Details",
                            subtitle: "View registered vehicle info",
                            color: .blue
                        ) {
                            showVehicleDetails = true
                        }
                        
                        DemoNavigationButton(
                            icon: "doc.text.fill",
                            title: "Vehicle Change Request",
                            subtitle: "Upload documents to change vehicle",
                            color: .blue
                        ) {
                            showVehicleChange = true
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    VStack(spacing: 12) {
                        DemoSectionHeader(title: "Account & Support")
                        
                        DemoNavigationButton(
                            icon: "person.2.fill",
                            title: "Invite Friends",
                            subtitle: "Refer and earn rewards",
                            color: .orange
                        ) {
                            showInviteFriends = true
                        }
                        
                        DemoNavigationButton(
                            icon: "questionmark.circle.fill",
                            title: "Help & Support",
                            subtitle: "Chat with support, get help",
                            color: .purple
                        ) {
                            showHelpSupport = true
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .navigationDestination(isPresented: $showEarnings) {
                EarningsScreen()
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showWalletHome) {
                WalletHomeScreen()
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showWalletHistory) {
                WalletHistoryScreen()
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showVehicleDetails) {
                VehicleDetailsScreen()
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showVehicleChange) {
                VehicleChangeScreen()
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showInviteFriends) {
                InviteFriendsScreen()
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $showHelpSupport) {
                HelpSupportScreen()
                    .navigationBarHidden(true)
            }
        }
    }
}

struct DemoSectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(Font.custom("Poppins", size: 14).weight(.semibold))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
            Spacer()
        }
        .padding(.top, 16)
    }
}

struct DemoNavigationButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                    
                    Text(subtitle)
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DemoNavigationScreen()
}
