//
//  ReservationConfirmedScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/18/25.
//

import SwiftUI

// MARK: - Main Screen

struct ReservationConfirmedScreen: View {
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    @Binding var sheetHeight: CGFloat
    var reservationID: String = "HZ646067"
    var carInfo: String = "8 | أ | 26363"
    var carModel: String = "Toyota HR-V"
    var carColor: String = "White"
    var carType: String = "STANDARD"
    var carImage: String = "personal_car1"
    var driverName: String = "Ahmed Hassan"
    var driverTrips: Int = 2847
    var driverRating: Double = 4.8
    var pickupLocation: String = "Current Location, Marrakech"
    var destinationLocation: String = "Current Location, Marrakech"
    var pickupTime: String = "16 July, 2025 at 9:00 am"
    var onContinue: () -> Void = {}
    var onCancel: () -> Void = {}
    var onChat: () -> Void = {}
    var onCall: () -> Void = {}

    var body: some View {
        ScrollView{
            
            VStack(spacing: 15) {
                // Checkmark icon
                VStack {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.67, green: 0.85, blue: 0.72))
                            .frame(width: 120, height: 120)
                        //                    Circle()
                        //                        .fill(Color(red: 0.22, green: 0.65, blue: 0.33))
                        //                        .frame(width: 83, height: 83)
                        Image("success_tick")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 83, height: 83)
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, 15)
                // Confirmation text
                VStack(spacing: 3) {
                    Text("Reservation confirmed!")
                        .font(Font.custom("Poppins", size: 20).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    Text("Your ride has been successfully scheduled")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                }
                // Schedule Card (reuse from ReservationDetailScreen)
                ReservationScheduleCard(
                    reservationID: reservationID,
                    carInfo: carInfo,
                    carModel: carModel,
                    carColor: carColor,
                    carType: carType,
                    carImage: carImage
                )
                // Driver info reusable
                PersonDetailsWithActions(
                    profileImage: "profile_placeholder",
                    name: driverName,
                    trips: driverTrips,
                    rating: driverRating,
                    badgeImage: "verified_badge",
                    onChat: onChat,
                    onCall: onCall
                )
                // Pickup/Destination Path Cards (reuse from HomeScreen)
                PickupDestinationPathView(
                    pickupLocation: pickupLocation,
                    destinationLocation: destinationLocation
                )
                // Pickup time card
                PickupTimeCard(pickupTime: pickupTime)
                // Action buttons
                VStack(spacing: 10) {
                    Button(action: onContinue) {
                        Text("Continue to home")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .cornerRadius(8)
                    }
                    Button(action: onCancel) {
                        Text("Cancel Reservation")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.83, green: 0.18, blue: 0.18))
                            .cornerRadius(8)
                    }
                }
                .frame(width: .infinity)
            }
            .padding(.top, 15)
            .padding(.bottom, 35)
            .background(Color.white)
            .cornerRadius(24)
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Reusable Car Info Section

struct ReservationScheduleCard: View {
    var reservationID: String?
    var carInfo: String
    var carModel: String
    var carColor: String
    var carType: String
    var carImage: String

    var body: some View {
        VStack(spacing: 15) {
            if reservationID != nil {
                HStack {
                    Text("Reservation ID")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                    Spacer()
                    Text(reservationID!)
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 15)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.10), lineWidth: 0.5)
                )
            }
            
            CarInfoSection(
                carInfo: carInfo,
                carModel: carModel,
                carColor: carColor,
                carType: carType,
                carImage: carImage,
                price: 45
            )
        }
    }
}

struct CarInfoSection: View {
    var carInfo: String
    var carModel: String
    var carColor: String
    var carType: String
    var carImage: String
    var price: Double?
    var id: String?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(carInfo)
                    .font(Font.custom("Poppins", size: 16).weight(.semibold))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                HStack(spacing: 5) {
                    Text(carModel)
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 3, height: 3)
                    Text(carColor)
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                }
                if price != nil {
                    Text(String(format: "%.1f", price ?? 0) + "MAR")
                        .font(Font.custom("Poppins", size: 10).weight(.medium))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.white)
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.30), lineWidth: 0.5)
                        )
                } else if id != nil {
                    HStack(spacing: 0){
                        Image("wheel_icon")
                            .foregroundStyle(.white)
                        Text("ID NO \(id ?? "C-0000")")
                            .font(Font.custom("Poppins", size: 10).weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                    }
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2.5)
                    .background(Color.black)
                    .cornerRadius(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                            .stroke(Color.white, lineWidth: 0.5)
                    )
                    
                }
               
            }
            Spacer()
            ZStack {
                Image(carImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 107, height: 97)
                    .overlay(
                        HStack(spacing: 3){
                            Image("wheel_icon")
                                .foregroundStyle(.white)
                            Text(carType)
                                .font(Font.custom("Poppins", size: 8))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2.5)
                        .background(Color.black)
                        .cornerRadius(7)
                        .overlay(
                            RoundedRectangle(cornerRadius: 7)
                                .stroke(Color.white, lineWidth: 0.5)
                        )
                        .offset(x: 15, y: -25)
                    )
            }
        }
        .padding(EdgeInsets(top: 8, leading: 15, bottom: 8, trailing: 15))
        .background(.white)
        .cornerRadius(16)
        .overlay(
        RoundedRectangle(cornerRadius: 16)
        .inset(by: 0.50)
        .stroke(
        Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
        )
        )
        .shadow(
        color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4
        )
    }
}

// MARK: - Reusable Person Details With Buttons

struct PersonDetailsWithActions: View {
    var profileImage: String
    var name: String
    var trips: Int
    var rating: Double
    var badgeImage: String?
    var onChat: () -> Void
    var onCall: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(profileImage)
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    HStack(spacing: 0){
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(Font.custom("Poppins", size: 10).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, y: 1)
                    .offset(y: 9),
                    alignment: .bottom
                )
            VStack(alignment: .leading, spacing: 2) {
                HStack{
                    Text(name)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    if let badgeImage = badgeImage {
                        Image(badgeImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                    }
                }
                Text("(\(trips) trips)")
                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                    .foregroundColor(Color(red: 0.45, green: 0.44, blue: 0.44))
            }
            Spacer()
            HStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Button(action: onChat) {
                        Circle()
                            .fill(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image("message_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            )
                    }
                    Circle()
                        .fill(Color(red: 0.87, green: 0.95, blue: 0.89))
                        .frame(width: 16, height: 16)
                        .overlay(
                            Text("2")
                                .font(Font.custom("Poppins", size: 8).weight(.medium))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        )
                        .offset(x: 2, y: -2)
                }
                Button(action: onCall) {
                    Circle()
                        .fill(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image("call_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)
                        )
                }
            }
        }
    }
}

struct PickupDestinationPathView: View {
    var pickupLocation: String
    var destinationLocation: String
    // New optional headings with defaults to preserve existing UI where not specified
    var pickupHeading: String?
    var destinationHeading: String?
    var offsetX: CGFloat = 23
    var cornerRadius : CGFloat = 8
    var body: some View {
        VStack(spacing: 0){
            LocationCardView(
                imageName: "pickup_ellipse",
                heading: pickupHeading,
                content: pickupLocation,
                onTap: {},
                cornerRadius: cornerRadius,
                roundedEdges: .top
                
            )
            LocationCardView(
                imageName: "dropoff_ellipse",
                heading: destinationHeading,
                content: destinationLocation,
                cornerRadius: cornerRadius,
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
            .offset(x: offsetX)
            ,alignment: .leading
        )
    }
}

struct PickupTimeCard: View {
    var pickupTime: String
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
            VStack(alignment: .leading, spacing: 2) {
                Text("Pickup time")
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(Color(red: 0.59, green: 0.59, blue: 0.59))
                Text(pickupTime)
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 13)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.92, green: 0.92, blue: 0.92).opacity(0.60), lineWidth: 0.5)
        )
        .frame(width: 362)
    }
}
//
//#Preview {
//    ReservationConfirmedScreen()
//}
