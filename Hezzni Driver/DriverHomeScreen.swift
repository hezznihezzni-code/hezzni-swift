//
//  DriverHomeScreen.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 2/4/26.
//

import SwiftUI
import CoreLocation

struct DriverHomeScreen: View {
    @ObservedObject private var socketManager = DriverRideSocketManager.shared
    @StateObject private var locationManager = LocationManager()
    
    @State private var showIncomingRide = false
    @State private var showRideAcceptedAlert = false
    @State private var showRideDeclinedAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Online/Offline Toggle Header
                onlineStatusHeader
                
                Spacer()
                
                // Status Info
                statusInfoView
                
                Spacer()
                
                // Current Ride Info (if any)
                if let currentRide = socketManager.currentRide {
                    currentRideView(ride: currentRide)
                }
            }
            .padding()
            .navigationTitle("Hezzni Driver")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showIncomingRide) {
            if let request = socketManager.currentRideRequest {
                IncomingRideRequestView(
                    request: request,
                    onAccept: {
                        socketManager.acceptRide(rideRequestId: request.rideRequestId)
                        showIncomingRide = false
                    },
                    onDecline: {
                        socketManager.declineRide(rideRequestId: request.rideRequestId)
                        showIncomingRide = false
                    }
                )
            }
        }
        .alert("Ride Accepted", isPresented: $showRideAcceptedAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .alert("Could Not Accept Ride", isPresented: $showRideDeclinedAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            setupSocketCallbacks()
        }
        .onChange(of: socketManager.hasIncomingRequest) { hasRequest in
            if hasRequest {
                showIncomingRide = true
            }
        }
    }
    
    // MARK: - Views
    
    private var onlineStatusHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(socketManager.isOnline ? "You're Online" : "You're Offline")
                    .font(.headline)
                
                Text(socketManager.isOnline ? "Waiting for ride requests..." : "Go online to receive rides")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { socketManager.isOnline },
                set: { isOnline in
                    if isOnline {
                        socketManager.goOnline()
                        startLocationUpdates()
                    } else {
                        socketManager.goOffline()
                    }
                }
            ))
            .labelsHidden()
            .tint(Color(red: 0.22, green: 0.65, blue: 0.33))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(socketManager.isOnline ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
        )
    }
    
    private var statusInfoView: some View {
        VStack(spacing: 16) {
            // Connection status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: statusIcon)
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                )
            
            Text(statusText)
                .font(.title2)
                .fontWeight(.medium)
            
            if let error = socketManager.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
    }
    
    private func currentRideView(ride: AcceptRideResponse.RideDetails) -> some View {
        VStack(spacing: 12) {
            Text("Current Ride")
                .font(.headline)
            
            if let pickup = ride.pickup {
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.green)
                    Text(pickup.address)
                        .font(.subheadline)
                    Spacer()
                }
            }
            
            if let dropoff = ride.dropoff {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text(dropoff.address)
                        .font(.subheadline)
                    Spacer()
                }
            }
            
            if let price = ride.estimatedPrice {
                Text("$\(String(format: "%.2f", price))")
                    .font(.title3)
                    .fontWeight(.bold)
            }
            
            // Action buttons based on ride status
            HStack(spacing: 12) {
                if let rideId = ride.rideId {
                    Button("Arrived") {
                        socketManager.arrivedAtPickup(rideId: rideId)
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Start Ride") {
                        socketManager.startRide(rideId: rideId)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    
                    Button("Complete") {
                        socketManager.completeRide(rideId: rideId)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 4)
        )
    }
    
    // MARK: - Computed Properties
    
    private var statusColor: Color {
        switch socketManager.onlineStatus {
        case .offline:
            return .gray
        case .online:
            return Color(red: 0.22, green: 0.65, blue: 0.33)
        case .busy:
            return .orange
        }
    }
    
    private var statusIcon: String {
        switch socketManager.onlineStatus {
        case .offline:
            return "car.fill"
        case .online:
            return "antenna.radiowaves.left.and.right"
        case .busy:
            return "car.side.fill"
        }
    }
    
    private var statusText: String {
        switch socketManager.onlineStatus {
        case .offline:
            return "Offline"
        case .online:
            return "Ready for Rides"
        case .busy:
            return "On a Ride"
        }
    }
    
    // MARK: - Setup
    
    private func setupSocketCallbacks() {
        socketManager.onRideAccepted = { ride in
            alertMessage = "You've been assigned to this ride. Head to pickup!"
            showRideAcceptedAlert = true
        }
        
        socketManager.onRideAcceptFailed = { message in
            alertMessage = message
            showRideDeclinedAlert = true
        }
        
        socketManager.onRideRequestTimeout = {
            showIncomingRide = false
        }
        
        socketManager.onRideCancelled = { reason in
            alertMessage = reason ?? "The ride has been cancelled"
            showRideDeclinedAlert = true
        }
    }
    
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        
        // Send location updates every 10 seconds while online
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
            guard socketManager.isOnline else {
                timer.invalidate()
                return
            }
            
            if let location = locationManager.currentLocation {
                socketManager.updateLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        }
    }
}

// MARK: - Incoming Ride Request View

struct IncomingRideRequestView: View {
    let request: DriverRideRequest
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Header with timer
            HStack {
                Text("New Ride Request")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                // Countdown timer
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(timeRemaining) / 30)
                        .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 4)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear, value: timeRemaining)
                    
                    Text("\(timeRemaining)")
                        .font(.headline)
                        .foregroundColor(timeRemaining <= 10 ? .red : .primary)
                }
            }
            .padding(.top)
            
            Divider()
            
            // Passenger info
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.passenger.name)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", request.passenger.rating ?? 5.0))
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("$\(String(format: "%.2f", request.estimatedPrice))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    
                    Text("\(String(format: "%.1f", request.distanceKm!)) km")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            // Location details
            VStack(spacing: 12) {
                HStack(alignment: .top) {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Pickup")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(request.pickup.address)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                
                HStack(alignment: .top) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dropoff")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(request.dropoff.address)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
            )
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: onDecline) {
                    HStack {
                        Image(systemName: "xmark")
                        Text("Decline")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .cornerRadius(12)
                }
                
                Button(action: onAccept) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("Accept")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(.bottom)
        }
        .padding()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                onDecline()
            }
        }
    }
}

#Preview {
    DriverHomeScreen()
}
