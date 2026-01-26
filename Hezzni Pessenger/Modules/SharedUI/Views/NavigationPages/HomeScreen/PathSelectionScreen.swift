//
//  PathSelectionScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/18/25.
//

import SwiftUI
import MapKit

struct PathSelectionScreen: View {
    @State private var isEditingPickup = false
    @State private var isChoosingOnMap = false
    @State private var pickupLocation: String = "Current Location, Marrakech"
    @State private var destinationLocation: String = "Menara Mall, Gueliz District"
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 31.6295, longitude: -7.9811),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var isLoadingPlaceName = false
    @State private var selectedCoordinate: CLLocationCoordinate2D? = nil
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                if isChoosingOnMap {
                    ZStack {
                        Map(coordinateRegion: $mapRegion, interactionModes: .all)
                            .edgesIgnoringSafeArea(.all)
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(Color.green)
                            .offset(y: -20)
                    }
                    Spacer()
                    VStack {
                        Button(action: chooseLocationOnMap) {
                            if isLoadingPlaceName {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .frame(maxWidth: .infinity)
                            } else {
                                Text("Choose")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                } else {
                    VStack(spacing: 0) {
                        HStack {
                            Button(action: { /* handle back */ }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                            }
                            Spacer()
                            Text("Car")
                                .font(.title2).bold()
                                .foregroundColor(.black)
                            Spacer()
                            Spacer().frame(width: 24)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        VStack(spacing: 0) {
                            Button(action: { isEditingPickup = true }) {
                                HStack {
                                    Image(systemName: "circle.fill")
                                        .foregroundColor(Color.green.opacity(0.5))
                                    VStack(alignment: .leading) {
                                        Text("Pickup")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        Text(pickupLocation)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                            Divider()
                            HStack {
                                Image(systemName: "mappin")
                                    .foregroundColor(Color.green.opacity(0.5))
                                VStack(alignment: .leading) {
                                    Text("Destination")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text(destinationLocation)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                        .padding(.horizontal)
                        .padding(.top, 16)
                        if isEditingPickup {
                            Button(action: { isChoosingOnMap = true; isEditingPickup = false }) {
                                HStack {
                                    Image(systemName: "mappin")
                                        .foregroundColor(Color.green.opacity(0.7))
                                    Text("Choose on Map")
                                        .font(.headline)
                                        .foregroundColor(Color.green)
                                }
                                .padding(.leading, 24)
                                .padding(.top, 16)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(isChoosingOnMap ? .all : .bottom)
        }
    }
    
    private func chooseLocationOnMap() {
        isLoadingPlaceName = true
        let center = mapRegion.center
        let location = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                isLoadingPlaceName = false
                if let placemark = placemarks?.first {
                    let name = placemark.name ?? "Selected Location"
                    let city = placemark.locality ?? ""
                    let fullName = city.isEmpty ? name : "\(name), \(city)"
                    pickupLocation = fullName
                } else {
                    pickupLocation = "Selected Location"
                }
                isChoosingOnMap = false
            }
        }
    }
}

// Preview
struct PathSelectionScreen_Previews: PreviewProvider {
    static var previews: some View {
        PathSelectionScreen()
    }
}
