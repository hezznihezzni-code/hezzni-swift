//
//  TripCompleteScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/28/25.
//

import SwiftUI

struct TripCompleteScreen: View {
    // Data
    var distance: String = "1.3 km"
    var totalTime: String = "11 min"
    var price: String = "74 MAD"

    var driverImage: String = "profile_placeholder"
    var driverName: String = "Ahmed Hassan"
    var driverTrips: Int = 2847
    var driverRating: Double = 4.8
    var driverID: String = "C-0003"
    var verifiedBadge: String = "verified_badge"

    var pickupLocation: String = "Current Location, Marrakech"
    var dropoffLocation: String = "Current Location, Marrakech"
    var pickupTime: String = "7:15 PM"
    var dropoffTime: String = "9:30 PM"

    // Actions
    var onRate: () -> Void = {}
    var onBookAnother: () -> Void = {}

    var body: some View {
        ScrollView{
            VStack(spacing: 18) {
                Spacer().frame(height: 24)
                
                // Top checkmark pin
                VStack(spacing: 8) {
                    ZStack {
                        // Big pin background
                        Image("location_pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 136, height: 160)
                        // If project doesn't have composite image, fallback to circle with check
                       
                    }
                    
                    Text("You Have Arrived!")
                        .font(Font.custom("Poppins", size: 22).weight(.semibold))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    Text("Thank you for riding with us.")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                }
                .padding(.top, 4)
                
                // Trip Stats
                TripStatsView(distance: "1.3 km", totalTime: "11 min", price: "74 MAD")
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // Driver card
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(driverImage)
                            .resizable()
                            .frame(width: 66, height: 66)
                            .clipShape(Circle())
                            .overlay(
                                HStack(spacing: 0) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(.yellow)
                                    Text(String(format: "%.1f", driverRating))
                                        .font(Font.custom("Poppins", size: 10).weight(.medium))
                                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 1)
                                    .offset(y: 08),
                                alignment: .bottom
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .center, spacing: 8) {
                                Text(driverName)
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                
                                Image(verifiedBadge)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                            
                            Text("(\(driverTrips) trips)")
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(Color(red: 0.45, green: 0.44, blue: 0.44))
                            
                            // ID pill
                            HStack(spacing: 6) {
                                Image("wheel_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(.white)
                                Text("ID No C-\(driverID)")
                                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.black)
                            .cornerRadius(7)
                            .padding(.top, 6)
                        }
                        Spacer()
                    }
                    .padding(12)
                }
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.92, green: 0.92, blue: 0.92).opacity(0.6), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.03), radius: 20, x: 0, y: 6)
                .padding(.horizontal, 16)
                
                // Pickup / Destination
                VStack(spacing: 8) {
                    PickupDestinationPathView(
                        pickupLocation: pickupLocation,
                        destinationLocation: dropoffLocation
                    )
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onRate) {
                        Text("Rate your ride")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    
                    Button(action: onBookAnother) {
                        Text("Book another ride")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .background(Color.white.edgesIgnoringSafeArea(.all))
        }
    }

    @ViewBuilder
    private func summaryColumn(title: String, value: String, valueColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(Font.custom("Poppins", size: 12))
                .foregroundColor(Color(red: 0.59, green: 0.59, blue: 0.59))
            Text(value)
                .font(Font.custom("Poppins", size: 18).weight(.semibold))
                .foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TripCompleteScreen()
}
