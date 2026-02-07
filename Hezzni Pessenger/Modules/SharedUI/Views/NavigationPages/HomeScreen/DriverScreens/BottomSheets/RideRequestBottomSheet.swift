//
//  RideRequestBottomSheet.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/7/26.
//

import SwiftUI

struct RideRequestBottomSheet: View {
    let request: RideRequest
    let onAccept: () -> Void
    let onSkip: () -> Void
    
    // Countdown timer
    let countdownSeconds: Int = 15
    @State private var remainingSeconds: Int = 15
    @State private var countdownTimer: Timer?
    
    var body: some View {
        VStack(spacing: 16) {
            // Driver info
            RiderCardInformationSection(
                profileImage: "profile_placeholder",
                name: request.passengerName,
                trips: request.passengerTrips,
                rating: request.passengerRating,
                badgeImage: request.isVerified ? "verified_badge" : nil,
                carInfo: "8 | أ | 26363",
                carModel: "Toyota HR-V",
                carColor: "White",
                carType: "STANDARD",
                carImage: "personal_car1"
            )
            VStack(spacing: 0){
                HStack {
                        Text(request.fare)
                            .font(Font.custom("Poppins", size: 28).weight(.semibold))
                            .foregroundColor(.black)
                    Spacer()
                }
                    HStack(spacing: 8) {
                        Text("\(request.duration) • \(request.distance)")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color.black.opacity(0.6))
                        PaymentMethodBadge(icon: "cash_on_deliver_icon", text: request.paymentMethod)
                        Spacer()
                    }
            }
            
            
            Divider()
                .padding(.horizontal, -16)
            

            PickupDestinationPathView(pickupLocation: request.pickupLocation, destinationLocation: request.destinationLocation, offsetX: 25)
            HStack(spacing: 12) {
                Button(action: {
                    stopCountdown()
                    onSkip()
                }) {
                    Text("Skip")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(width: 130, height: 50)
                        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
                        .cornerRadius(10)
                }
                
                // Accept button with countdown progress
                Button(action: {
                    stopCountdown()
                    onAccept()
                }) {
                    AcceptButtonWithCountdown(
                        remainingSeconds: remainingSeconds,
                        totalSeconds: countdownSeconds
                    )
                }
            }
        }
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 35, trailing: 20))
        .background(.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.10), radius: 10)
        .onAppear {
            startCountdown()
        }
        .onDisappear {
            stopCountdown()
        }
    }
    
    private func startCountdown() {
        remainingSeconds = countdownSeconds
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingSeconds > 0 {
                remainingSeconds -= 1
            } else {
                stopCountdown()
                onSkip() // Auto-skip when timer expires
            }
        }
    }
    
    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}

// MARK: - Accept Button with Countdown Progress
struct AcceptButtonWithCountdown: View {
    let remainingSeconds: Int
    let totalSeconds: Int
    
    private var progress: CGFloat {
        CGFloat(remainingSeconds) / CGFloat(totalSeconds)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Light green background (revealed as timer counts down)
                Rectangle()
                    .fill(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.4))
                
                // Dark green progress (shrinks from right to left)
                Rectangle()
                    .fill(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .frame(width: geometry.size.width * progress)
                    .animation(.linear(duration: 1.0), value: progress)
                
                // Text overlay
                HStack {
                    Spacer()
                    Text("Accept (\(remainingSeconds)s)")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.white)
                    Spacer()
                }
            }
        }
        .frame(height: 50)
        .cornerRadius(10)
    }
}

//// Swift
//#Preview {
//    RideRequestBottomSheet(
//        request: RideRequest(
//            passengerName: "Test Passenger",
//            passengerRating: 4.5,
//            passengerTrips: 10,
//            passengerImage: "profile_placeholder",
//            isVerified: true,
//            pickupLocation: "Current Location, Marrakech",
//            destinationLocation: "Menara Mall, Gueliz District",
//            distance: "2.5 KM",
//            duration: "8 min",
//            fare: "25.00 MAD",
//            paymentMethod: "Cash",
//            rideType: "Standard"
//        ),
//        onAccept: {},
//        onSkip: {}
//    )
//}



struct RiderCardInformationSection: View {
    var profileImage: String
    var name: String
    var trips: Int
    var rating: Double
    var badgeImage: String?
    var carInfo: String
    var carModel: String
    var carColor: String
    var carType: String
    var carImage: String
    var price: Double?
    var id: String?

    var body: some View {
        HStack {
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


#Preview{

    // Driver info
    RiderCardInformationSection(
        profileImage: "profile_placeholder",
        name: "Ahmed Hassan",
        trips: 2847,
        rating: 4.8,
        badgeImage: "verified_badge",
        carInfo: "8 | أ | 26363",
        carModel: "Toyota HR-V",
        carColor: "White",
        carType: "STANDARD",
        carImage: "personal_car1"
    )
    
}
