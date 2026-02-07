//
//  FindingReservationScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/18/25.
//

import SwiftUI

struct FindingRideScreen: View {
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    @Binding var sheetHeight: CGFloat
    var isReservation: Bool = false
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
    
    // Socket-related properties
    var pickupLatitude: Double = 0
    var pickupLongitude: Double = 0
    var dropoffLatitude: Double = 0
    var dropoffLongitude: Double = 0
    var serviceTypeId: Int = 1
    var selectedRideOptionId: Int = 1
    var estimatedPrice: Double = 0
    var couponId: Int? = nil  // Optional coupon ID from applied coupon
    
    // Socket manager
    @ObservedObject private var socketManager = RideSocketManager.shared

    @State private var showReservationScreen = false
    @State private var showNoDriverFound = false
    @State private var timerTask: DispatchWorkItem?
    @State private var searchTimeoutSeconds: Int = 60
    @State private var currentSearchTime: Int = 0
    @State private var searchTimer: Timer?

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
                    Text(!isReservation ? "Finding your Ride" : "Finding your Reservation")
                        .font(Font.custom("Poppins", size: 20).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    
                    Text(getStatusMessage())
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                    
                    // Search progress indicator
                    if socketManager.isSearchingForDriver {
                        Text("Searching... \(currentSearchTime)s")
                            .font(Font.custom("Poppins", size: 10))
                            .foregroundColor(.gray)
                            .padding(.top, 4)
                    }
                }

                RideOptionCard(
                    icon: vehicle.icon,
                    title: vehicle.title,
                    subtitle: vehicle.subtitle,
                    seats: vehicle.seats,
                    timeEstimate: vehicle.timeEstimate,
                    price: vehicle.price,
                    isSelected: .constant(true)
                )
                
                // Source & Destination with Line overlay
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
                if isReservation{
                    // Pickup time
                    ScheduleCardView(
                        dateTime: "\(formattedDate) at \(formattedTime)",
                        onTap: {}
                    )
                    .padding(.bottom, 20)
                }

                // Cancel Button
                PrimaryButton(
                    text: "Cancel Search",
                    isEnabled: true,
                    buttonColor: .red,
                    action: cancelSearch
                )
                .padding(.horizontal, 0)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 16)
            .background(Color(.white))

            // Show NoDriverFoundScreen when no driver is found
            if showNoDriverFound {
                NoDriverFoundScreen(
                    bottomSheetState: $bottomSheetState,
                    onKeepSearching: {
                        withAnimation {
                            showNoDriverFound = false
                        }
                        // Restart the search
                        startRideSearch()
                    }
                )
                .transition(.move(edge: .bottom))
                .zIndex(1)
            }
        }
        .onAppear {
            setupSocketCallbacks()
            startRideSearch()
        }
        .onDisappear {
            cleanupTimers()
            socketManager.disconnect()
        }
        .onChange(of: socketManager.currentRideStatus) { newStatus in
            handleStatusChange(newStatus)
        }
    }
    
    // MARK: - Socket Integration
    
    private func setupSocketCallbacks() {
        socketManager.onDriverFound = { driver in
            cleanupTimers()
            withAnimation {
                bottomSheetState = .reservationConfirmation
            }
        }
        
        socketManager.onNoDriverFound = {
            cleanupTimers()
            withAnimation {
                showNoDriverFound = true
            }
        }
        
        socketManager.onError = { errorMessage in
            print("Socket error: \(errorMessage)")
            // Optionally show error to user
        }
        
        socketManager.onRideRequestSuccess = { rideId in
            print("Ride request successful. Ride ID: \(rideId)")
        }
    }
    
    private func startRideSearch() {
        currentSearchTime = 0
        
        // Request ride - the socketManager will handle connection automatically
        // It will connect first if not already connected
        socketManager.requestRide(
            pickupLatitude: pickupLatitude,
            pickupLongitude: pickupLongitude,
            pickupAddress: pickupLocation,
            dropoffLatitude: dropoffLatitude,
            dropoffLongitude: dropoffLongitude,
            dropoffAddress: destinationLocation,
            serviceTypeId: serviceTypeId,
            selectedRideOptionId: selectedRideOptionId,
            estimatedPrice: estimatedPrice,
            couponId: couponId
        )
        
        // Start search timer
        searchTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            currentSearchTime += 1
            
            // Timeout after specified seconds
            if currentSearchTime >= searchTimeoutSeconds {
                cleanupTimers()
                socketManager.cancelRideSearch()
                withAnimation {
                    showNoDriverFound = true
                }
            }
        }
        
        // Fallback timer (legacy behavior)
        timerTask?.cancel()
        let task = DispatchWorkItem {
            if socketManager.isSearchingForDriver {
                withAnimation {
                    showNoDriverFound = true
                }
            }
        }
        timerTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(searchTimeoutSeconds), execute: task)
    }
    
    private func cancelSearch() {
        cleanupTimers()
        socketManager.cancelRideSearch()
        socketManager.disconnect() // Ensure socket is fully disconnected
        onCancel()
    }
    
    private func cleanupTimers() {
        timerTask?.cancel()
        timerTask = nil
        searchTimer?.invalidate()
        searchTimer = nil
    }
    
    private func handleStatusChange(_ status: RideStatusUpdate.RideStatus?) {
        guard let status = status else { return }
        
        switch status {
        case .driverFound:
            cleanupTimers()
            withAnimation {
                bottomSheetState = .reservationConfirmation
            }
        case .noDriverFound:
            cleanupTimers()
            withAnimation {
                showNoDriverFound = true
            }
        case .rideCancelled:
            cleanupTimers()
        default:
            break
        }
    }
    
    private func getStatusMessage() -> String {
        switch socketManager.currentRideStatus {
        case .searching:
            return "Matching you with the best driver"
        case .driverFound:
            return "Driver found! Getting details..."
        case .noDriverFound:
            return "No drivers available nearby"
        default:
            return "Matching you with the best driver"
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
    FindingRideScreen(
        bottomSheetState: .constant(.findingRide),
        sheetHeight: .constant(600),
        pickupLatitude: 33.5731,
        pickupLongitude: -7.5898,
        dropoffLatitude: 33.5922,
        dropoffLongitude: -7.6012,
        serviceTypeId: 1,
        selectedRideOptionId: 1,
        estimatedPrice: 25
    )
}

