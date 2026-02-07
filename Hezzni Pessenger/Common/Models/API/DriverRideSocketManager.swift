//
//  DriverRideSocketManager.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 2/4/26.
//

import Foundation
import SocketIO
internal import Combine
internal import _LocationEssentials

// MARK: - Ride Request Models for Driver

/// Represents a ride request received by the driver
/// Updated to match server's flat field format
struct DriverRideRequest: Codable, Identifiable {
    let rideRequestId: Int
    let rideOfferId: Int?
    let estimatedPrice: Double
    let distanceToPickup: Double?
    let estimatedArrivalMinutes: Int?
    let serviceTypeName: String?
    let distanceKm: Double?
    let estimatedDurationMinutes: Int?
    
    // Flat pickup fields from server
    let pickupLatitude: Double
    let pickupLongitude: Double
    let pickupAddress: String
    
    // Flat dropoff fields from server
    let dropoffLatitude: Double
    let dropoffLongitude: Double
    let dropoffAddress: String
    
    // Selected preferences
    let selectedPreferences: [Int]?
    let expiresAt: String?
    
    let passenger: PassengerInfo
    
    var id: Int { rideRequestId }
    
    // Computed location objects for convenience
    var pickup: Location {
        Location(latitude: pickupLatitude, longitude: pickupLongitude, address: pickupAddress)
    }
    
    var dropoff: Location {
        Location(latitude: dropoffLatitude, longitude: dropoffLongitude, address: dropoffAddress)
    }
    
    // Computed properties for UI display
    var formattedDistanceToPickup: String {
        if let dist = distanceToPickup {
            return String(format: "%.1f km", dist)
        }
        return "N/A"
    }
    
    var formattedETA: String {
        if let eta = estimatedArrivalMinutes {
            return "\(eta) min"
        }
        return "N/A"
    }
    
    var formattedRideDistance: String {
        if let dist = distanceKm {
            return String(format: "%.1f km", dist)
        }
        return "N/A"
    }
    
    var formattedRideDuration: String {
        if let duration = estimatedDurationMinutes {
            return "\(duration) min"
        }
        return "N/A"
    }
    
    var formattedPrice: String {
        return String(format: "%.2f MAD", estimatedPrice)
    }
    
    struct Location: Codable {
        let latitude: Double
        let longitude: Double
        let address: String
    }
    
    struct PassengerInfo: Codable {
        let id: Int
        let name: String
        let phone: String?
        let imageUrl: String?
        let rating: Double?
        
        // Computed property for display rating
        var displayRating: String {
            if let r = rating {
                return String(format: "%.1f", r)
            }
            return "New"
        }
    }
}

/// Response from accepting a ride
struct AcceptRideResponse: Codable {
    let success: Bool
    let message: String?
    let ride: RideDetails?
    
    struct RideDetails: Codable {
        let rideId: Int?
        let passengerId: Int?
        let pickup: DriverRideRequest.Location?
        let dropoff: DriverRideRequest.Location?
        let estimatedPrice: Double?
        let status: String?
    }
}

// MARK: - Driver Socket Events
enum DriverSocketEvent: String {
    // Listen events
    case newRequest = "ride:newRequest"
    case requestTimeout = "ride:requestTimeout"
    case rideStatusUpdate = "ride:statusUpdate"
    case rideCancelled = "ride:cancelled"
    
    // Emit events
    case goOnline = "driver:goOnline"
    case goOffline = "driver:goOffline"
    case acceptRide = "driver:acceptRide"
    case declineRide = "driver:declineRide"
    case updateLocation = "driver:updateLocation"
    case arrivedAtPickup = "driver:arrivedAtPickup"
    case startRide = "driver:startRide"
    case completeRide = "driver:completeRide"
}

// MARK: - Driver Online Status
enum DriverOnlineStatus: String {
    case offline
    case online
    case busy // Currently on a ride
}

// MARK: - Driver Ride Socket Manager
@MainActor
final class DriverRideSocketManager: ObservableObject {
    static let shared = DriverRideSocketManager()
    
    // Published properties for UI updates
    @Published var connectionState: SocketConnectionState = .disconnected
    @Published var onlineStatus: DriverOnlineStatus = .offline
    @Published var currentRideRequest: DriverRideRequest?
    @Published var currentRide: AcceptRideResponse.RideDetails?
    @Published var errorMessage: String?
    @Published var hasIncomingRequest: Bool = false
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private var cancellables = Set<AnyCancellable>()
    
    // Callbacks for specific events
    var onNewRideRequest: ((DriverRideRequest) -> Void)?
    var onRideRequestTimeout: (() -> Void)?
    var onRideAccepted: ((AcceptRideResponse.RideDetails) -> Void)?
    var onRideAcceptFailed: ((String) -> Void)?
    var onRideCancelled: ((String?) -> Void)?
    var onError: ((String) -> Void)?
    
    private init() {}
    
    // Track retry attempts to prevent infinite loops
    private var connectionRetryCount = 0
    private let maxConnectionRetries = 3
    
    // MARK: - Connection Management
    
    /// Connect to socket when driver goes online
    func goOnline() {
        // Prevent multiple connection attempts
        if connectionState == .connecting || connectionState == .connected {
            print("🚗 Driver socket already \(connectionState == .connected ? "connected" : "connecting"), skipping...")
            return
        }
        
        guard let token = TokenManager.shared.token else {
            connectionState = .error("No authentication token found")
            onlineStatus = .offline
            return
        }
        
        // ✅ FIX: Extract userId from JWT token
        guard let userId = JWTHelper.extractUserId(from: token) else {
            connectionState = .error("Failed to extract userId from token")
            onlineStatus = .offline
            print("❌ Could not decode userId from JWT token")
            return
        }
        
        let socketURL = URLEnvironment.socketURL
        
        connectionState = .connecting
        connectionRetryCount = 0
        print("🔌 Driver socket connecting to \(socketURL.absoluteString)/ride")
        
        // Get location for initial connection
        let latitude = pendingLocation?.latitude ?? 0
        let longitude = pendingLocation?.longitude ?? 0
        
        // Clean up any existing connection
        socket?.disconnect()
        manager?.disconnect()
        
        // Configure socket manager
        manager = SocketManager(
            socketURL: socketURL,
            config: [
                .log(true),
                .compress,
                .forceNew(true),
                .reconnects(true),
                .reconnectAttempts(-1), // Unlimited reconnects while online
                .reconnectWait(3),
                .extraHeaders(["Authorization": "Bearer \(token)"])
            ]
        )
        
        // Connect to /ride namespace
        socket = manager?.socket(forNamespace: "/ride")
        
        // ✅ FIX: Auth payload to be sent with connect()
        // This maps to socket.handshake.auth on the server
        let authPayload: [String: Any] = [
            "userId": userId,
            "userType": "driver"
        ]
        
        print("")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║  🔌 DRIVER SOCKET CONNECTION                                 ║")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  URL: \(socketURL.absoluteString)/ride")
        print("║  Auth Payload: \(authPayload)")
        print("║  Location: \(latitude), \(longitude)")
        print("║  Preferences: \(pendingPreferences)")
        print("╚══════════════════════════════════════════════════════════════╝")
        print("")
        
        setupEventHandlers()
        
        // ✅ Connect with auth payload - this sends auth data to server's socket.handshake.auth
        socket?.connect(withPayload: authPayload)
        
        onlineStatus = .online
    }
    
    /// Disconnect socket when driver goes offline
    func goOffline() {
        // Notify server before disconnecting
        if let socket = socket, connectionState == .connected {
            socket.emit(DriverSocketEvent.goOffline.rawValue)
            print("📴 Emitted driver:goOffline event")
        }
        
        socket?.disconnect()
        manager = nil
        socket = nil
        connectionState = .disconnected
        onlineStatus = .offline
        currentRideRequest = nil
        currentRide = nil
        hasIncomingRequest = false
        print("Driver socket disconnected - went offline")
    }
    
    /// Store the current location and preferences for emitting when connected
    private var pendingLocation: (latitude: Double, longitude: Double)?
    private var pendingPreferences: [Int] = []
    
    /// Set location and preferences to be sent when going online
    func setLocation(latitude: Double, longitude: Double, preferences: [Int] = []) {
        pendingLocation = (latitude, longitude)
        pendingPreferences = preferences
    }
    
    /// Emit driver:goOnline event to notify server
    private func emitGoOnline() {
        guard let socket = socket else {
            print("❌ emitGoOnline: socket is nil")
            return
        }
        
        // Check actual socket status, not our state
        guard socket.status == .connected else {
            print("❌ emitGoOnline: socket.status is \(socket.status), not connected - skipping emit")
            return
        }
        
        // Use pending location if available, otherwise default to 0,0
        let latitude = pendingLocation?.latitude ?? 0
        let longitude = pendingLocation?.longitude ?? 0
        
        let payload: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "role": "driver",
            "selectedPreferences": pendingPreferences
        ]
        
        print("")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║  🚗 EMITTING: driver:goOnline                                ║")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  Event: \(DriverSocketEvent.goOnline.rawValue)")
        print("║  Socket Status: \(socket.status)")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  PAYLOAD (JSON):")
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            print("   Raw: \(payload)")
        }
        print("╚══════════════════════════════════════════════════════════════╝")
        print("")
        
        socket.emit(DriverSocketEvent.goOnline.rawValue, payload)
        print("✅ driver:goOnline emitted successfully")
    }
    
    /// Check if driver is currently online
    var isOnline: Bool {
        return onlineStatus == .online || onlineStatus == .busy
    }
    
    // MARK: - Event Handlers Setup
    
    private func setupEventHandlers() {
        guard let socket = socket else { return }
        
        // Connection events
        socket.on(clientEvent: .connect) { [weak self] data, _ in
            print("")
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  ✅ DRIVER SOCKET CONNECTED                                   ║")
            print("╠══════════════════════════════════════════════════════════════╣")
            print("║  Data: \(data)")
            print("║  Socket Status: \(socket.status)")
            print("╚══════════════════════════════════════════════════════════════╝")
            print("")
            
            Task { @MainActor in
                self?.connectionState = .connected
                print("🚗 Driver: connectionState set to .connected")
                
                // Small delay to ensure socket is fully ready before emitting
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                
                // Check if still connected before emitting
                if socket.status == .connected {
                    print("🚗 Driver: socket still connected, emitting goOnline...")
                    self?.emitGoOnline()
                } else {
                    print("❌ Driver: socket no longer connected (status: \(socket.status)), skipping emit")
                }
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] _, _ in
            Task { @MainActor in
                self?.connectionState = .disconnected
                print("Driver socket disconnected")
            }
        }
        
        socket.on(clientEvent: .error) { [weak self] data, _ in
            Task { @MainActor in
                let errorMsg = (data.first as? String) ?? "Unknown socket error"
                self?.connectionState = .error(errorMsg)
                self?.errorMessage = errorMsg
                self?.onError?(errorMsg)
                print("Driver socket error: \(errorMsg)")
            }
        }
        
        // New ride request from passenger
        socket.on(DriverSocketEvent.newRequest.rawValue) { [weak self] data, _ in
            print("🚗 RECEIVED ride:newRequest event with data: \(data)")
            Task { @MainActor in
                self?.handleNewRideRequest(data)
            }
        }
        
        // Ride request timeout (another driver accepted or passenger cancelled)
        socket.on(DriverSocketEvent.requestTimeout.rawValue) { [weak self] data, _ in
            print("⏰ RECEIVED ride:requestTimeout event")
            Task { @MainActor in
                self?.currentRideRequest = nil
                self?.hasIncomingRequest = false
                self?.onRideRequestTimeout?()
                print("Ride request timed out")
            }
        }
        
        // Ride cancelled by passenger
        socket.on(DriverSocketEvent.rideCancelled.rawValue) { [weak self] data, _ in
            print("❌ RECEIVED ride:cancelled event")
            Task { @MainActor in
                let reason = data.first as? String
                self?.currentRide = nil
                self?.onlineStatus = .online
                self?.onRideCancelled?(reason)
                print("Ride cancelled: \(reason ?? "No reason provided")")
            }
        }
        
        // Ride status update
        socket.on(DriverSocketEvent.rideStatusUpdate.rawValue) { [weak self] data, _ in
            print("📊 RECEIVED ride:statusUpdate event with data: \(data)")
            Task { @MainActor in
                self?.handleRideStatusUpdate(data)
            }
        }
        
        // Listen for ALL events to debug
        socket.onAny { event in
            print("🔔 DRIVER SOCKET EVENT: \(event.event) with items: \(event.items ?? [])")
        }
    }
    
    // MARK: - Event Handlers
    
    private func handleNewRideRequest(_ data: [Any]) {
        guard let firstItem = data.first else {
            print("No data in new ride request")
            return
        }
        
        do {
            let jsonData: Data
            if let dict = firstItem as? [String: Any] {
                jsonData = try JSONSerialization.data(withJSONObject: dict)
            } else if let dataItem = firstItem as? Data {
                jsonData = dataItem
            } else {
                print("Unexpected data format for ride request")
                return
            }
            
            let decoder = JSONDecoder()
            let rideRequest = try decoder.decode(DriverRideRequest.self, from: jsonData)
            
            currentRideRequest = rideRequest
            hasIncomingRequest = true
            onNewRideRequest?(rideRequest)
            
            print("Received new ride request: \(rideRequest.rideRequestId)")
        } catch {
            print("Failed to decode ride request: \(error)")
            errorMessage = "Failed to parse ride request"
        }
    }
    
    private func handleRideStatusUpdate(_ data: [Any]) {
        guard let dict = data.first as? [String: Any],
              let status = dict["status"] as? String else {
            return
        }
        
        print("Ride status update: \(status)")
        
        // Handle different status updates
        switch status {
        case "cancelled":
            currentRide = nil
            onlineStatus = .online
            onRideCancelled?(dict["message"] as? String)
        case "completed":
            currentRide = nil
            onlineStatus = .online
        default:
            break
        }
    }
    
    // MARK: - Driver Actions
    
    /// Accept a ride request
    func acceptRide(rideRequestId: Int) {
        guard let socket = socket, connectionState == .connected else {
            onRideAcceptFailed?("Not connected to server")
            return
        }
        
        let payload: [String: Any] = [
            "rideRequestId": rideRequestId
        ]
        
        socket.emitWithAck(DriverSocketEvent.acceptRide.rawValue, payload).timingOut(after: 10) { [weak self] data in
            Task { @MainActor in
                self?.handleAcceptRideResponse(data)
            }
        }
        
        print("Emitted accept ride request for ID: \(rideRequestId)")
    }
    
    private func handleAcceptRideResponse(_ data: [Any]) {
        guard let firstItem = data.first else {
            onRideAcceptFailed?("No response from server")
            return
        }
        
        // Check for socket timeout
        if let noAck = firstItem as? String, noAck == "NO ACK" {
            onRideAcceptFailed?("Request timed out")
            return
        }
        
        guard let dict = firstItem as? [String: Any] else {
            onRideAcceptFailed?("Invalid response format")
            return
        }
        
        let success = dict["success"] as? Bool ?? false
        
        if success {
            // Parse ride details
            if let rideDict = dict["ride"] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: rideDict)
                    let rideDetails = try JSONDecoder().decode(AcceptRideResponse.RideDetails.self, from: jsonData)
                    
                    currentRide = rideDetails
                    currentRideRequest = nil
                    hasIncomingRequest = false
                    onlineStatus = .busy
                    onRideAccepted?(rideDetails)
                    
                    print("Successfully accepted ride")
                } catch {
                    print("Failed to decode ride details: \(error)")
                    onRideAccepted?(AcceptRideResponse.RideDetails(rideId: nil, passengerId: nil, pickup: nil, dropoff: nil, estimatedPrice: nil, status: nil))
                }
            } else {
                currentRideRequest = nil
                hasIncomingRequest = false
                onlineStatus = .busy
                onRideAccepted?(AcceptRideResponse.RideDetails(rideId: nil, passengerId: nil, pickup: nil, dropoff: nil, estimatedPrice: nil, status: nil))
            }
        } else {
            let message = dict["message"] as? String ?? "Ride already taken"
            currentRideRequest = nil
            hasIncomingRequest = false
            onRideAcceptFailed?(message)
            print("Failed to accept ride: \(message)")
        }
    }
    
    /// Decline a ride request
    func declineRide(rideRequestId: Int) {
        guard let socket = socket, connectionState == .connected else { return }
        
        let payload: [String: Any] = [
            "rideRequestId": rideRequestId
        ]
        
        socket.emit(DriverSocketEvent.declineRide.rawValue, payload)
        
        currentRideRequest = nil
        hasIncomingRequest = false
        
        print("Declined ride request: \(rideRequestId)")
    }
    
    /// Update driver's current location
    func updateLocation(latitude: Double, longitude: Double) {
        guard let socket = socket, connectionState == .connected else {
            print("⚠️ Cannot update location - socket not connected (state: \(connectionState))")
            return
        }
        
        // ✅ FIX: Include isAvailable flag (REQUIRED by backend)
        // Without this, driver will be filtered out during ride matching!
        let payload: [String: Any] = [
            "latitude": latitude,
            "longitude": longitude,
            "isAvailable": true  // ✅ CRITICAL: Required for ride matching
        ]
        
        print("📍 EMITTING driver:updateLocation - lat: \(latitude), lng: \(longitude), available: true")
        socket.emit(DriverSocketEvent.updateLocation.rawValue, payload)
    }
    
    /// Notify that driver has arrived at pickup location
    func arrivedAtPickup(rideId: Int) {
        guard let socket = socket, connectionState == .connected else { return }
        
        let payload: [String: Any] = [
            "rideId": rideId
        ]
        
        socket.emit(DriverSocketEvent.arrivedAtPickup.rawValue, payload)
        print("Notified arrival at pickup for ride: \(rideId)")
    }
    
    /// Start the ride
    func startRide(rideId: Int) {
        guard let socket = socket, connectionState == .connected else { return }
        
        let payload: [String: Any] = [
            "rideId": rideId
        ]
        
        socket.emit(DriverSocketEvent.startRide.rawValue, payload)
        print("Started ride: \(rideId)")
    }
    
    /// Complete the ride
    func completeRide(rideId: Int) {
        guard let socket = socket, connectionState == .connected else { return }
        
        let payload: [String: Any] = [
            "rideId": rideId
        ]
        
        socket.emit(DriverSocketEvent.completeRide.rawValue, payload)
        
        currentRide = nil
        onlineStatus = .online
        
        print("Completed ride: \(rideId)")
    }
    
    /// Clear current ride request (e.g., after timeout or decline)
    func clearCurrentRequest() {
        currentRideRequest = nil
        hasIncomingRequest = false
    }
}
