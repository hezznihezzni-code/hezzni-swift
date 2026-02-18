//
//  DriverMapView.swift
//  Hezzni
//
//  Custom Map View for Driver with custom pins, route drawing, and ripple animation
//

import SwiftUI
import GoogleMaps
import CoreLocation

// MARK: - Route Display Mode
enum DriverRouteDisplayMode {
    case none                    // No route displayed
    case driverToPickup          // Show route from driver to pickup only
    case driverToPickupAndDestination  // Show both routes (when ride request received)
    case driverToDestination     // Show route from driver to destination only (ride in progress)
}

// MARK: - Driver Map View
struct DriverMapView: UIViewRepresentable {
    @Binding var mapView: GMSMapView
    @Binding var cameraPosition: GMSCameraPosition
    
    // Driver location
    var driverLocation: CLLocationCoordinate2D?
    
    // Pickup and destination for route
    var pickupLocation: CLLocationCoordinate2D?
    var destinationLocation: CLLocationCoordinate2D?
    
    // Address strings for marker info cards
    var pickupAddressText: String = ""
    var destinationAddressText: String = ""
    
    // Route display mode (replaces simple showRoute bool)
    var routeDisplayMode: DriverRouteDisplayMode = .none
    
    // Legacy support - deprecated, use routeDisplayMode instead
    var showRoute: Bool = false
    
    // Whether driver is online/waiting (for ripple animation)
    var isWaitingForRequests: Bool = false
    
    // Distance callbacks for button enabling - use Binding for proper SwiftUI state updates
    @Binding var distanceToPickup: Double
    @Binding var distanceToDestination: Double
    
    // Route polylines stored in coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> GMSMapView {
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cameraPosition)
        mapView.isMyLocationEnabled = false // Disable default blue dot
        mapView.settings.myLocationButton = false
        
        // Apply custom style
        MapStyleHelper.applyCustomStyle(to: mapView)
        
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        // Update driver marker (always updates smoothly)
        context.coordinator.updateDriverMarker(on: uiView, at: driverLocation, isWaiting: isWaitingForRequests)
        
        // Calculate distances if we have driver location - update Bindings directly
        // Note: Use coordinator to avoid modifying state during view update
        if let driver = driverLocation {
            if let pickup = pickupLocation {
                let distance = calculateDistance(from: driver, to: pickup)
                print("📍 Distance to pickup: \(distance)m (driver: \(driver.latitude),\(driver.longitude) -> pickup: \(pickup.latitude),\(pickup.longitude))")
                // Store in coordinator to update after view update completes
                context.coordinator.pendingDistanceToPickup = distance
            } else {
                print("⚠️ No pickup location available for distance calculation")
            }
            if let destination = destinationLocation {
                let distance = calculateDistance(from: driver, to: destination)
                print("📍 Distance to destination: \(distance)m")
                // Store in coordinator to update after view update completes
                context.coordinator.pendingDistanceToDestination = distance
            }
        } else {
            print("⚠️ No driver location available for distance calculation")
        }
        
        // Defer binding updates to after view update using DispatchQueue
        let coordinator = context.coordinator
        DispatchQueue.main.async {
            if let pickup = coordinator.pendingDistanceToPickup {
                self.distanceToPickup = pickup
                coordinator.pendingDistanceToPickup = nil
            }
            if let destination = coordinator.pendingDistanceToDestination {
                self.distanceToDestination = destination
                coordinator.pendingDistanceToDestination = nil
            }
        }
        
        // Handle route display based on mode
        let effectiveMode: DriverRouteDisplayMode
        if routeDisplayMode != .none {
            effectiveMode = routeDisplayMode
        } else if showRoute {
            // Legacy support
            effectiveMode = .driverToPickupAndDestination
        } else {
            effectiveMode = .none
        }
        
        // Check if we need to redraw the route (prevents flickering)
        let needsRedraw = context.coordinator.shouldRedrawRoute(
            mode: effectiveMode,
            driverLocation: driverLocation,
            pickup: pickupLocation, 
            destination: destinationLocation
        )
        
        // Only redraw route if necessary
        if needsRedraw {
            // Only re-fit camera when route mode changes, not on driver movement redraws
            let modeChanged = context.coordinator.currentRouteMode != effectiveMode
            if modeChanged {
                context.coordinator.resetCameraFit()
            }
            context.coordinator.updateRouteCache(mode: effectiveMode, driverLocation: driverLocation, pickup: pickupLocation, destination: destinationLocation)
            
            switch effectiveMode {
            case .none:
                context.coordinator.clearRoutes(on: uiView)
                
            case .driverToPickup:
                if let pickup = pickupLocation, let driver = driverLocation {
                    context.coordinator.drawRouteToPickup(on: uiView, driverLocation: driver, pickupLocation: pickup)
                } else {
                    context.coordinator.clearRoutes(on: uiView)
                }
                
            case .driverToPickupAndDestination:
                if let pickup = pickupLocation, let destination = destinationLocation, let driver = driverLocation {
                    context.coordinator.drawRoutes(on: uiView, driverLocation: driver, pickupLocation: pickup, destinationLocation: destination)
                } else {
                    context.coordinator.clearRoutes(on: uiView)
                }
                
            case .driverToDestination:
                if let destination = destinationLocation, let driver = driverLocation {
                    context.coordinator.drawRouteToDestination(on: uiView, driverLocation: driver, destinationLocation: destination)
                } else {
                    context.coordinator.clearRoutes(on: uiView)
                }
            }
        }
        
        // Only update camera if no route is being displayed
        if effectiveMode == .none {
            uiView.animate(to: cameraPosition)
        }
    }
    
    // Calculate distance in meters between two coordinates
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    class Coordinator: NSObject {
        var parent: DriverMapView
        
        // Pending distance updates (to avoid modifying state during view update)
        var pendingDistanceToPickup: Double?
        var pendingDistanceToDestination: Double?
        
        // Markers
        private var driverMarker: GMSMarker?
        private var pickupMarker: GMSMarker?
        private var destinationMarker: GMSMarker?
        
        // Polylines
        private var driverToPickupPolyline: GMSPolyline?
        private var pickupToDestinationPolyline: GMSPolyline?
        
        // Route caching - to prevent redrawing on every update
        var currentRouteMode: DriverRouteDisplayMode = .none
        private var lastDriverLocation: CLLocationCoordinate2D?
        private var lastPickupLocation: CLLocationCoordinate2D?
        private var lastDestinationLocation: CLLocationCoordinate2D?
        private var isDrawingRoute: Bool = false  // Prevent concurrent route draws
        private var hasFittedCamera: Bool = false  // Only fit camera once per route
        
        // Ripple animation views
        private var rippleViews: [UIView] = []
        private var rippleTimer: Timer?
        private var isRippleAnimating = false
        
        // Location manager for fetching directions
        private let locationManager = LocationManager()
        
        init(_ parent: DriverMapView) {
            self.parent = parent
        }
        
        // Check if route needs to be redrawn (mode changed, driver moved, or destination changed)
        func shouldRedrawRoute(mode: DriverRouteDisplayMode, driverLocation: CLLocationCoordinate2D?, pickup: CLLocationCoordinate2D?, destination: CLLocationCoordinate2D?) -> Bool {
            // Always redraw if mode changed
            if mode != currentRouteMode {
                return true
            }
            
            // Check if driver moved significantly (more than 100m) - triggers route redraw
            // for any mode that includes the driver's position as a route endpoint
            if mode == .driverToPickup || mode == .driverToPickupAndDestination || mode == .driverToDestination {
                if let newDriver = driverLocation, let oldDriver = lastDriverLocation {
                    let distance = CLLocation(latitude: newDriver.latitude, longitude: newDriver.longitude)
                        .distance(from: CLLocation(latitude: oldDriver.latitude, longitude: oldDriver.longitude))
                    if distance > 100 {
                        return true
                    }
                } else if (driverLocation == nil) != (lastDriverLocation == nil) {
                    return true
                }
            }
            
            // Check if pickup changed significantly (more than 50m)
            if let newPickup = pickup, let oldPickup = lastPickupLocation {
                let distance = CLLocation(latitude: newPickup.latitude, longitude: newPickup.longitude)
                    .distance(from: CLLocation(latitude: oldPickup.latitude, longitude: oldPickup.longitude))
                if distance > 50 {
                    return true
                }
            } else if (pickup == nil) != (lastPickupLocation == nil) {
                return true
            }
            
            // Check if destination changed significantly
            if let newDest = destination, let oldDest = lastDestinationLocation {
                let distance = CLLocation(latitude: newDest.latitude, longitude: newDest.longitude)
                    .distance(from: CLLocation(latitude: oldDest.latitude, longitude: oldDest.longitude))
                if distance > 50 {
                    return true
                }
            } else if (destination == nil) != (lastDestinationLocation == nil) {
                return true
            }
            
            return false
        }
        
        func updateRouteCache(mode: DriverRouteDisplayMode, driverLocation: CLLocationCoordinate2D?, pickup: CLLocationCoordinate2D?, destination: CLLocationCoordinate2D?) {
            currentRouteMode = mode
            lastDriverLocation = driverLocation
            lastPickupLocation = pickup
            lastDestinationLocation = destination
        }
        
        func resetCameraFit() {
            hasFittedCamera = false
        }
        
        func updateDriverMarker(on mapView: GMSMapView, at location: CLLocationCoordinate2D?, isWaiting: Bool) {
            guard let location = location else {
                driverMarker?.map = nil
                driverMarker = nil
                stopRippleAnimation()
                return
            }
            
            if driverMarker == nil {
                driverMarker = GMSMarker()
                driverMarker?.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            }
            
            driverMarker?.position = location
            
            // Use custom driver pin image
            if let pinImage = UIImage(named: "driver_current_pin") {
                // Scale the image to appropriate size
                let scaledImage = pinImage.scaledTo(size: CGSize(width: 50, height: 50))
                driverMarker?.icon = scaledImage
            } else {
                // Fallback to default marker
                driverMarker?.icon = GMSMarker.markerImage(with: .systemBlue)
            }
            
            driverMarker?.map = mapView
            
            // Handle ripple animation
            if isWaiting {
                startRippleAnimation(on: mapView, at: location)
            } else {
                stopRippleAnimation()
            }
        }
        
        func drawRoutes(on mapView: GMSMapView, driverLocation: CLLocationCoordinate2D, pickupLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
            // Clear existing routes first
            clearRoutes(on: mapView)
            
            let pickupAddress = parent.pickupAddressText
            let destAddress = parent.destinationAddressText
            
            // Add pickup marker with passenger_pickup pin and info card
            if pickupMarker == nil {
                pickupMarker = GMSMarker()
            }
            pickupMarker?.position = pickupLocation
            pickupMarker?.title = "Pickup"
            
            // Draw route from driver to pickup (black line) — need distance/duration for pickup info card
            locationManager.fetchDirections(from: driverLocation, to: pickupLocation) { [weak self] path, distanceText, durationText in
                DispatchQueue.main.async {
                    // Update pickup marker with info card showing distance/duration from driver
                    if let pinImage = UIImage(named: "passenger_pickup") ?? UIImage(named: "pickup_pin") {
                        let scaledPin = pinImage.scaledTo(size: CGSize(width: 26, height: 26))
                        let markerView = self?.createPickupMarkerView(
                            title: "Pickup",
                            subtitle: pickupAddress,
                            color: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0),
                            pinImage: scaledPin
                        )
                        self?.pickupMarker?.iconView = markerView
                        self?.pickupMarker?.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                    } else {
                        self?.pickupMarker?.icon = GMSMarker.markerImage(with: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0))
                    }
                    self?.pickupMarker?.map = mapView
                    
                    if let path = path {
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = .black
                        polyline.map = mapView
                        self?.driverToPickupPolyline = polyline
                    } else {
                        // Fallback to straight line
                        let fallbackPath = GMSMutablePath()
                        fallbackPath.add(driverLocation)
                        fallbackPath.add(pickupLocation)
                        
                        let polyline = GMSPolyline(path: fallbackPath)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = .black
                        polyline.map = mapView
                        self?.driverToPickupPolyline = polyline
                    }
                    
                    // Fit camera only once when route is first drawn
                    if self?.hasFittedCamera == false {
                        self?.fitCameraToShowAllMarkers(on: mapView, driver: driverLocation, pickup: pickupLocation, destination: destinationLocation)
                        self?.hasFittedCamera = true
                    }
                }
            }
            
            // Draw route from pickup to destination (green line) — need distance/duration for destination info card
            locationManager.fetchDirections(from: pickupLocation, to: destinationLocation) { [weak self] path, distanceText, durationText in
                DispatchQueue.main.async {
                    // Add destination marker with info card
                    if self?.destinationMarker == nil {
                        self?.destinationMarker = GMSMarker()
                    }
                    self?.destinationMarker?.position = destinationLocation
                    self?.destinationMarker?.title = "Destination"
                    
                    if let pinImage = UIImage(named: "source_dest_pin") {
                        let scaledPin = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
                        let markerView = self?.createDestinationMarkerView(
                            title: "Destination",
                            subtitle: destAddress,
                            distance: distanceText ?? "N/A",
                            duration: durationText ?? "N/A",
                            color: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0),
                            pinImage: scaledPin
                        )
                        self?.destinationMarker?.iconView = markerView
                        self?.destinationMarker?.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                    } else {
                        self?.destinationMarker?.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
                    }
                    self?.destinationMarker?.map = mapView
                    
                    if let path = path {
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                        polyline.map = mapView
                        self?.pickupToDestinationPolyline = polyline
                    } else {
                        // Fallback to straight line
                        let fallbackPath = GMSMutablePath()
                        fallbackPath.add(pickupLocation)
                        fallbackPath.add(destinationLocation)
                        
                        let polyline = GMSPolyline(path: fallbackPath)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                        polyline.map = mapView
                        self?.pickupToDestinationPolyline = polyline
                    }
                }
            }
        }
        
        func clearRoutes(on mapView: GMSMapView) {
            driverToPickupPolyline?.map = nil
            driverToPickupPolyline = nil
            
            pickupToDestinationPolyline?.map = nil
            pickupToDestinationPolyline = nil
            
            pickupMarker?.map = nil
            pickupMarker = nil
            
            destinationMarker?.map = nil
            destinationMarker = nil
        }
        
        // Draw route from driver to pickup only (for accepted ride, going to pickup)
        func drawRouteToPickup(on mapView: GMSMapView, driverLocation: CLLocationCoordinate2D, pickupLocation: CLLocationCoordinate2D) {
            // Clear existing routes first
            clearRoutes(on: mapView)
            
            let pickupAddress = parent.pickupAddressText
            
            // Add pickup marker
            if pickupMarker == nil {
                pickupMarker = GMSMarker()
            }
            pickupMarker?.position = pickupLocation
            pickupMarker?.title = "Pickup"
            
            // Draw route from driver to pickup (black line)
            locationManager.fetchDirections(from: driverLocation, to: pickupLocation) { [weak self] path, distanceText, durationText in
                DispatchQueue.main.async {
                    // Update pickup marker with info card
                    if let pinImage = UIImage(named: "passenger_pickup") ?? UIImage(named: "pickup_pin") {
                        let scaledPin = pinImage.scaledTo(size: CGSize(width: 26, height: 26))
                        let markerView = self?.createPickupMarkerView(
                            title: "Pickup",
                            subtitle: pickupAddress,
                            color: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0),
                            pinImage: scaledPin
                        )
                        self?.pickupMarker?.iconView = markerView
                        self?.pickupMarker?.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                    } else {
                        self?.pickupMarker?.icon = GMSMarker.markerImage(with: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0))
                    }
                    self?.pickupMarker?.map = mapView
                    
                    if let path = path {
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = .black
                        polyline.map = mapView
                        self?.driverToPickupPolyline = polyline
                    } else {
                        // Fallback to straight line
                        let fallbackPath = GMSMutablePath()
                        fallbackPath.add(driverLocation)
                        fallbackPath.add(pickupLocation)
                        
                        let polyline = GMSPolyline(path: fallbackPath)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = .black
                        polyline.map = mapView
                        self?.driverToPickupPolyline = polyline
                    }
                    
                    // Fit camera only once when route is first drawn
                    if self?.hasFittedCamera == false {
                        self?.fitCameraToShowTwoPoints(on: mapView, point1: driverLocation, point2: pickupLocation)
                        self?.hasFittedCamera = true
                    }
                }
            }
        }
        
        // Draw route from driver to destination only (for ride in progress)
        func drawRouteToDestination(on mapView: GMSMapView, driverLocation: CLLocationCoordinate2D, destinationLocation: CLLocationCoordinate2D) {
            // Clear existing routes first
            clearRoutes(on: mapView)
            
            let destAddress = parent.destinationAddressText
            
            // Add destination marker
            if destinationMarker == nil {
                destinationMarker = GMSMarker()
            }
            destinationMarker?.position = destinationLocation
            destinationMarker?.title = "Destination"
            
            // Draw route from driver to destination (green line)
            locationManager.fetchDirections(from: driverLocation, to: destinationLocation) { [weak self] path, distanceText, durationText in
                DispatchQueue.main.async {
                    // Update destination marker with info card
                    if let pinImage = UIImage(named: "source_dest_pin") {
                        let scaledPin = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
                        let markerView = self?.createDestinationMarkerView(
                            title: "Destination",
                            subtitle: destAddress,
                            distance: distanceText ?? "N/A",
                            duration: durationText ?? "N/A",
                            color: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0),
                            pinImage: scaledPin
                        )
                        self?.destinationMarker?.iconView = markerView
                        self?.destinationMarker?.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                    } else {
                        self?.destinationMarker?.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
                    }
                    self?.destinationMarker?.map = mapView
                    
                    if let path = path {
                        let polyline = GMSPolyline(path: path)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                        polyline.map = mapView
                        self?.pickupToDestinationPolyline = polyline
                    } else {
                        // Fallback to straight line
                        let fallbackPath = GMSMutablePath()
                        fallbackPath.add(driverLocation)
                        fallbackPath.add(destinationLocation)
                        
                        let polyline = GMSPolyline(path: fallbackPath)
                        polyline.strokeWidth = 5
                        polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                        polyline.map = mapView
                        self?.pickupToDestinationPolyline = polyline
                    }
                    
                    // Fit camera only once when route is first drawn
                    if self?.hasFittedCamera == false {
                        self?.fitCameraToShowTwoPoints(on: mapView, point1: driverLocation, point2: destinationLocation)
                        self?.hasFittedCamera = true
                    }
                }
            }
        }
        
        private func fitCameraToShowTwoPoints(on mapView: GMSMapView, point1: CLLocationCoordinate2D, point2: CLLocationCoordinate2D) {
            let bounds = GMSCoordinateBounds()
                .includingCoordinate(point1)
                .includingCoordinate(point2)
            
            let padding = UIEdgeInsets(
                top: 100,
                left: 50,
                bottom: 300 + 50, // Extra padding for bottom sheet
                right: 50
            )
            let update = GMSCameraUpdate.fit(bounds, with: padding)
            mapView.animate(with: update)
        }
        
        private func fitCameraToShowAllMarkers(on mapView: GMSMapView, driver: CLLocationCoordinate2D, pickup: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
            let bounds = GMSCoordinateBounds()
                .includingCoordinate(driver)
                .includingCoordinate(pickup)
                .includingCoordinate(destination)
            
            let padding = UIEdgeInsets(
                top: 100,
                left: 50,
                bottom: 300 + 50, // Extra padding for bottom sheet
                right: 50
            )
            let update = GMSCameraUpdate.fit(bounds, with: padding)
            mapView.animate(with: update)
        }
        
        // MARK: - Marker View Builders
        
        func createPickupMarkerView(title: String, subtitle: String, color: UIColor, pinImage: UIImage?) -> UIView {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 70))
            containerView.backgroundColor = .clear
            
            // Card view above the pin
            let cardView = UIView(frame: CGRect(x: 50, y: 0, width: 100, height: 40))
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 8
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowOpacity = 0.15
            cardView.layer.shadowRadius = 4
            
            // Title label
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.textColor = .gray
            
            // Subtitle label (address)
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
            subtitleLabel.textColor = .black
            subtitleLabel.numberOfLines = 2
            subtitleLabel.lineBreakMode = .byTruncatingTail
            
            let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stackView.axis = .vertical
            stackView.spacing = 2
            stackView.frame = CGRect(x: 8, y: 4, width: 84, height: 32)
            
            cardView.addSubview(stackView)
            
            // Pin icon below card, centered
            let pinImageView = UIImageView(frame: CGRect(x: 92, y: 40, width: 16, height: 20))
            if let pinImage = pinImage {
                pinImageView.image = pinImage
            }
            pinImageView.contentMode = .scaleAspectFit
            
            containerView.addSubview(cardView)
            containerView.addSubview(pinImageView)
            
            return containerView
        }
        
        func createDestinationMarkerView(title: String, subtitle: String, distance: String, duration: String, color: UIColor, pinImage: UIImage?) -> UIView {
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 70))
            containerView.backgroundColor = .clear
            
            // Card view above the pin
            let cardView = UIView(frame: CGRect(x: 4, y: 0, width: 192, height: 48))
            cardView.backgroundColor = .white
            cardView.layer.cornerRadius = 8
            cardView.layer.shadowColor = UIColor.black.cgColor
            cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer.shadowOpacity = 0.15
            cardView.layer.shadowRadius = 4
            
            // Distance box
            let distanceBox = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            distanceBox.backgroundColor = UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 0.2)
            
            let distanceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            distanceLabel.text = distance
            distanceLabel.font = UIFont.boldSystemFont(ofSize: 15)
            distanceLabel.textColor = UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0)
            distanceLabel.textAlignment = .center
            distanceLabel.numberOfLines = 2
            distanceBox.addSubview(distanceLabel)
            
            // Duration box
            let durationBox = UIView(frame: CGRect(x: 40, y: 0, width: 40, height: 40))
            durationBox.backgroundColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 0.2)
            
            let durationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            durationLabel.text = duration
            durationLabel.font = UIFont.boldSystemFont(ofSize: 15)
            durationLabel.textColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
            durationLabel.textAlignment = .center
            durationLabel.numberOfLines = 2
            durationBox.addSubview(durationLabel)
            
            // Destination info (right side)
            let destinationStack = UIStackView()
            destinationStack.axis = .vertical
            destinationStack.spacing = 2
            destinationStack.frame = CGRect(x: 88, y: 8, width: 96, height: 32)
            
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = UIFont.systemFont(ofSize: 10)
            titleLabel.textColor = .gray
            
            let subtitleLabel = UILabel()
            subtitleLabel.text = subtitle
            subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
            subtitleLabel.textColor = .black
            subtitleLabel.numberOfLines = 2
            subtitleLabel.lineBreakMode = .byTruncatingTail
            
            destinationStack.addArrangedSubview(titleLabel)
            destinationStack.addArrangedSubview(subtitleLabel)
            
            cardView.addSubview(distanceBox)
            cardView.addSubview(durationBox)
            cardView.addSubview(destinationStack)
            
            // Pin icon below card, centered
            let pinImageView = UIImageView(frame: CGRect(x: 88, y: 40, width: 16, height: 20))
            if let pinImage = pinImage {
                pinImageView.image = pinImage
            }
            pinImageView.contentMode = .scaleAspectFit
            
            containerView.addSubview(cardView)
            containerView.addSubview(pinImageView)
            
            return containerView
        }
        
        // MARK: - Ripple Animation
        
        private func startRippleAnimation(on mapView: GMSMapView, at location: CLLocationCoordinate2D) {
            guard !isRippleAnimating else { return }
            isRippleAnimating = true
            
            // Start timer to create ripple waves
            rippleTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
                self?.createRippleWave(on: mapView, at: location)
            }
            
            // Create initial ripple
            createRippleWave(on: mapView, at: location)
        }
        
        private func stopRippleAnimation() {
            rippleTimer?.invalidate()
            rippleTimer = nil
            isRippleAnimating = false
            
            // Remove all ripple views
            for view in rippleViews {
                view.removeFromSuperview()
            }
            rippleViews.removeAll()
        }
        
        private func createRippleWave(on mapView: GMSMapView, at location: CLLocationCoordinate2D) {
            // Convert coordinate to point on screen
            let point = mapView.projection.point(for: location)
            
            // Create ripple circle
            let rippleSize: CGFloat = 60
            let rippleView = UIView(frame: CGRect(x: point.x - rippleSize/2, y: point.y - rippleSize/2, width: rippleSize, height: rippleSize))
            rippleView.backgroundColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 0.4)
            rippleView.layer.cornerRadius = rippleSize / 2
            rippleView.alpha = 0.8
            
            mapView.addSubview(rippleView)
            rippleViews.append(rippleView)
            
            // Animate ripple expanding and fading
            UIView.animate(withDuration: 2.0, delay: 0, options: [.curveEaseOut], animations: {
                rippleView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
                rippleView.alpha = 0
            }) { [weak self] _ in
                rippleView.removeFromSuperview()
                self?.rippleViews.removeAll { $0 == rippleView }
            }
        }
    }
}

// MARK: - UIImage Extension for Scaling
extension UIImage {
    func scaledTo(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
