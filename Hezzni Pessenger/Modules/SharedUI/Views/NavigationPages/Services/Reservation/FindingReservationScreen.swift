//
//  FindingReservationScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/18/25.
//

import SwiftUI

struct FindingReservationScreen: View {
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    @Binding var sheetHeight: CGFloat
    // Props for trip info
    var vehicle: VehicleSubOptionsView.RideOption = .init(
        id: 1,
        text_id: "standard",
        icon: "car-service-icon",
        title: "Hezzni Standard",
        subtitle: "Comfortable vehicles",
        seats: 4,
        timeEstimate: "3-8 min",
        price: 25
    )
    var pickupLocation: String = "Current Location, Marrakech"
    var destinationLocation: String = "Current Location, Marrakech"
    var pickupDate: Date = Date(timeIntervalSince1970: 1752658800) // 16 July, 2025 at 9:00 am
    var onCancel: () -> Void = {}

    @State private var showReservationScreen = false
    @State private var showNoDriverFound = false
    @State private var timerTask: DispatchWorkItem?

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: pickupDate)
    }
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: pickupDate)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                // Top animated ellipses
                AnimatedEllipses()
                    .padding(.top, 32)

                VStack(spacing: 4) {
                    Text("Finding your Reservation")
                        .font(Font.custom("Poppins", size: 20).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    Text("Matching you with the best driver")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                }

                RideOptionCard(
                    icon: "car-service-icon",
                    title: "Hezzni Standard",
                    subtitle: "Comfortable vehicles",
                    seats: 4,
                    timeEstimate: "3-8 min",
                    price: 25,
                    isSelected: .constant(true)
                )
                // Source & Destination with Line overlay (reuse from HomeScreen)
                VStack(spacing: 0) {
                    LocationCardView(
                        imageName: "pickup_ellipse",
                        heading: "Pickup",
                        content: pickupLocation,
                        roundedEdges: .top
                    )
                    .padding(.bottom, -8)
                    LocationCardView(
                        imageName: "dropoff_ellipse",
                        heading: "Destination",
                        content: destinationLocation,
                        roundedEdges: .bottom
                    )
                }
                .overlay(
                    Line()
                        .stroke(
                            Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.25),
                            style: StrokeStyle(lineWidth: 2, dash: [5,5])
                        )
                        .frame(height: 50)
                        .offset(x: 28),
                    alignment: .leading
                )

                // Pickup time (reuse from ReservationDetailScreen)
                ScheduleCardView(
                    dateTime: "\(formattedDate) at \(formattedTime)",
                    onTap: {}
                )
                .padding(.bottom, 20)

                // Cancel Button
                PrimaryButton(
                    text: "Cancel Search",
                    isEnabled: true,
                    buttonColor: .red,
                    action: onCancel
                )
                .padding(.horizontal, 0)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 16)
            .background(Color(.white))

            // Show NoDriverFoundScreen as a bottom sheet after 20 seconds
            if showNoDriverFound {
                NoDriverFoundScreen(
                    bottomSheetState: $bottomSheetState,
                    onKeepSearching: {
                        withAnimation {
                            showNoDriverFound = false
                        }
                        // Cancel any existing timer
                        timerTask?.cancel()
                        // Start a 5s timer to change bottomSheetState
                        let task = DispatchWorkItem {
                            withAnimation {
                                bottomSheetState = .reservationConfirmation
                            }
                        }
                        timerTask = task
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: task)
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .onAppear {
            // Cancel any previous timer
            timerTask?.cancel()
            // Start a 20s timer to show NoDriverFoundScreen
            let task = DispatchWorkItem {
                withAnimation {
                    showNoDriverFound = true
                }
            }
            timerTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: task)
        }
        .onDisappear {
            timerTask?.cancel()
        }
    }
}

struct AnimatedEllipses: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.10))
                .frame(width: 120, height: 120)
                .scaleEffect(animate ? 1.15 : 0.95)
                .opacity(animate ? 0.7 : 1)
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                        .delay(0),
                    value: animate
                )

            Ellipse()
                .fill(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.20))
                .frame(width: 80, height: 80)
                .scaleEffect(animate ? 1.10 : 0.98)
                .opacity(animate ? 0.85 : 1)
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                        .delay(0.2),
                    value: animate
                )

            Ellipse()
                .fill(Color(red: 0.22, green: 0.65, blue: 0.33))
                .frame(width: 40, height: 40)
                .scaleEffect(animate ? 1.05 : 1)
                .opacity(animate ? 0.95 : 1)
                .animation(
                    Animation.easeInOut(duration: 1.2)
                        .repeatForever(autoreverses: true)
                        .delay(0.4),
                    value: animate
                )
        }
        .frame(width: 120, height: 120)
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    FindingReservationScreen(
        bottomSheetState: .constant(.findingRide),
        sheetHeight: .constant(600)
        
    )
}

