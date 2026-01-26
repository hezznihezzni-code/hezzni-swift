//
//  HistoryScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/22/25.
//
import SwiftUI

struct Trip: Identifiable {
    let id = UUID()
    let userName: String
    let date: String
    let rating: Double
    let status: TripStatus
    let fare: String
    let pickup: String
    let destination: String
    var reviewGiven: String? = nil
    var reviewReceived: String? = nil
}

enum TripStatus {
    case completed, cancelled
    var text: String {
        switch self {
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        }
    }
    var color: Color {
        switch self {
        case .completed: return Color.green
        case .cancelled: return Color.red
        }
    }
}

struct HistoryScreen: View {
    @State private var selectedTab: String = "All"
    @State private var selectedTrip: Trip? = nil // Track selected trip for bottom sheet
    let tabs = ["All", "Completed", "Cancelled"]
    let trips: [Trip] = [
        Trip(userName: "Ahmed Hassan", date: "3 Jun, 2025 at 12:00 PM", rating: 5.0, status: .completed, fare: "24 MAD", pickup: "Current Location, Marrakech", destination: "Current Location, Marrakech"),
        Trip(userName: "Ahmed Hassan", date: "3 Jun, 2025 at 12:00 PM", rating: 5.0, status: .cancelled, fare: "24 MAD", pickup: "Current Location, Marrakech", destination: "Current Location, Marrakech"),
        Trip(userName: "Ahmed Hassan", date: "3 Jun, 2025 at 12:00 PM", rating: 5.0, status: .completed, fare: "24 MAD", pickup: "Current Location, Marrakech", destination: "Current Location, Marrakech")
    ]
    var body: some View {
        VStack(spacing: 0) {
            CustomAppBar(title: "Trips History", backButtonAction: {})
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
            ScrollView {
                VStack(spacing: 16) {
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
                    // Filter Tabs (segmented style)
                    HStack(spacing: 0) {
                        ForEach(tabs, id: \.self) { tab in
                            FilterTabPill(title: tab, isSelected: selectedTab == tab)
                                .onTapGesture { selectedTab = tab }
                        }
                    }
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
                    // Trip Cards
                    VStack(spacing: 16) {
                        ForEach(trips.filter { selectedTab == "All" || $0.status.text == selectedTab }) { trip in
                            TripHistoryCard(trip: trip)
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
        .navigationBarBackButtonHidden()
    }
}

struct SummaryCardGreen: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Gradient background similar to design
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.22, green: 0.65, blue: 0.33),
                            Color(red: 0.12, green: 0.46, blue: 0.25)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 120)
//                .overlay(
//                    ZStack {
//                        Circle()
//                            .fill(Color.white.opacity(0.10))
//                            .frame(width: 120, height: 120)
//                            .offset(x: 60, y: -60)
//                        Circle()
//                            .fill(Color.white.opacity(0.12))
//                            .frame(width: 72, height: 72)
//                            .offset(x: -8, y: 8)
//                    }, alignment: .topTrailing
//                )
            ZStack(alignment: .topTrailing){
                ZStack {
                    Circle().fill(Color.white.opacity(0.18)).frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(iconColor)
                }
                .padding(8)
                VStack(alignment: .leading, spacing: 6) {
                    
                    Spacer()
                    HStack(alignment: .center) {
                        Text(value)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        
                    }
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(16)
            }
            
        }
    }
}

struct FilterTabPill: View {
    let title: String
    let isSelected: Bool
    var body: some View {
        Text(title)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isSelected ? .black : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(isSelected ? Color.white : Color.clear)
            .cornerRadius(14)
            .shadow(color: isSelected ? Color.black.opacity(0.06) : .clear, radius: 2, y: 1)
    }
}

struct TripHistoryCard: View {
    let trip: Trip
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Rating + status (only show rating for non-cancelled trips)
            if trip.status != .cancelled{
                HStack(alignment: .center) {
                    if trip.status != .cancelled {
                        HStack(spacing: 2) {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.yellow)
                            }
                            Text(String(format: "%.1f", trip.rating))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                        }
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
                    HStack(spacing: 6) {
                        Text(trip.fare.split(separator: " ").first.map(String.init) ?? trip.fare)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        Text(trip.fare.split(separator: " ").last.map(String.init) ?? "")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .textCase(.uppercase)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            } else {
                HStack(alignment: .center) {
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
                    StatusBadge(status: trip.status)
                }
            }
            
            VStack(spacing: 0){
                LocationCardView(
                    imageName: "pickup_ellipse",
                    heading: "Pickup",
                    content: "Current Location, Marrakech",
                    onTap: {},
                    roundedEdges: .top
                )
                LocationCardView(
                    imageName: "dropoff_ellipse",
                    heading: "Destination",
                    content: "Menara Mall, Gueliz District",
                    roundedEdges: .bottom
                )
            }
            .overlay(
                Line()
                .stroke(
                    Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.25),
                    style: StrokeStyle(
                        lineWidth: 2,
                        dash: [5,5]
                    )
                )
                .frame(height: 50)
                .offset(x: 28)
                ,alignment: .leading
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.06), radius: 10, y: 2)
    }
}

struct StatusBadge: View {
    let status: TripStatus
    var body: some View {
        HStack(spacing: 10) {
            Text(status.text)
                .font(Font.custom("Poppins", size: 9).weight(.medium))
                .foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
        .cornerRadius(100)
//        Text(status.text)
//            .font(.system(size: 14, weight: .medium))
//            .foregroundColor(.white)
//            .padding(.horizontal, 16)
//            .padding(.vertical, 6)
//            .background(status.color)
//            .cornerRadius(18)
    }
}


#Preview {
    HistoryScreen()
}
