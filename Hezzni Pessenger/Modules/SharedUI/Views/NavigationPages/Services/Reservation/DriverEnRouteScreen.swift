//
//  DriverEnRouteScreen.swift
//  Hezzni Pessenger
//
//  Shows driver information and real-time tracking after ride is accepted
//

import SwiftUI
import GoogleMaps
import CoreLocation

//// MARK: - Passenger Ride State
//enum PassengerRideState {
//    case driverEnRoute      // Driver is coming to pickup
//    case driverArrived      // Driver has arrived at pickup
//    case rideInProgress     // Ride has started, heading to destination
//    case rideCompleted      // Ride finished
//}

struct DriverEnRouteScreen: View {
    @Binding var bottomSheetState: BottomSheetState

    
    // Socket manager for real-time updates
    @ObservedObject private var socketManager = RideSocketManager.shared
    
    // Map state
    @State private var mapView = GMSMapView()
    @State private var cameraPosition: GMSCameraPosition
    @State private var driverMarker: GMSMarker?
    @State private var pickupMarker: GMSMarker?
    @State private var destinationMarker: GMSMarker?
    @State private var routePolyline: GMSPolyline?
    
    // Location manager for route drawing
    @StateObject private var locationManager = LocationManager()
    
    // UI State
    @State private var showChatScreen = false
    @State private var showCallOptions = false
    @State private var estimatedArrivalTime: Int = 0
    @State private var rideState: PassengerRideState = .driverEnRoute
    
    private let minSheetHeight: CGFloat = 200
    private let midSheetHeight: CGFloat = 380
    private let maxSheetHeight: CGFloat = UIScreen.main.bounds.height * 0.7
    
    // Pickup coordinates from driver info
    private var pickupCoordinate: CLLocationCoordinate2D? {
        guard let driverInfo = socketManager.driverInfo,
              let lat = Double(driverInfo.pickupLatitude),
              let lng = Double(driverInfo.pickupLongitude) else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    // Destination coordinates from driver info
    private var destinationCoordinate: CLLocationCoordinate2D? {
        guard let driverInfo = socketManager.driverInfo,
              let lat = Double(driverInfo.dropoffLatitude),
              let lng = Double(driverInfo.dropoffLongitude) else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    
    // Driver coordinates - use real-time location if available, fallback to initial
    private var driverCoordinate: CLLocationCoordinate2D? {
        if let location = socketManager.driverLocation {
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        guard let driverInfo = socketManager.driverInfo else { return nil }
        return CLLocationCoordinate2D(
            latitude: driverInfo.driver.currentLatitude,
            longitude: driverInfo.driver.currentLongitude
        )
    }
    
    init(bottomSheetState: Binding<BottomSheetState>) {
        self._bottomSheetState = bottomSheetState
        
        // Initialize camera to a default position (will be updated when driver info is available)
        let defaultCoord = CLLocationCoordinate2D(latitude: 37.33233141, longitude: -122.03121860)
        _cameraPosition = State(initialValue: GMSCameraPosition.camera(withTarget: defaultCoord, zoom: 15))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Map showing driver location and route
            DriverEnRouteMapView(
                mapView: $mapView,
                cameraPosition: $cameraPosition,
                driverCoordinate: driverCoordinate,
                pickupCoordinate: pickupCoordinate
            )
            .edgesIgnoringSafeArea(.all)
            
            // Bottom sheet content
            VStack(spacing: 0) {
                // Header with status
                statusHeader
                
                // White content area
                VStack(spacing: 0) {
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
                .cornerRadius(24)
            }
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
        }
        .onAppear {
            setupMap()
            setupSocketCallbacks()
        }
        .onChange(of: socketManager.driverLocation) { newLocation in
            if let newLocation = newLocation {
                updateDriverMarkerPosition(latitude: newLocation.latitude, longitude: newLocation.longitude)
            }
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
                // Redraw route to destination
                if let driverCoord = driverCoordinate, let destCoord = destinationCoordinate {
                    addDestinationMarker(at: destCoord)
                    drawRouteToDestination(from: driverCoord, to: destCoord)
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
        .ignoresSafeArea()
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
            return "Driver has arrived"
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
            carColor: "",
            carType: "STANDARD",
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
            cancelRide()
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
    
    
    
    // MARK: - Map Setup
    
    private func setupMap() {
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        
        // Apply custom style
        MapStyleHelper.applyCustomStyle(to: mapView)
        
        // Setup initial markers and route
        if let driverCoord = driverCoordinate, let pickupCoord = pickupCoordinate {
            addDriverMarker(at: driverCoord)
            addPickupMarker(at: pickupCoord)
            drawRouteFromDriverToPickup(from: driverCoord, to: pickupCoord)
            fitCameraToShowRoute(driverCoord: driverCoord, pickupCoord: pickupCoord)
        }
    }
    
    private func setupSocketCallbacks() {
        // Listen for driver location updates
        socketManager.onDriverLocationUpdate = { [self] location in
            updateDriverMarkerPosition(latitude: location.latitude, longitude: location.longitude)
            
            // If ride is in progress, update route to destination
            if rideState == .rideInProgress, let destCoord = destinationCoordinate {
                let driverCoord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                drawRouteToDestination(from: driverCoord, to: destCoord)
            }
        }
        
        // Listen for driver arrived event
        socketManager.onDriverArrived = { [self] in
            withAnimation {
                rideState = .driverArrived
            }
        }
        
        // Listen for ride started event
        socketManager.onRideStarted = { [self] in
            withAnimation {
                rideState = .rideInProgress
            }
            // Clear pickup marker and draw route to destination
            pickupMarker?.map = nil
            if let driverCoord = driverCoordinate, let destCoord = destinationCoordinate {
                addDestinationMarker(at: destCoord)
                drawRouteToDestination(from: driverCoord, to: destCoord)
                fitCameraToShowRouteToDestination(driverCoord: driverCoord, destCoord: destCoord)
            }
        }
        
        // Listen for ride completed event
        socketManager.onRideCompleted = { [self] in
            withAnimation {
                rideState = .rideCompleted
            }
        }
    }
    
    // MARK: - Map Markers
    
    private func addDriverMarker(at coordinate: CLLocationCoordinate2D) {
        driverMarker?.map = nil
        
        let marker = GMSMarker(position: coordinate)
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        // Use car_pin image for driver
        if let carImage = UIImage(named: "car_pin") {
            let scaledImage = carImage.scaledTo(size: CGSize(width: 50, height: 50))
            marker.icon = scaledImage
        } else {
            marker.icon = GMSMarker.markerImage(with: .systemBlue)
        }
        
        marker.map = mapView
        driverMarker = marker
    }
    
    private func addPickupMarker(at coordinate: CLLocationCoordinate2D) {
        pickupMarker?.map = nil
        
        let marker = GMSMarker(position: coordinate)
        marker.title = "Pickup"
        
        if let pinImage = UIImage(named: "source_dest_pin") {
            let scaledImage = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
            marker.icon = scaledImage
        } else {
            marker.icon = GMSMarker.markerImage(with: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0))
        }
        
        marker.map = mapView
        pickupMarker = marker
    }
    
    private func addDestinationMarker(at coordinate: CLLocationCoordinate2D) {
        destinationMarker?.map = nil
        
        let marker = GMSMarker(position: coordinate)
        marker.title = "Destination"
        
        if let pinImage = UIImage(named: "source_dest_pin") {
            let scaledImage = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
            marker.icon = scaledImage
        } else {
            marker.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
        }
        
        marker.map = mapView
        destinationMarker = marker
    }
    
    private func updateDriverMarkerPosition(latitude: Double, longitude: Double) {
        let newPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Animate marker movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        driverMarker?.position = newPosition
        CATransaction.commit()
        
        // Redraw route based on current state
        if rideState == .rideInProgress {
            // Route to destination when ride is in progress
            if let destCoord = destinationCoordinate {
                drawRouteToDestination(from: newPosition, to: destCoord)
            }
        } else {
            // Route to pickup before ride starts
            if let pickupCoord = pickupCoordinate {
                drawRouteFromDriverToPickup(from: newPosition, to: pickupCoord)
            }
        }
    }
    
    // MARK: - Route Drawing
    
    private func drawRouteFromDriverToPickup(from driverCoord: CLLocationCoordinate2D, to pickupCoord: CLLocationCoordinate2D) {
        // Clear existing route
        routePolyline?.map = nil
        
        // Fetch directions and draw route
        locationManager.fetchDirections(from: driverCoord, to: pickupCoord) { [self] path, _, _ in
            DispatchQueue.main.async {
                if let path = path {
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0) // Green
                    polyline.map = self.mapView
                    self.routePolyline = polyline
                } else {
                    // Fallback to straight line
                    let fallbackPath = GMSMutablePath()
                    fallbackPath.add(driverCoord)
                    fallbackPath.add(pickupCoord)
                    
                    let polyline = GMSPolyline(path: fallbackPath)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                    polyline.map = self.mapView
                    self.routePolyline = polyline
                }
            }
        }
    }
    
    private func drawRouteToDestination(from driverCoord: CLLocationCoordinate2D, to destCoord: CLLocationCoordinate2D) {
        // Clear existing route
        routePolyline?.map = nil
        
        // Fetch directions and draw route to destination
        locationManager.fetchDirections(from: driverCoord, to: destCoord) { [self] path, _, _ in
            DispatchQueue.main.async {
                if let path = path {
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0) // Green
                    polyline.map = self.mapView
                    self.routePolyline = polyline
                } else {
                    // Fallback to straight line
                    let fallbackPath = GMSMutablePath()
                    fallbackPath.add(driverCoord)
                    fallbackPath.add(destCoord)
                    
                    let polyline = GMSPolyline(path: fallbackPath)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                    polyline.map = self.mapView
                    self.routePolyline = polyline
                }
            }
        }
    }
    
    private func fitCameraToShowRoute(driverCoord: CLLocationCoordinate2D, pickupCoord: CLLocationCoordinate2D) {
        let bounds = GMSCoordinateBounds()
            .includingCoordinate(driverCoord)
            .includingCoordinate(pickupCoord)
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        mapView.animate(with: update)
    }
    
    private func fitCameraToShowRouteToDestination(driverCoord: CLLocationCoordinate2D, destCoord: CLLocationCoordinate2D) {
        let bounds = GMSCoordinateBounds()
            .includingCoordinate(driverCoord)
            .includingCoordinate(destCoord)
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
        mapView.animate(with: update)
    }
    
    // MARK: - Actions
    
    private func cancelRide() {
        socketManager.cancelRideSearch()
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
        // For now, just call emergency
        if let url = URL(string: "tel://911") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Driver En Route Map View
struct DriverEnRouteMapView: UIViewRepresentable {
    @Binding var mapView: GMSMapView
    @Binding var cameraPosition: GMSCameraPosition
    var driverCoordinate: CLLocationCoordinate2D?
    var pickupCoordinate: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> GMSMapView {
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cameraPosition)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false
        mapView.settings.compassButton = false
        
        MapStyleHelper.applyCustomStyle(to: mapView)
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Camera updates handled externally
    }
}

// MARK: - RoundedCorner Extension for specific corners
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
//        clipShape(RoundedCorner(radius: radius, corners: corners))
//    }
//}

//struct RoundedCorner: Shape {
//    var radius: CGFloat = .infinity
//    var corners: UIRectCorner = .allCorners
//    
//    func path(in rect: CGRect) -> Path {
//        let path = UIBezierPath(
//            roundedRect: rect,
//            byRoundingCorners: corners,
//            cornerRadii: CGSize(width: radius, height: radius)
//        )
//        return Path(path.cgPath)
//    }
//}

#Preview {
    DriverEnRouteScreen(
        bottomSheetState: .constant(.driverEnRoute)
    )
}
