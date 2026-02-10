//
//  GoogleMapView.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/9/25.
//

import SwiftUI
import GoogleMaps
internal import Combine
// The rest of your existing code remains the same...
// GoogleMapView, LocationManager, ServiceCardHorizontal, etc.
struct GoogleMapView: UIViewRepresentable {
    @Binding var mapView: GMSMapView
    @Binding var cameraPosition: GMSCameraPosition
    
    func makeUIView(context: Context) -> GMSMapView {
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: cameraPosition)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = false  // Already set
        
        // Hide Google logo and other UI elements
        mapView.settings.compassButton = false
        mapView.settings.indoorPicker = false
        mapView.settings.rotateGestures = true
        mapView.settings.scrollGestures = true
        mapView.settings.tiltGestures = false
        mapView.settings.zoomGestures = true
        
        // Move Google logo to bottom left (behind your sheet)
        mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        // Apply custom style
        MapStyleHelper.applyCustomStyle(to: mapView)
        
        return mapView
    }
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.animate(to: cameraPosition)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: GoogleMapView
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
    }
}


struct MapWithMarkerOverlay: View {
    @Binding var mapView: GMSMapView
    @Binding var cameraPosition: GMSCameraPosition
    @Binding var pickupLat: Double
    @Binding var pickupLong: Double
    @Binding var destLat: Double
    @Binding var destLong: Double
    @State private var pickupPoint: CGPoint = .zero
    @State private var destPoint: CGPoint = .zero

    var pickupCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: pickupLat, longitude: pickupLong)
    }
    var destCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: destLat, longitude: destLong)
    }

    var body: some View {
        ZStack {
            GoogleMapView(mapView: $mapView, cameraPosition: $cameraPosition)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    addMarkers()
                    updateOverlayPositions()
                }
                .onChange(of: mapView.camera.target) { _ in
                    updateOverlayPositions()
                }
                .onChange(of: pickupLat) { _ in
                    addMarkers()
                    updateOverlayPositions()
                }
                .onChange(of: pickupLong) { _ in
                    addMarkers()
                    updateOverlayPositions()
                }
                .onChange(of: destLat) { _ in
                    addMarkers()
                    updateOverlayPositions()
                }
                .onChange(of: destLong) { _ in
                    addMarkers()
                    updateOverlayPositions()
                }

            if pickupPoint != .zero {
                VStack {
                    Text("Pickup Widget")
                        .padding(8)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(8)
                }
                .position(x: pickupPoint.x, y: pickupPoint.y - 40)
            }

            if destPoint != .zero {
                VStack {
                    Text("Destination Widget")
                        .padding(8)
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                .position(x: destPoint.x, y: destPoint.y - 40)
            }
        }
    }

    private func addMarkers() {
        mapView.clear()
        let pickupMarker = GMSMarker(position: pickupCoordinate)
        pickupMarker.map = mapView
        let destMarker = GMSMarker(position: destCoordinate)
        destMarker.map = mapView
    }

    private func updateOverlayPositions() {
        DispatchQueue.main.async {
            pickupPoint = mapView.projection.point(for: pickupCoordinate)
            destPoint = mapView.projection.point(for: destCoordinate)
        }
    }
}
