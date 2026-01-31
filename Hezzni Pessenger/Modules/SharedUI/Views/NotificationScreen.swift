//
//  NotificationScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/24/25.
//

import SwiftUI

struct NotificationScreen: View {
    @Binding var showNotification: Bool
    @EnvironmentObject private var navigationState: NavigationStateManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            CustomAppBar(
                title: "Notifications", backButtonAction: {
                    navigationState.showBottomBar()
                    showNotification = !showNotification
                    
                }
            )
                .padding(.horizontal, 16)
                
            ScrollView {
                VStack(spacing: 20) {
                    // Today Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Today")
                            .font(Font.custom("Poppins", size: 11).weight(.medium))
                            .foregroundColor(Color.black.opacity(0.5))
                        VStack(alignment: .leading, spacing: 0) {
                            NotificationItem(
                                iconBg: Color(red: 1, green: 0.76, blue: 0.03).opacity(0.20),
                                icon: Image(systemName: "exclamationmark.triangle.fill"),
                                iconColor: Color(red: 1, green: 0.76, blue: 0.03),
                                title: "Safety Check",
                                time: "Just Now",
                                timeColor: Color(red: 0.25, green: 0.76, blue: 0.38),
                                message: "Unusual delay detected. Are you okay?",
                                showDot: true
                            )
                            NotificationItem(
                                iconBg: Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.20),
                                icon: Image(systemName: "bubble.left.fill"),
                                iconColor: Color(red: 0.22, green: 0.65, blue: 0.33),
                                title: "Message from Driver",
                                time: "Just Now",
                                timeColor: Color(red: 0.25, green: 0.76, blue: 0.38),
                                message: "Abdelali: I’m outside the blue building",
                                showDot: true
                            )
                            NotificationItem(
                                iconBg: Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.20),
                                icon: Image(systemName: "checkmark.circle.fill"),
                                iconColor: Color(red: 0.22, green: 0.65, blue: 0.33),
                                title: "Trip Completed",
                                time: "5 hour ago",
                                timeColor: Color.gray,
                                message: "You've arrived. Thanks for riding with Hezzni!",
                                showDot: false
                            )
                        }
                    }
                    // Yesterday Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Yesterday")
                            .font(Font.custom("Poppins", size: 11).weight(.medium))
                            .foregroundColor(Color.black.opacity(0.5))
                        VStack(alignment: .leading, spacing: 0) {
                            NotificationItem(
                                iconBg: Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.20),
                                icon: Image(systemName: "arrowtriangle.up.circle.fill"),
                                iconColor: Color(red: 0.22, green: 0.65, blue: 0.33),
                                title: "Trip Started",
                                time: "5 hour ago",
                                timeColor: Color.gray,
                                message: "Your trip with Mohamed has started. Enjoy...",
                                showDot: false
                            )
                            NotificationItem(
                                iconBg: Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.20),
                                icon: Image(systemName: "location.circle.fill"),
                                iconColor: Color(red: 0.22, green: 0.65, blue: 0.33),
                                title: "Driver Arrived",
                                time: "5 hour ago",
                                timeColor: Color.gray,
                                message: "Your driver has arrived — please head to...",
                                showDot: false
                            )
                            NotificationItem(
                                iconBg: Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.20),
                                icon: Image(systemName: "person.crop.circle.fill.badge.checkmark"),
                                iconColor: Color(red: 0.22, green: 0.65, blue: 0.33),
                                title: "Ride Accepted",
                                time: "5 hour ago",
                                timeColor: Color.gray,
                                message: "Driver found and on the way",
                                showDot: false
                            )
                            NotificationItem(
                                iconBg: Color(red: 0.83, green: 0.18, blue: 0.18).opacity(0.20),
                                icon: Image(systemName: "nosign"),
                                iconColor: Color(red: 0.83, green: 0.18, blue: 0.18),
                                title: "Ride Canceled",
                                time: "6 hour ago",
                                timeColor: Color.gray,
                                message: "Unfortunately, your driver canceled the ride.",
                                showDot: false
                            )
                        }
                    }
                    // 5 October 2025 Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("5 October 2025")
                            .font(Font.custom("Poppins", size: 11).weight(.medium))
                            .foregroundColor(Color.black.opacity(0.5))
                        VStack(alignment: .leading, spacing: 0) {
                            NotificationItem(
                                iconBg: Color(red: 1, green: 0.76, blue: 0.03).opacity(0.20),
                                icon: Image(systemName: "exclamationmark.triangle.fill"),
                                iconColor: Color(red: 1, green: 0.76, blue: 0.03),
                                title: "Safety Check",
                                time: "5 hour ago",
                                timeColor: Color.gray,
                                message: "Unusual delay detected. Are you okay?",
                                showDot: false
                            )
                            NotificationItem(
                                iconBg: Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.20),
                                icon: Image(systemName: "bubble.left.fill"),
                                iconColor: Color(red: 0.22, green: 0.65, blue: 0.33),
                                title: "Message from Driver",
                                time: "5 hour ago",
                                timeColor: Color.gray,
                                message: "Abdelali: Thank you for the tip",
                                showDot: false
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarHidden(true)
//        .padding(.top, 44)
//        .ignoresSafeArea(.container, edges: .top)
    }
}

struct NotificationItem: View {
    var iconBg: Color
    var icon: Image
    var iconColor: Color
    var title: String
    var time: String
    var timeColor: Color
    var message: String
    var showDot: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconBg)
                        .frame(width: 40, height: 40)
                        .overlay(
                            RoundedRectangle(cornerRadius: 800)
                                .inset(by: 0.40)
                                .stroke(Color(red: 0.90, green: 0.92, blue: 0.98), lineWidth: 0.40)
                        )
                    icon
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Text(title)
                            .font(Font.custom("Poppins", size: 15).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        Spacer()
                        Text(time)
                            .font(Font.custom("Poppins", size: 8).weight(.medium))
                            .foregroundColor(timeColor)
                    }
                    HStack(spacing: 10) {
                        Text(message)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.52, green: 0.52, blue: 0.52))
                        Spacer()
                        if showDot {
                            Circle()
                                .fill(Color(red: 0.25, green: 0.76, blue: 0.38))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 15)
        .overlay(
            Rectangle()
                .inset(by: 0.50)
                .stroke(Color.black.opacity(0.05), lineWidth: 0.50)
        )
    }
}

#Preview{
    NotificationScreen(showNotification: .constant(true))
}
