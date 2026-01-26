//
//  ReviewScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 11/5/25.
//


import SwiftUI


struct ReviewScreen: View {
    var onBack: (() -> Void)? = nil
    @State private var selectedTab: Int = 0
    @EnvironmentObject private var navigationState: NavigationStateManager
    @State private var selectedTrip: Trip? = nil // Track selected trip for bottom sheet
    
    let trips: [Trip] = [
        Trip(userName: "Ahmed Hassan", date: "3 Jun, 2025 at 12:00 PM", rating: 5.0, status: .completed, fare: "24 MAD", pickup: "Current Location, Marrakech", destination: "Current Location, Marrakech", reviewGiven: "The ride was smooth and comfortable. The driver was polite, the car was clean, and pickup was on time. Overall, a great experience!", reviewReceived: "Very polite passenger"),
        Trip(userName: "Ahmed Hassan", date: "3 Jun, 2025 at 12:00 PM", rating: 5.0, status: .cancelled, fare: "24 MAD", pickup: "Current Location, Marrakech", destination: "Current Location, Marrakech"),
        Trip(userName: "Ahmed Hassan", date: "3 Jun, 2025 at 12:00 PM", rating: 5.0, status: .completed, fare: "24 MAD", pickup: "Current Location, Marrakech", destination: "Current Location, Marrakech")
    ]
    var body: some View {
        VStack(spacing: 0) {
            CustomAppBar(title: "Reviews", backButtonAction: {
                onBack?()
            })
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
            ScrollView {
                VStack(spacing: 16) {
                    // Toggle Button
                    HStack(spacing: 0) {
                        Button(action: { selectedTab = 0 }) {
                            Text("Rating Given")
                                .font(Font.custom("Poppins", size: 13).weight(.medium))
                                .foregroundColor(selectedTab == 0 ? .black : Color(.sRGB, white: 0.36, opacity: 1))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Group {
                                        if selectedTab == 0 {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white)
                                                .shadow(color: Color(.sRGB, white: 0.9, opacity: 1), radius: 8, y: 2)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        }
                        Button(action: { selectedTab = 1 }) {
                            Text("Rating Received")
                                .font(Font.custom("Poppins", size: 13).weight(.medium))
                                .foregroundColor(selectedTab == 1 ? .black : Color(.sRGB, white: 0.36, opacity: 1))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Group {
                                        if selectedTab == 1 {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white)
                                                .shadow(color: Color(.sRGB, white: 0.9, opacity: 1), radius: 8, y: 2)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        }
                    }
                    .padding(5)
                    .background(Color(.sRGB, white: 0.97, opacity: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                    
                    // Summary Cards
                    HStack(spacing: 16) {
                        SummaryCardGreen(
                            title: "Avg Rating Given",
                            value: "4.4",
                            icon: "star.fill",
                            iconColor: .yellow
                        )
                        SummaryCardGreen(
                            title: "Total Trips",
                            value: "5",
                            icon: "map",
                            iconColor: .white
                        )
                    }
                    .padding(.horizontal, 16)
                    HStack{
                        Text("All Reviews")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    // Trip Cards
                    VStack(spacing: 16) {
                        ForEach(trips) { trip in
                            ReviewCard(trip: trip, selectedTab: selectedTab)
                                .onTapGesture {
                                    selectedTrip = trip
                                }
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .background(.white)
        // Present bottom sheet when a trip is selected
        .sheet(item: $selectedTrip) { trip in
            TripSummaryDetail(trip: trip)
        }
    }
}


struct ReviewCard: View {
    let trip: Trip
    let selectedTab: Int
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Rating + status (only show rating for non-cancelled trips)
            
                HStack(alignment: .center) {
                    
                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.yellow)
                            }
                            Text(String(format: "%.1f", trip.rating))
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.black)
                        }
                    
                    Spacer()
                    StatusBadge(status: trip.status)
                }
                // User row + fare pill
                HStack(spacing: 12) {
                    Image("profile_placeholder")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(trip.userName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                        Text(trip.date)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                }
            
            
            Text(selectedTab == 0 ? trip.reviewGiven ?? "": trip.reviewReceived ?? "")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(.black)
            HStack {
                TagView(text: "On pickup time")
                TagView(text: "Clean Car")
                TagView(text: "Safe Driving")
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 2)
    }
}

struct StatusBadge1: View {
    let status: TripStatus
    var body: some View {
        Text(status.text)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(status.color)
            .cornerRadius(18)
    }
}


#Preview {
    ReviewScreen()
}
