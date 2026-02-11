//
//  DriverEnRouteBottomSheet.swift
//  Hezzni Pessenger
//
//  Bottom sheet content showing driver information during ride (no separate map - uses HomeScreen's map)
//

import SwiftUI
import CoreLocation

// MARK: - Passenger Ride State
enum PassengerRideState {
    case driverEnRoute      // Driver is coming to pickup
    case driverArrived      // Driver has arrived at pickup
    case rideInProgress     // Ride has started, heading to destination
    case rideCompleted      // Ride finished
}

struct DriverEnRouteBottomSheet: View {
    @Binding var bottomSheetState: BottomSheetState
    @Binding var sheetHeight: CGFloat
    
    // Socket manager for real-time updates
    @ObservedObject private var socketManager = RideSocketManager.shared
    
    // UI State
    @State private var showChatScreen = false
    @State private var rideState: PassengerRideState = .driverEnRoute
    @State private var showCancelConfirmation = false  // Confirmation dialog state
    
    private let minSheetHeight: CGFloat = 320
    private let midSheetHeight: CGFloat = 420
    private let maxSheetHeight: CGFloat = UIScreen.main.bounds.height * 0.55
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with status
            statusHeader
            // Sheet content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    // Driver & Vehicle info
                    if let driverInfo = socketManager.driverInfo {
                        driverInfoCard(driverInfo: driverInfo)
                        
                        // Driver details with actions
                        driverDetailsSection(driverInfo: driverInfo)
                        
                        // Pickup/Destination
                        PickupDestinationPathView(
                            pickupLocation: driverInfo.pickupAddress,
                            destinationLocation: driverInfo.dropoffAddress
                        )
                    } else {
                        // Fallback loading state
                        ProgressView("Loading driver information...")
                            .padding()
                    }
                    
                    // Bottom action buttons based on ride state
                    bottomActionButtons
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 24)
            }
        }
        .background(Color.white)
        .onAppear {
            sheetHeight = midSheetHeight
            setupSocketCallbacks()
        }
        .onChange(of: socketManager.hasDriverArrived) { arrived in
            if arrived {
                withAnimation {
                    rideState = .driverArrived
                }
            }
        }
        .onChange(of: socketManager.isRideStarted) { started in
            if started {
                withAnimation {
                    rideState = .rideInProgress
                }
            }
        }
        .background(
            NavigationLink(
                destination: ChatDetailedScreen().environmentObject(NavigationStateManager()),
                isActive: $showChatScreen
            ) {
                EmptyView()
            }
        )
        .alert("Cancel Ride", isPresented: $showCancelConfirmation) {
            Button("No, Keep Ride", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                cancelRide()
            }
        } message: {
            Text("Are you sure you want to cancel this ride?")
        }
    }
    
    // MARK: - View Components
    
    private var statusHeader: some View {
        HStack {
            Spacer()
            Text(statusHeaderText)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(.white)
            
            Text(statusTimeText)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(.hezzniGreen)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.white.opacity(0.9))
                .cornerRadius(12)
            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.hezzniGreen)
        .cornerRadius(24, corners: [.topLeft, .topRight])
    }
    
    private var statusHeaderText: String {
        switch rideState {
        case .driverEnRoute:
            return "Driver is on the way"
        case .driverArrived:
            return "Driver has arrived!"
        case .rideInProgress:
            return "Ride in progress"
        case .rideCompleted:
            return "Ride completed"
        }
    }
    
    private var statusTimeText: String {
        switch rideState {
        case .driverEnRoute:
            return "\(socketManager.driverInfo?.estimatedArrivalMinutes ?? 1) min"
        case .driverArrived:
            return "Waiting"
        case .rideInProgress:
            return "On trip"
        case .rideCompleted:
            return "Done"
        }
    }
    
    private func driverInfoCard(driverInfo: DriverFoundResponse) -> some View {
        ReservationScheduleCard(
            carInfo: driverInfo.driver.vehicle.plateNumber,
            carModel: "\(driverInfo.driver.vehicle.make) \(driverInfo.driver.vehicle.model)",
            carColor: driverInfo.driver.vehicle.color ?? "",
            carType: driverInfo.driver.vehicle.year != nil ? String(driverInfo.driver.vehicle.year!) : "STANDARD",
            carImage: "personal_car1"
        )
    }
    
    private func driverDetailsSection(driverInfo: DriverFoundResponse) -> some View {
        PersonDetailsWithActions(
            profileImage: driverInfo.driver.imageUrl ?? "profile_placeholder",
            name: driverInfo.driver.name.trimmingCharacters(in: .whitespaces),
            trips: driverInfo.driver.totalTrips,
            rating: Double(driverInfo.driver.averageRating) ?? 5.0,
            badgeImage: "verified_badge",
            onChat: {
                showChatScreen = true
            },
            onCall: {
                if let phone = driverInfo.driverPhone, let url = URL(string: "tel://\(phone)") {
                    UIApplication.shared.open(url)
                }
            }
        )
    }
    
    // MARK: - Bottom Action Buttons
    
    @ViewBuilder
    private var bottomActionButtons: some View {
        switch rideState {
        case .driverEnRoute, .driverArrived:
            // Show cancel button when ride hasn't started yet
            cancelRideButton
        case .rideInProgress:
            // Show Share Trip and Safety buttons when ride is in progress
            shareTripAndSafetyButtons
        case .rideCompleted:
            // Show rate driver button or return home
            rideCompletedButtons
        }
    }
    
    private var cancelRideButton: some View {
        Button(action: {
            showCancelConfirmation = true  // Show confirmation dialog instead of direct cancel
        }) {
            Text("Cancel Ride")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.83, green: 0.18, blue: 0.18))
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
    
    private var shareTripAndSafetyButtons: some View {
        HStack(spacing: 12) {
            // Share Trip Button
            Button(action: {
                shareTrip()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .medium))
                    Text("Share Trip")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                .cornerRadius(12)
            }
            
            // Safety Button
            Button(action: {
                showSafetyOptions()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 18, weight: .medium))
                    Text("Safety")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.83, green: 0.18, blue: 0.18))
                .cornerRadius(12)
            }
        }
        .padding(.top, 8)
    }
    
    private var rideCompletedButtons: some View {
        Button(action: {
            withAnimation {
                bottomSheetState = .initial
            }
        }) {
            Text("Return Home")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
    
    // MARK: - Socket Callbacks
    
    private func setupSocketCallbacks() {
        // Listen for driver arrived event
        socketManager.onDriverArrived = {
            withAnimation {
                rideState = .driverArrived
            }
        }
        
        // Listen for ride started event
        socketManager.onRideStarted = {
            withAnimation {
                rideState = .rideInProgress
            }
        }
        
        // Listen for ride completed event
        socketManager.onRideCompleted = {
            withAnimation {
                rideState = .rideCompleted
            }
        }
    }
    
    // MARK: - Actions
    
    private func cancelRide() {
        // Emit passenger:cancelRide with rideRequestId
        socketManager.cancelRide(reason: "Passenger cancelled")
        withAnimation {
            bottomSheetState = .initial
        }
    }
    
    private func shareTrip() {
        guard let driverInfo = socketManager.driverInfo else { return }
        
        let shareText = """
        I'm on a Hezzni ride!
        Driver: \(driverInfo.driver.name)
        Vehicle: \(driverInfo.driver.vehicle.make) \(driverInfo.driver.vehicle.model)
        Plate: \(driverInfo.driver.vehicle.plateNumber)
        From: \(driverInfo.pickupAddress)
        To: \(driverInfo.dropoffAddress)
        """
        
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func showSafetyOptions() {
        // Show safety options - could be emergency call, share location, etc.
        if let url = URL(string: "tel://911") {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    DriverEnRouteBottomSheet(
        bottomSheetState: .constant(.driverEnRoute),
        sheetHeight: .constant(420)
    )
}
