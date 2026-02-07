//
//  DriverMapView.swift
//  Hezzni
//
//  Custom Map View for Driver with custom pins, route drawing, and ripple animation
//

import SwiftUI
import GoogleMaps
import CoreLocation

// MARK: - Driver Map View
struct DriverMapView: UIViewRepresentable {
    @Binding var mapView: GMSMapView
    @Binding var cameraPosition: GMSCameraPosition
    
    // Driver location
    var driverLocation: CLLocationCoordinate2D?
    
    // Pickup and destination for route
    var pickupLocation: CLLocationCoordinate2D?
    var destinationLocation: CLLocationCoordinate2D?
    
    // Whether to show route
    var showRoute: Bool = false
    
    // Whether driver is online/waiting (for ripple animation)
    var isWaitingForRequests: Bool = false
    
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
        // Update camera
        uiView.animate(to: cameraPosition)
        
        // Update driver marker
        context.coordinator.updateDriverMarker(on: uiView, at: driverLocation, isWaiting: isWaitingForRequests)
        
        // Update routes and pins
        if showRoute, let pickup = pickupLocation, let destination = destinationLocation, let driver = driverLocation {
            context.coordinator.drawRoutes(on: uiView, driverLocation: driver, pickupLocation: pickup, destinationLocation: destination)
        } else {
            context.coordinator.clearRoutes(on: uiView)
        }
    }
    
    class Coordinator: NSObject {
        var parent: DriverMapView
        
        // Markers
        private var driverMarker: GMSMarker?
        private var pickupMarker: GMSMarker?
        private var destinationMarker: GMSMarker?
        
        // Polylines
        private var driverToPickupPolyline: GMSPolyline?
        private var pickupToDestinationPolyline: GMSPolyline?
        
        // Ripple animation views
        private var rippleViews: [UIView] = []
        private var rippleTimer: Timer?
        private var isRippleAnimating = false
        
        // Location manager for fetching directions
        private let locationManager = LocationManager()
        
        init(_ parent: DriverMapView) {
            self.parent = parent
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
            
            // Add pickup marker with source_dest_pin
            if pickupMarker == nil {
                pickupMarker = GMSMarker()
            }
            pickupMarker?.position = pickupLocation
            pickupMarker?.title = "Pickup"
            
            if let pinImage = UIImage(named: "source_dest_pin") {
                let scaledImage = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
                pickupMarker?.icon = scaledImage
            } else {
                pickupMarker?.icon = GMSMarker.markerImage(with: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0))
            }
            pickupMarker?.map = mapView
            
            // Add destination marker with source_dest_pin
            if destinationMarker == nil {
                destinationMarker = GMSMarker()
            }
            destinationMarker?.position = destinationLocation
            destinationMarker?.title = "Destination"
            
            if let pinImage = UIImage(named: "source_dest_pin") {
                let scaledImage = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
                destinationMarker?.icon = scaledImage
            } else {
                destinationMarker?.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
            }
            destinationMarker?.map = mapView
            
            // Draw route from driver to pickup (black line)
            locationManager.fetchDirections(from: driverLocation, to: pickupLocation) { [weak self] path, _, _ in
                DispatchQueue.main.async {
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
                    
                    // Fit camera to show all markers and routes
                    self?.fitCameraToShowAllMarkers(on: mapView, driver: driverLocation, pickup: pickupLocation, destination: destinationLocation)
                }
            }
            
            // Draw route from pickup to destination (green line)
            locationManager.fetchDirections(from: pickupLocation, to: destinationLocation) { [weak self] path, _, _ in
                DispatchQueue.main.async {
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
        
        private func fitCameraToShowAllMarkers(on mapView: GMSMapView, driver: CLLocationCoordinate2D, pickup: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
            let bounds = GMSCoordinateBounds()
                .includingCoordinate(driver)
                .includingCoordinate(pickup)
                .includingCoordinate(destination)
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: 80)
            mapView.animate(with: update)
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
