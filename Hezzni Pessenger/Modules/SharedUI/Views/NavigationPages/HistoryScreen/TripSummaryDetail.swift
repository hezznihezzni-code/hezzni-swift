//
//  TripSummaryDetail.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/22/25.
//

import SwiftUI

struct TripSummaryDetail: View {
    let trip: Trip
    var reservationID: String = "HZ646067"
    var carInfo: String = "8 | أ | 26363"
    var carModel: String = "Toyota HR-V"
    var carColor: String = "White"
    var carType: String = "STANDARD"
    var carImage: String = "personal_car1"
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Top bar with title, date, and close button
                HStack {
                    Spacer()
                    Text("Trip Summary")
                        .font(Font.custom("Poppins", size: 18).weight(.medium))
                        .lineSpacing(28.80)
                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.80))
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal)
                Text("3 Jun, 2025 at 12:00 PM")
                    .font(Font.custom("Poppins", size: 10))
                    .lineSpacing(13)
                    .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                    .padding(.bottom, 8)
                
                // Driver Info Section
                ReviewProfileCard(person: Person(
                    id: "C-0003",
                    name: "Ahmed Hassan",
                    phoneNumber: "+212 666 666 6666",
                    rating: 4.8,
                    tripCount: 2847,
                    imageUrl: "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
                ))
                
                // Car Info Card
                CarInfoSection(
                    carInfo: carInfo,
                    carModel: carModel,
                    carColor: carColor,
                    carType: carType,
                    carImage: carImage,
                    id: "C-0003"
                )
                .padding(.horizontal, 16)

                // Trip Stats
                TripStatsView(distance: "1.3 km", totalTime: "11 min", price: "74 MAD")
                    .padding(.horizontal)
                    .padding(.top, 8)

                PickupDestinationPathView(pickupLocation: "Current Location, Marrakech", destinationLocation: "Current Location, Marrakech", offsetX: 22, cornerRadius: 10)
                    .padding(.horizontal, 16)
                
                .padding(.top, 8)

                // Rating Given
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating Given")
                        .font(.headline)
                        .padding(.bottom, 2)
                    Divider()
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        Text("5.0")
                            .font(.headline)
                    }
                    Text("The ride was smooth and comfortable. The driver was polite, the car was clean, and pickup was on time. Overall, a great experience!")
                        .font(.body)
                        .foregroundColor(.primary)
                    HStack {
                        TagView(text: "On time pickup")
                        TagView(text: "Clean Car")
                        TagView(text: "Safe Driving")
                    }
                }
                .padding(16)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.50)
                .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
                )
                .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.06), radius: 35, y: 4
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)

                // Rating Received
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating Received")
                        .font(.headline)
                        .padding(.bottom, 2)
                    Divider()
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                        Text("5.0")
                            .font(.headline)
                    }
                    Text("The ride was smooth and comfortable. The driver was polite, the car was clean, and pickup was on time. Overall, a great experience!")
                        .font(.body)
                        .foregroundColor(.primary)
                    HStack {
                        TagView(text: "On time pickup")
                        TagView(text: "Clean Car")
                        TagView(text: "Safe Driving")
                    }
                }
                .padding(16)
                .background(.white)
                .cornerRadius(10)
                .overlay(
                RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.50)
                .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
                )
                .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.06), radius: 35, y: 4
                )
                .padding(.top, 8)
                .padding(.horizontal, 16)

                // Download Receipt Button
                Button(action: {
                    // Download receipt action
                }) {
                    HStack {
                        Image(systemName: "arrow.down.to.line")
                        Text("Download Receipt")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.hezzniGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
        }
    }
}

// TagView for rating tags
struct TagView: View {
    let text: String
    var body: some View {
        Text(text)
            .lineLimit(1)
            .font(Font.custom("Poppins", size: 10).weight(.medium))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.hezzniGreen)
            .cornerRadius(8)
    }
}

#Preview{
    TripSummaryDetail(trip: Trip(userName: "Ahmed Hassan", date: "3 Jun, 2025 at 12:00 PM", rating: 5.0, status: .completed, fare: "24 MAD", pickup: "Current Location, Marrakech", destination: "Current Location, Marrakech"))
}
