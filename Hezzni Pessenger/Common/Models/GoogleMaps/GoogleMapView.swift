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
        mapView.settings.myLocationButton = true
        
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
