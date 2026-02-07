//
//  DriverHomeComplete.swift
//  Hezzni
//
//  Complete Driver Home with Ride Request, Active Ride, Chat, and Trip Complete integration
//

import SwiftUI
import GoogleMaps
import CoreLocation
import OSLog

// MARK: - Ride Request Model
struct RideRequest: Identifiable {
    let id: UUID
    let rideRequestId: Int
    let passengerName: String
    let passengerRating: Double
    let passengerTrips: Int
    let passengerImage: String
    let passengerPhone: String?
    let isVerified: Bool
    let pickupLocation: String
    let pickupLatitude: Double
    let pickupLongitude: Double
    let destinationLocation: String
    let destinationLatitude: Double
    let destinationLongitude: Double
    let distance: String
    let duration: String
    let fare: String
    let paymentMethod: String
    let rideType: String
    let distanceToPickup: String
    let estimatedArrivalMinutes: Int
    
    // Initialize from DriverRideRequest socket model
    init(from socketRequest: DriverRideRequest) {
        self.id = UUID()
        self.rideRequestId = socketRequest.rideRequestId
        self.passengerName = socketRequest.passenger.name
        self.passengerRating = socketRequest.passenger.rating ?? 5.0
        self.passengerTrips = 0 // Not provided in socket
        self.passengerImage = socketRequest.passenger.imageUrl ?? "profile_placeholder"
        self.passengerPhone = socketRequest.passenger.phone
        self.isVerified = true
        self.pickupLocation = socketRequest.pickup.address
        self.pickupLatitude = socketRequest.pickup.latitude
        self.pickupLongitude = socketRequest.pickup.longitude
        self.destinationLocation = socketRequest.dropoff.address
        self.destinationLatitude = socketRequest.dropoff.latitude
        self.destinationLongitude = socketRequest.dropoff.longitude
        self.distance = socketRequest.formattedRideDistance
        self.duration = socketRequest.formattedRideDuration
        self.fare = socketRequest.formattedPrice
        self.paymentMethod = "Cash"
        self.rideType = socketRequest.serviceTypeName ?? "Hezzni Standard"
        self.distanceToPickup = socketRequest.formattedDistanceToPickup
        self.estimatedArrivalMinutes = socketRequest.estimatedArrivalMinutes ?? 5
    }
    
    // Legacy initializer for backward compatibility
    init(
        passengerName: String,
        passengerRating: Double,
        passengerTrips: Int,
        passengerImage: String,
        isVerified: Bool,
        pickupLocation: String,
        pickupLatitude: Double,
        pickupLongitude: Double,
        destinationLocation: String,
        destinationLatitude: Double,
        destinationLongitude: Double,
        distance: String,
        duration: String,
        fare: String,
        paymentMethod: String,
        rideType: String
    ) {
        self.id = UUID()
        self.rideRequestId = 0
        self.passengerName = passengerName
        self.passengerRating = passengerRating
        self.passengerTrips = passengerTrips
        self.passengerImage = passengerImage
        self.passengerPhone = nil
        self.isVerified = isVerified
        self.pickupLocation = pickupLocation
        self.pickupLatitude = pickupLatitude
        self.pickupLongitude = pickupLongitude
        self.destinationLocation = destinationLocation
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.distance = distance
        self.duration = duration
        self.fare = fare
        self.paymentMethod = paymentMethod
        self.rideType = rideType
        self.distanceToPickup = "N/A"
        self.estimatedArrivalMinutes = 5
    }
}

// MARK: - Driver Ride State
enum DriverRideState {
    case offline
    case waitingForRequests
    case rideRequestReceived
    case rideAccepted
    case arrivedAtPickup
    case rideInProgress
    case rideCompleted
}

// MARK: - Main Driver Home View
struct DriverHomeComplete: View {
    @State private var mapView = GMSMapView()
    @State private var cameraPosition: GMSCameraPosition
    @StateObject private var locationManager = LocationManager()
    @ObservedObject private var driverSocketManager = DriverRideSocketManager.shared
    @State private var isOnline = false
    @State private var showOptionsSheet = false
    @State private var todaysEarnings: Double = 0.00
    @State private var tripsToday: Int = 5
    @State private var showSideDrawer = false
    @State private var navigateToEarnings = false
    @State private var navigateToHezzniWallet = false
    @State private var navigateToTripHistory = false
    @State private var navigateToAccount = false
    @State private var navigateToSupport = false
    
    @State private var rideState: DriverRideState = .offline
    @State private var currentRideRequest: RideRequest?
    @State private var showChatScreen = false
    @State private var showCallOptions = false
    @State private var showTripComplete = false
    @State private var showRatingSheet = false
    @State private var locationUpdateTimer: Timer?
    
    @StateObject var preferencesVM = DriverPreferencesViewModel()
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.hezzni.app", category: "DriverHome")

    init() {
        let defaultLocation = CLLocationCoordinate2D(latitude: 31.6295, longitude: -7.9811)
        _cameraPosition = State(initialValue: GMSCameraPosition.camera(withTarget: defaultLocation, zoom: 14))
        
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                mapContentView
                    .onAppear { configureMap() }
                    .onChange(of: locationManager.currentLocation) { location in
                        updateCameraPosition(location: location)
                    }
                
                VStack {
                    topNavigationBar
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    bottomFloatingButtons
                        .padding(.bottom, getBottomPadding())
                }
                
                VStack {
                    Spacer()
                    bottomSheetContent
                }
                .edgesIgnoringSafeArea(.bottom)
                
                if showSideDrawer {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation { showSideDrawer = false }
                        }
                    SideDrawerView(isOpen: $showSideDrawer, navigateToEarnings: $navigateToEarnings,
                                   navigateToHezzniWallet : $navigateToHezzniWallet,
                                    navigateToTripHistory : $navigateToTripHistory,
                                    navigateToAccount : $navigateToAccount,
                                    navigateToSupport : $navigateToSupport
                    )
                        .transition(.move(edge: .leading))
                        .zIndex(1)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                locationManager.startUpdatingLocation()
            }
            .sheet(isPresented: $showOptionsSheet) {
                DriverOptionsSheet(isPresented: $showOptionsSheet, preferencesVM: preferencesVM)
                    .presentationDetents([.height(600)])
                    .presentationDragIndicator(.hidden)
                    .presentationBackground(.white)
            }
            .navigationDestination(isPresented: $showChatScreen) {
                ChatDetailedScreen()
            }
            .fullScreenCover(isPresented: $showTripComplete) {
                TripCompleteScreen(
                    onRate: {
                        showTripComplete = false
                        showRatingSheet = true
                    },
                    onBookAnother: {
                        showTripComplete = false
                        resetToWaitingState()
                    }
                )
//                DriverTripCompleteScreen(
//                    onRateRider: {
//                        showTripComplete = false
//                        showRatingSheet = true
//                    },
//                    onFindNextRide: {
//                        showTripComplete = false
//                        resetToWaitingState()
//                    }
//                )
            }
            .sheet(isPresented: $showRatingSheet) {
                DriverRatingScreen(
                    passengerName: currentRideRequest?.passengerName ?? "Passenger",
                    onSubmit: {
                        showRatingSheet = false
                        resetToWaitingState()
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(35)
                .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showCallOptions) {
                CallOptionsSheet(
                    passengerName: currentRideRequest?.passengerName ?? "Passenger",
                    onDismiss: { showCallOptions = false }
                )
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
            .navigationDestination(isPresented: $navigateToEarnings) {
                EarningsScreen()
            }
            .navigationDestination(isPresented: $navigateToHezzniWallet) {
                WalletHomeScreen()
            }
            .navigationDestination(isPresented: $navigateToTripHistory) {
                HistoryScreen()
            }
            .navigationDestination(isPresented: $navigateToAccount) {
                DriverAccountScreen()
            }
            .navigationDestination(isPresented: $navigateToSupport) {
                HelpSupportScreen()
            }
            
            
        }
        
        .onAppear {
            setupSocketCallbacks()
        }
    }
    
    // MARK: - Socket Setup
    
    private func setupSocketCallbacks() {
        // Handle new ride requests from socket
        driverSocketManager.onNewRideRequest = { driverRideRequest in
            log.info("Received new ride request from socket: rideRequestId=\(driverRideRequest.rideRequestId)")
            
            let rideRequest = RideRequest(from: driverRideRequest)
            
            DispatchQueue.main.async {
                if rideState == .waitingForRequests {
                    currentRideRequest = rideRequest
                    withAnimation {
                        rideState = .rideRequestReceived
                    }
                }
            }
        }
        
        // Handle ride offer timeout
        driverSocketManager.onRideRequestTimeout = {
            log.info("Ride offer timed out")
            DispatchQueue.main.async {
                if rideState == .rideRequestReceived {
                    withAnimation {
                        rideState = .waitingForRequests
                        currentRideRequest = nil
                    }
                }
            }
        }
        
        // Handle ride accepted confirmation
        driverSocketManager.onRideAccepted = { rideDetails in
            log.info("Ride accepted confirmation received")
            DispatchQueue.main.async {
                withAnimation {
                    rideState = .rideAccepted
                }
            }
        }
        
        // Handle ride accept failed
        driverSocketManager.onRideAcceptFailed = { errorMessage in
            log.error("Failed to accept ride: \(errorMessage)")
            DispatchQueue.main.async {
                withAnimation {
                    rideState = .waitingForRequests
                    currentRideRequest = nil
                }
            }
        }
        
        // Handle ride cancelled
        driverSocketManager.onRideCancelled = { reason in
            log.info("Ride was cancelled: \(reason ?? "No reason")")
            DispatchQueue.main.async {
                withAnimation {
                    rideState = .waitingForRequests
                    currentRideRequest = nil
                }
            }
        }
        
        // Handle errors
        driverSocketManager.onError = { errorMsg in
            log.error("Socket error received: \(errorMsg)")
        }
    }
    
    // MARK: - Subviews
    
    private var mapContentView: some View {
        GoogleMapView(mapView: $mapView, cameraPosition: $cameraPosition)
            .edgesIgnoringSafeArea(.all)
    }
    
    private var topNavigationBar: some View {
        HStack(spacing: 0) {
            
            Button(action: {
                withAnimation { showSideDrawer = true }
            }) {
                circularButton(icon: "hamburger_icon")
            }
            .opacity(rideState == .rideAccepted || rideState == .arrivedAtPickup || rideState == .rideInProgress || rideState == .offline ? 1 : 0)
//            .disabled(rideState == .rideAccepted || rideState == .arrivedAtPickup || rideState == .rideInProgress || rideState == .offline)
            
            Spacer()
            if rideState == .offline || rideState == .waitingForRequests {onlineStatusPill}
            
            Spacer()
            
            if rideState == .rideAccepted || rideState == .arrivedAtPickup || rideState == .rideInProgress {
                    Button(action: {}) {
                        Text("Cancel")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.83, green: 0.18, blue: 0.18))
                    }
                    .padding(12)
                    .background(.white)
                    .cornerRadius(800)
                    .overlay(
                    RoundedRectangle(cornerRadius: 800)
                    .inset(by: 0.40)
                    .stroke(Color(red: 0.90, green: 0.90, blue: 0.90), lineWidth: 0.40)
                    )
                    .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 12, y: 1
                    )
            } else {
                Button(action: {}) {
                    ZStack {
                        circularButton(icon: "notification_bell_icon")
                        notificationBadge
                    }
                }
                .opacity(isOnline ? 0 : 1)
                .disabled(isOnline)
            }
        }
        .padding(.top, 60)
        .padding(.horizontal, 15)
    }
    
    private var onlineStatusPill: some View {
        HStack(spacing: 7) {
            Circle()
                .foregroundColor(.clear)
                .frame(width: 8, height: 8)
                .background(isOnline ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.85, green: 0.85, blue: 0.85))
            Text(isOnline ? "You're Online" : "You're Offline")
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(isOnline ? .black : Color.black.opacity(0.50))
        }
        .padding(EdgeInsets(top: 14, leading: 12, bottom: 14, trailing: 15))
        .background(.white)
        .cornerRadius(800)
        .overlay(
            RoundedRectangle(cornerRadius: 800)
                .stroke(Color(red: 0.90, green: 0.90, blue: 0.90), lineWidth: 0.40)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 12, y: 1)
    }
    
    
    
    private var bottomFloatingButtons: some View {
        HStack(spacing: 12) {
            if rideState == .offline || rideState == .waitingForRequests {
                Button(action: {
                    Task {
                        await preferencesVM.loadPreferences()
                        await MainActor.run {
                            showOptionsSheet = true
                        }
                    }
                }) {
                    circularButton(icon: "options_icon")
                }
                .opacity(isOnline ? 0 : 1)
                .disabled(isOnline)
            }
            if rideState == .rideAccepted{
                
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.white)
                        Text("Navigate")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.white)
                        
                    }
                    .padding(EdgeInsets(top: 10, leading: 13, bottom: 10, trailing: 13))
                    .background(.black)
                    .cornerRadius(800)
                    .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.15), radius: 12, y: 1
                    )
                
            }
                
            
            Spacer()
            
//            if rideState == .rideAccepted || rideState == .arrivedAtPickup || rideState == .rideInProgress {
//                HStack(spacing: 12) {
//                    Button(action: { showChatScreen = true }) {
//                        communicationButton(icon: "message.fill", color: Color(red: 0.22, green: 0.65, blue: 0.33))
//                    }
//
//                    Button(action: { showCallOptions = true }) {
//                        communicationButton(icon: "phone.fill", color: Color(red: 0.22, green: 0.65, blue: 0.33))
//                    }
//                }
//            }
            
            Button(action: {
                centerOnCurrentLocation()
            }) {
                circularButton(icon: "gps_location_icon")
            }
        }
        .padding(.horizontal, 15)
    }
    
    /// Center the map on the user's current location
    private func centerOnCurrentLocation() {
        if let location = locationManager.currentLocation {
            log.info("Centering map on current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16)
            cameraPosition = camera
            mapView.animate(to: camera)
        } else {
            // Request location update if not available
            log.info("Current location not available, requesting update...")
            locationManager.startUpdatingLocation()
        }
    }
    
    @ViewBuilder
    private var bottomSheetContent: some View {
        switch rideState {
        case .offline:
            offlineBottomSheet
        case .waitingForRequests:
            waitingBottomSheet
        case .rideRequestReceived:
            if let request = currentRideRequest {
                RideRequestBottomSheet(
                    request: request,
                    onAccept: { acceptRide() },
                    onSkip: { skipRide() }
                )
            }
        case .rideAccepted:
            ActiveRideBottomSheet(
                request: currentRideRequest!,
                state: .accepted,
                onNavigate: {},
                onArrived: { arrivedAtPickup() },
                onChat: { showChatScreen = true },
                onCall: { showCallOptions = true }
            )
        case .arrivedAtPickup:
            ActiveRideBottomSheet(
                request: currentRideRequest!,
                state: .arrivedAtPickup,
                onNavigate: {},
                onStartRide: { startRide() },
                onChat: { showChatScreen = true },
                onCall: { showCallOptions = true }
            )
        case .rideInProgress:
            ActiveRideBottomSheet(
                request: currentRideRequest!,
                state: .inProgress,
                onNavigate: {},
                onCompleteRide: { completeRide() },
                onChat: { showChatScreen = true },
                onCall: { showCallOptions = true }
            )
        case .rideCompleted:
            EmptyView()
        }
    }
    
    private var offlineBottomSheet: some View {
        VStack(spacing: 21) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
            
            HStack(spacing: 10) {
                earningsCard
                tripsCard
            }
            
            goOnlineButton
        }
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 25, trailing: 20))
        .background(.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.10), radius: 10)
    }
    
    private var waitingBottomSheet: some View {
        VStack(spacing: 21) {
            Capsule()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
            
            Text("Waiting for ride requests…")
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(Color.black.opacity(0.40))
            
            goOfflineButton
        }
        .padding(EdgeInsets(top: 15, leading: 20, bottom: 25, trailing: 20))
        .background(.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.10), radius: 10)
    }
    
    private var earningsCard: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("MAD \(String(format: "%.2f", todaysEarnings))")
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .foregroundColor(.black)
                Text("Today's Earnings")
                    .font(Font.custom("Poppins", size: 10))
                    .foregroundColor(Color.black.opacity(0.60))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Circle()
                .fill(Color.black.opacity(0.06))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.5))
                )
                .offset(x: 75, y: -12.50)
        }
        .frame(height: 75)
        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
        .cornerRadius(15)
    }
    
    private var tripsCard: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(tripsToday)")
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .foregroundColor(.black)
                Text("Trips Today")
                    .font(Font.custom("Poppins", size: 10))
                    .foregroundColor(Color.black.opacity(0.60))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            
            Circle()
                .fill(Color.black.opacity(0.06))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "car.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray.opacity(0.5))
                )
                .offset(x: 75, y: -12.50)
        }
        .frame(height: 75)
        .background(Color(red: 0.93, green: 0.93, blue: 0.93))
        .cornerRadius(15)
    }
    
    private var goOnlineButton: some View {
        Button(action: { goOnline() }) {
            Text("Go Online")
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                .cornerRadius(10)
        }
    }
    
    private var goOfflineButton: some View {
        Button(action: { goOffline() }) {
            Text("Go Offline")
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0.93, green: 0.93, blue: 0.93))
                .cornerRadius(10)
        }
    }
    
    // MARK: - Helper Views
    
    
    
    private func communicationButton(icon: String, color: Color) -> some View {
        Image(systemName: icon)
            .font(.system(size: 18))
            .foregroundColor(.white)
            .frame(width: 50, height: 50)
            .background(color)
            .cornerRadius(25)
            .shadow(color: color.opacity(0.3), radius: 8, y: 2)
    }
    
    // MARK: - Helper Methods
    
    private func getBottomPadding() -> CGFloat {
        switch rideState {
        case .offline: return 220
        case .waitingForRequests: return 170
        case .rideRequestReceived: return 355
        case .rideAccepted, .arrivedAtPickup, .rideInProgress: return 300
        case .rideCompleted: return 100
        }
    }
    
    private func goOnline() {
        Task {
            let ids = Array(preferencesVM.selectedPreferenceIds).sorted()
            log.info("Go Online tapped. selectedPreferenceIds=\(ids, privacy: .public)")

            do {
                let response = try await APIService.shared.driverGoOnline(preferenceIds: ids)
                log.info("Go Online API success. isOnline=\(response.data.isOnline, privacy: .public) activePreferences=\(response.data.activePreferences ?? [], privacy: .public)")

                await MainActor.run {
                    withAnimation {
                        isOnline = response.data.isOnline
                        rideState = response.data.isOnline ? .waitingForRequests : .offline
                    }
                    if response.data.isOnline {
                        // Pass current location and preferences to socket manager before going online
                        if let location = locationManager.currentLocation {
                            driverSocketManager.setLocation(
                                latitude: location.coordinate.latitude,
                                longitude: location.coordinate.longitude,
                                preferences: ids
                            )
                            log.info("Setting driver location: \(location.coordinate.latitude), \(location.coordinate.longitude) with preferences: \(ids)")
                        } else {
                            // Even without location, set preferences
                            driverSocketManager.setLocation(
                                latitude: 0,
                                longitude: 0,
                                preferences: ids
                            )
                            log.info("Setting driver preferences without location: \(ids)")
                        }
                        
                        // Connect to socket and start listening for ride requests
                        driverSocketManager.goOnline()
                        log.info("Driver socket connected and listening for ride requests")
                        
                        // Start periodic location updates (every 10 seconds)
                        startLocationUpdates()
                    }
                }
            } catch {
                let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                log.error("Go Online API failed. error=\(msg, privacy: .public)")
            }
        }
    }
    
    private func goOffline() {
        Task {
            log.info("Go Offline tapped")

            do {
                let response = try await APIService.shared.driverGoOffline()
                log.info("Go Offline API success. isOnline=\(response.data.isOnline, privacy: .public)")

                await MainActor.run {
                    withAnimation {
                        isOnline = response.data.isOnline
                        rideState = response.data.isOnline ? .waitingForRequests : .offline
                    }
                    // Stop location updates
                    stopLocationUpdates()
                    
                    // Disconnect from socket when going offline
                    driverSocketManager.goOffline()
                    log.info("Driver socket disconnected")
                }
            } catch {
                let msg = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                log.error("Go Offline API failed. error=\(msg, privacy: .public)")
            }
        }
    }
    
    /// Start sending periodic location updates to the server
    private func startLocationUpdates() {
        stopLocationUpdates() // Stop any existing timer
        
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [self] _ in
            if let location = locationManager.currentLocation {
                driverSocketManager.updateLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                log.info("Sent location update: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            }
        }
        log.info("Started periodic location updates")
    }
    
    /// Stop sending periodic location updates
    private func stopLocationUpdates() {
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
        log.info("Stopped periodic location updates")
    }
    
    private func acceptRide() {
        guard let rideRequest = currentRideRequest else {
            log.warning("No current ride request to accept")
            return
        }
        
        // Emit socket event to accept the ride
        driverSocketManager.acceptRide(rideRequestId: rideRequest.rideRequestId)
        log.info("Accepting ride request: \(rideRequest.rideRequestId)")
        
        withAnimation {
            rideState = .rideAccepted
        }
    }
    
    private func skipRide() {
        guard let rideRequest = currentRideRequest else {
            log.warning("No current ride request to skip")
            withAnimation {
                rideState = .waitingForRequests
                currentRideRequest = nil
            }
            return
        }
        
        // Emit socket event to decline/skip the ride
        driverSocketManager.declineRide(rideRequestId: rideRequest.rideRequestId)
        log.info("Skipping ride request: \(rideRequest.rideRequestId)")
        
        withAnimation {
            rideState = .waitingForRequests
            currentRideRequest = nil
        }
    }
    
    private func arrivedAtPickup() {
        withAnimation {
            rideState = .arrivedAtPickup
        }
    }
    
    private func startRide() {
        withAnimation {
            rideState = .rideInProgress
        }
    }
    
    private func completeRide() {
        withAnimation {
            rideState = .rideCompleted
            showTripComplete = true
        }
    }
    
    private func resetToWaitingState() {
        withAnimation {
            rideState = .waitingForRequests
            currentRideRequest = nil
        }
        // Socket will automatically receive new ride requests when available
        log.info("Reset to waiting state, listening for new ride requests")
    }
    
    private func updateCameraPosition(location: CLLocation?) {
        if let location = location {
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 14)
            cameraPosition = camera
            mapView.animate(to: camera)
        }
    }
    
    private func configureMap() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
    }
}


// MARK: - Active Ride Bottom Sheet
enum ActiveRideSheetState {
    case accepted
    case arrivedAtPickup
    case inProgress
}

struct ActiveRideBottomSheet: View {
    let request: RideRequest
    let state: ActiveRideSheetState
    var onNavigate: () -> Void = {}
    var onArrived: () -> Void = {}
    var onStartRide: () -> Void = {}
    var onCompleteRide: () -> Void = {}
    var onChat: () -> Void = {}
    var onCall: () -> Void = {}
    
    var body: some View {
        ZStack{
//            if state == .arrivedAtPickup {
//                RoundedRectangle(cornerRadius: 8)
//
//            }
            VStack(spacing: 16) {
                
                
                PassengerInfoRow(
                    name: request.passengerName,
                    rating: request.passengerRating,
                    trips: request.passengerTrips,
                    image: request.passengerImage,
                    isVerified: request.isVerified,
                    onChat: onChat,
                    onCall: onCall
                )
                
                PickupDestinationPathView(pickupLocation: "Current Location, Marrakech", destinationLocation: "Menara Mall, Gueliz District", offsetX: 25)
                
                actionButton
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 35, trailing: 20))
            .background(.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.10), radius: 10)
        }
    }
    
    @ViewBuilder
    private var actionButton: some View {
        switch state {
        case .accepted:
            Button(action: onArrived) {
                Text("I'm here")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .cornerRadius(10)
            }
        case .arrivedAtPickup:
            Button(action: onStartRide) {
                Text("Start Ride")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .cornerRadius(10)
            }
        case .inProgress:
            Button(action: onCompleteRide) {
                Text("Complete Ride")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Passenger Info Row
struct PassengerInfoRow: View {
    let name: String
    let rating: Double
    let trips: Int
    let image: String
    let isVerified: Bool
    var onChat: () -> Void = {}
    var onCall: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 12) {
            Image(image)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                    if isVerified {
                        Image("verified_badge")
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                        .foregroundColor(.black)
                    Text("(\(trips) trips)")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color.black.opacity(0.6))
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: onChat) {
                    Image(systemName: "message.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .cornerRadius(22)
                }
                
                Button(action: onCall) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .cornerRadius(22)
                }
            }
        }
        .padding(12)
//        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views
struct PaymentMethodBadge: View {
    let icon: String
    var isSystemIcon: Bool = false
    let text: String
    
    
    var body: some View {
        HStack(spacing: 4) {
            if isSystemIcon {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(.yellow)
            }
            else {
                Image(icon)
                    .resizable()
                    .scaledToFit()
            }
            Text(text)
                .font(Font.custom("Poppins", size: 12).weight(.medium))
        }
        .padding(8)
        .frame(height: 30)
        .background(.white)
        .cornerRadius(7)
        .overlay(
        RoundedRectangle(cornerRadius: 7)
        .inset(by: 0.50)
        .stroke(Color(red: 0.87, green: 0.87, blue: 0.87), lineWidth: 0.50)
        )
    }
}

struct RideTypeBadge: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image("wheel_icon")
                .resizable()
                .frame(width: 12, height: 12)
            Text(text)
                .font(Font.custom("Poppins", size: 10).weight(.medium))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.black)
        .foregroundColor(.white)
        .cornerRadius(6)
    }
}

struct LocationRow: View {
    let icon: String
    let location: String
    let isPickup: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(location)
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color.black.opacity(0.8))
            
            Spacer()
        }
        .padding(12)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .cornerRadius(10)
    }
}

// MARK: - Call Options Sheet
struct CallOptionsSheet: View {
    let passengerName: String
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose how to call")
                .font(Font.custom("Poppins", size: 18).weight(.semibold))
                .foregroundColor(.black)
            
            Text("You can call \(passengerName) using the Hezzni app or your phone.")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color.black.opacity(0.6))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button(action: {}) {
                    HStack(spacing: 12) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Direct Call")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.black)
                            Text("Use your phone's dialer")
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(Color.black.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.black.opacity(0.3))
                    }
                    .padding(16)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                    .cornerRadius(12)
                }
                
                Button(action: {}) {
                    HStack(spacing: 12) {
                        Image("app_icon_small")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Call via Hezzni")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.black)
                            Text("Stay in the app for secure calls")
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(Color.black.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.black.opacity(0.3))
                    }
                    .padding(16)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                    .cornerRadius(12)
                }
            }
        }
        .padding(24)
        .background(.white)
    }
}

// MARK: - Driver Trip Complete Screen
struct DriverTripCompleteScreen: View {
    var fare: String = "25.00 MAD"
    var serviceFee: String = "-1.25 MAD"
    var distance: String = "2.5 KM"
    var time: String = "8 min"
    var paymentMethod: String = "Cash"
    var discount: String = "5%"
    var earningsAdded: String = "22.00 MAD"
    
    var passengerName: String = "Ahmed Hassan"
    var passengerRating: Double = 4.8
    var passengerImage: String = "profile_placeholder"
    
    var pickupLocation: String = "Current Location, Marrakech"
    var destinationLocation: String = "Current Location, Marrakech"
    
    var onRateRider: () -> Void = {}
    var onFindNextRide: () -> Void = {}
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.67, green: 0.85, blue: 0.72))
                            .frame(width: 100, height: 100)
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    }
                    
                    Text("Trip Complete")
                        .font(Font.custom("Poppins", size: 22).weight(.semibold))
                        .foregroundColor(.black)
                    
                    Text("Your trip has ended successfully.")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color.black.opacity(0.6))
                }
                .padding(.top, 40)
                
                tripSummaryCard
                
                passengerCard
                
                locationCard
                
                VStack(spacing: 12) {
                    Button(action: onRateRider) {
                        Text("Rate your Rider")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onFindNextRide) {
                        Text("Find Next Ride")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
    }
    
    private var tripSummaryCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "doc.text")
                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                Text("Trip Summary")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(Color.black.opacity(0.3))
            }
            
            VStack(spacing: 8) {
                summaryRow(title: "Fare", value: fare, valueColor: .black)
                summaryRow(title: "Service fee (5%)", value: serviceFee, valueColor: Color.red)
                summaryRow(title: "Distance", value: distance, valueColor: .black)
                summaryRow(title: "Time", value: time, valueColor: .black)
                summaryRow(title: "Payment Method", value: paymentMethod, valueColor: Color(red: 0.22, green: 0.65, blue: 0.33), showBadge: true)
                summaryRow(title: "Discount", value: discount, valueColor: .black)
                
                Divider()
                
                HStack {
                    Text("Earnings Added")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                    Spacer()
                    Text(earningsAdded)
                        .font(Font.custom("Poppins", size: 16).weight(.semibold))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10)
        .padding(.horizontal, 20)
    }
    
    private func summaryRow(title: String, value: String, valueColor: Color, showBadge: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color.black.opacity(0.6))
            Spacer()
            if showBadge {
                HStack(spacing: 4) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 10))
                    Text(value)
                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(valueColor.opacity(0.1))
                .foregroundColor(valueColor)
                .cornerRadius(12)
            } else {
                Text(value)
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(valueColor)
            }
        }
    }
    
    private var passengerCard: some View {
        HStack(spacing: 12) {
            Image(passengerImage)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(passengerName)
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.black)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", passengerRating))
                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
        .padding(.horizontal, 20)
    }
    
    private var locationCard: some View {
        PickupDestinationPathView(pickupLocation: "Current Location, Marrakech", destinationLocation: "Menara Mall, Gueliz District", offsetX: 25)
    }
}

// MARK: - Driver Rating Screen
struct DriverRatingScreen: View {
    let passengerName: String
    var onSubmit: () -> Void = {}
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedTags: Set<String> = []
    
    private let positiveTags = ["Polite & friendly", "Great conversation", "On time pickup", "Smooth Payment", "Clear directions", "Easy to deal with"]
    private let negativeTags = ["Rude or unfriendly", "Bad communication", "Late to pickup", "Payment Issue", "Confusing directions", "Too many stops"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How was your rider?")
                .font(Font.custom("Poppins", size: 18).weight(.medium))
                .foregroundColor(.black)
            
            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(rating >= 4 ? Color(red: 0.22, green: 0.65, blue: 0.33) : (rating >= 3 ? .yellow : .orange))
                        .onTapGesture {
                            withAnimation { rating = index }
                        }
                }
            }
            
            if rating > 0 {
                Text(getRatingLabel())
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color.black.opacity(0.6))
            }
            
            if rating > 0 && rating < 4 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What went wrong?")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                    
                    DriverFlowLayout(spacing: 8) {
                        ForEach(negativeTags, id: \.self) { tag in
                            TagButton(text: tag, isSelected: selectedTags.contains(tag)) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
            }
            
            if rating >= 4 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tell us about your rider...")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                    
                    DriverFlowLayout(spacing: 8) {
                        ForEach(positiveTags, id: \.self) { tag in
                            TagButton(text: tag, isSelected: selectedTags.contains(tag)) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Tell us about your rider...")
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color.black.opacity(0.5))
                
                TextEditor(text: $reviewText)
                    .font(Font.custom("Poppins", size: 14))
                    .frame(height: 80)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                    )
            }
            
            Button(action: onSubmit) {
                Text("Submit Review")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding(20)
        .background(.white)
    }
    
    private func getRatingLabel() -> String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Needs Improvements"
        case 3: return "Satisfactory"
        case 4: return "Great!"
        case 5: return "Amazing!"
        default: return ""
        }
    }
}

// MARK: - Tag Button
struct TagButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Font.custom("Poppins", size: 12))
                .foregroundColor(isSelected ? .white : Color.black.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .padding(9)
                .cornerRadius(8)
                .overlay(
                RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 0.50)
                )
                .overlay(
                RoundedRectangle(cornerRadius: 8)
                .stroke(
                Color(red: 0, green: 0, blue: 0).opacity(0.15), lineWidth: 0.50
                )
                )
        }
    }
}

// MARK: - Flow Layout for Tags
struct DriverFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.origin.x, y: bounds.minY + frame.origin.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var frames: [CGRect] = []
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        return (CGSize(width: maxWidth, height: currentY + lineHeight), frames)
    }
}

#Preview {
    DriverHomeComplete()
}

// MARK: - Side Drawer View
struct SideDrawerView: View {
    @Binding var isOpen: Bool
    @Binding var navigateToEarnings: Bool
    @Binding var navigateToHezzniWallet: Bool
    @Binding var navigateToTripHistory: Bool
    @Binding var navigateToAccount: Bool
    @Binding var navigateToSupport: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Green Header Section
            VStack(alignment: .leading, spacing: 0) {
                
                
                // Profile Section
                HStack(spacing: 12) {
                    // Profile Image
                    Image("profile_placeholder")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(800)
                        .font(.system(size: 30))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .frame(width: 68, height: 68)
                        .background{
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                
                        }
                        
                    
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Ahmed Hassan")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(.white)
                            
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(.yellow)
                            
                            Text("4.8")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(.white)
                            
                            Text("(2,847 trips)")
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .overlay(alignment: .topTrailing){
                    HStack {
                        Spacer()
                        Button(action: { withAnimation { isOpen = false } }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                .safeAreaPadding(.top,60)
                
                // Balance Cards
                HStack(spacing: 12) {
                    // Wallet Balance Card
                    VStack(alignment: .leading, spacing: 4) {
                        Text("55.66 MAD")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(.white)
                        
                        Text("Wallet Balance")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    
                    // Earnings Balance Card
                    VStack(alignment: .leading, spacing: 4) {
                        Text("135.66 MAD")
                            .font(Font.custom("Poppins", size: 18).weight(.semibold))
                            .foregroundColor(.white)
                        
                        Text("Earnings Balance")
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(Color(red: 0.22, green: 0.65, blue: 0.33))
            
            // White Menu Section
            VStack(alignment: .leading, spacing: 0) {
                DrawerMenuItem(icon: "earning_icon", text: "Earnings", action: {
                    withAnimation { isOpen = false }
                    navigateToEarnings = true
                })
                
                DrawerMenuItem(icon: "hezzni_wallet_icon_green", text: "Hezzni Wallet", action: {
                    withAnimation { isOpen = false }
                    navigateToHezzniWallet = true
                })
                
                DrawerMenuItem(icon: "tripHistory_icon", text: "Trip History", action: {
                    withAnimation { isOpen = false }
                    navigateToTripHistory = true
                })
                
                DrawerMenuItem(icon: "account_icon_filled_green", text: "Account", action: {
                    withAnimation { isOpen = false }
                    navigateToAccount = true
                })
                
                DrawerMenuItem(icon: "support_icon", text: "Support", action: {
                    withAnimation { isOpen = false }
                    navigateToSupport = true
                })
            }
            .padding(.top, 24)
            
            Spacer()
        }
        .frame(width: 350)
        .background(Color.white)
//        .edgesIgnoringSafeArea(.vertical)
        
    }
}


struct DrawerMenuItem: View {
    let icon: String
    let text: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Icon placeholder - replace with your custom icons
                Image(icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                
                Text(text)
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .lineSpacing(12)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            .frame(height: 62)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    // Helper function to map icon names to SF Symbols
    private func getSystemIcon(for iconName: String) -> String {
        switch iconName {
        case "earnings-icon":
            return "creditcard.fill"
        case "wallet-icon":
            return "wallet.pass.fill"
        case "trip-history-icon":
            return "clock.arrow.circlepath"
        case "account-icon":
            return "person.crop.circle.fill"
        case "support-icon":
            return "questionmark.circle.fill"
        default:
            return "circle.fill"
        }
    }
}

// MARK: - Driver Options Sheet
struct DriverOptionsSheet: View {
    @Binding var isPresented: Bool
    @ObservedObject var preferencesVM: DriverPreferencesViewModel

    private func assetIcon(for preferenceKey: String) -> String {
        switch preferenceKey.uppercased() {
        case "STANDARD": return "car-service-icon"
        case "COMFORT": return "car-service-comfort-icon"
        case "XL": return "car-service-xl-icon"
        case "DELIVERY": return "delivery-service-icon"
        default: return "car-service-icon"
        }
    }

    private var rideOptions: [VehicleOptionsView.RideOption] {
        preferencesVM.preferences.map { pref in
            VehicleOptionsView.RideOption(
                id: pref.id,
                icon: assetIcon(for: pref.key),
                title: pref.name,
                subtitle: pref.description
            )
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Ride Preferences")
                .font(.poppins(.semiBold, size: 18))
                .padding(.top, 20)

            if preferencesVM.isLoading {
                ProgressView()
                    .padding(.vertical, 20)
            }

            if let error = preferencesVM.errorMessage {
                Text(error)
                    .font(.poppins(.regular, size: 12))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            VehicleOptionsView(selectedPreferenceIds: $preferencesVM.selectedPreferenceIds, options: rideOptions)
                .padding(.horizontal, 20)

            Spacer()

            PrimaryButton(
                text: "Confirm",
                isEnabled: true,
                buttonColor: .hezzniGreen
            ) {
                isPresented = false
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .task {
            // If this sheet is opened in any other way, ensure data is loaded.
            await preferencesVM.loadPreferences()
        }
    }
}


struct VehicleOptionsView: View {
    @Binding var selectedPreferenceIds: Set<Int>
    let options: [RideOption]

    struct RideOption {
        let id: Int
        let icon: String
        let title: String
        let subtitle: String
    }

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \ .id) { option in
                DriverRideOptionCard(
                    icon: option.icon,
                    title: option.title,
                    subtitle: option.subtitle,
                    isSelected: Binding<Bool>(
                        get: { selectedPreferenceIds.contains(option.id) },
                        set: { isSelected in
                            if isSelected {
                                selectedPreferenceIds.insert(option.id)
                            } else {
                                selectedPreferenceIds.remove(option.id)
                            }
                        }
                    )
                )
            }
        }
    }
}

// MARK: - Ride Options Card
struct DriverRideOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    
    
    @Binding var isSelected: Bool
    
    var body: some View {
        HStack(alignment: .center) {
            // Left Content
            HStack(alignment: .center, spacing: 12) {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(title)
                            .font(.poppins(.medium, size: 16))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        
                        Text(subtitle)
                            .font(.poppins(.regular, size: 12))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                    }
                    
                }
            }
            
            Spacer()
            
            // Right Content
            VStack(alignment: .trailing, spacing: 10) {
                
                Toggle("", isOn: $isSelected)
                    .toggleStyle(CustomToggleStyle())
                    .labelsHidden()
                    
            }
            .padding(0)
            .frame(height: 45, alignment: .center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 96, maxHeight: 96, alignment: .center)
        .background(.white)
        .cornerRadius(16)
        .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06).opacity(0.06), radius: 25, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(isSelected ? .hezzniGreen : Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 1)
        )
        .onTapGesture{
            isSelected = !isSelected
        }
    }
}
