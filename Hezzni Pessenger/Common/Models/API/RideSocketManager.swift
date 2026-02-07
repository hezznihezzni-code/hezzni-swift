//
//  RideSocketManager.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 2/3/26.
//

import Foundation
import SocketIO
internal import Combine

// MARK: - Ride Request Payload
struct RideRequestPayload: Codable {
    let pickupLatitude: Double
    let pickupLongitude: Double
    let pickupAddress: String
    let dropoffLatitude: Double
    let dropoffLongitude: Double
    let dropoffAddress: String
    let role: String
    let serviceTypeId: Int
    let selectedPreferences: [Int]
    let estimatedPrice: Double
    let couponId: Int? // Optional coupon ID for discounted rides
    
    func toSocketData() -> [String: Any] {
        var data: [String: Any] = [
            "pickupLatitude": pickupLatitude,
            "pickupLongitude": pickupLongitude,
            "pickupAddress": pickupAddress,
            "dropoffLatitude": dropoffLatitude,
            "dropoffLongitude": dropoffLongitude,
            "dropoffAddress": dropoffAddress,
            "role": role,
            "serviceTypeId": serviceTypeId,
            "selectedPreferences": selectedPreferences,
            "estimatedPrice": estimatedPrice
        ]
        if let couponId = couponId {
            data["couponId"] = couponId
        }
        return data
    }
}

// MARK: - Socket Response Models
struct RideRequestResponse: Codable {
    let success: Bool
    let message: String?
    let rideId: String?
    let status: String?
}

struct DriverFoundResponse: Codable {
    let driverId: String
    let driverName: String
    let driverPhone: String?
    let vehicleInfo: VehicleInfo?
    let estimatedArrival: Int? // in minutes
    let rating: Double?
    
    struct VehicleInfo: Codable {
        let make: String?
        let model: String?
        let color: String?
        let plateNumber: String?
    }
}

struct RideStatusUpdate: Codable {
    let rideId: String
    let status: RideStatus
    let message: String?
    
    enum RideStatus: String, Codable {
        case searching = "searching"
        case driverFound = "driver_found"
        case driverEnRoute = "driver_en_route"
        case driverArrived = "driver_arrived"
        case rideStarted = "ride_started"
        case rideCompleted = "ride_completed"
        case rideCancelled = "ride_cancelled"
        case noDriverFound = "no_driver_found"
    }
}

// MARK: - Socket Events
enum RideSocketEvent: String {
    // Emit events
    case requestRide = "passenger:requestRide"
    case cancelRide = "passenger:cancelRide"
    
    // Listen events
    case rideRequestResponse = "ride:requestResponse"
    case driverFound = "ride:driverFound"
    case statusUpdate = "ride:statusUpdate"
    case noDriverFound = "ride:noDriverFound"
    case error = "error"
}

enum SocketConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case error(String)

    static func == (lhs: SocketConnectionState, rhs: SocketConnectionState) -> Bool {
        switch (lhs, rhs) {
        case (.disconnected, .disconnected),
             (.connecting, .connecting),
             (.connected, .connected):
            return true
        case let (.error(a), .error(b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - Ride Socket Manager
@MainActor
final class RideSocketManager: ObservableObject {
    static let shared = RideSocketManager()
    
    // Publishers for UI updates
    @Published var connectionState: SocketConnectionState = .disconnected
    @Published var currentRideStatus: RideStatusUpdate.RideStatus?
    @Published var driverInfo: DriverFoundResponse?
    @Published var errorMessage: String?
    @Published var isSearchingForDriver: Bool = false
    @Published var currentRideId: String?
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private var cancellables = Set<AnyCancellable>()
    
    // Callbacks for specific events
    var onDriverFound: ((DriverFoundResponse) -> Void)?
    var onNoDriverFound: (() -> Void)?
    var onRideStatusUpdate: ((RideStatusUpdate) -> Void)?
    var onError: ((String) -> Void)?
    var onRideRequestSuccess: ((String) -> Void)?
    
    private init() {}
    
    // Track retry attempts to prevent infinite loops
    private var connectionRetryCount = 0
    private let maxConnectionRetries = 3
    
    // MARK: - Connection Management
    
    func connect() {
        // Prevent multiple connection attempts
        if connectionState == .connecting || connectionState == .connected {
            print("✅ Passenger socket already \(connectionState == .connected ? "connected" : "connecting"), skipping...")
            return
        }
        
        guard let token = TokenManager.shared.token else {
            connectionState = .error("No authentication token found")
            return
        }
        
        // ✅ FIX: Extract userId from JWT token
        guard let userId = JWTHelper.extractUserId(from: token) else {
            connectionState = .error("Failed to extract userId from token")
            print("❌ Could not decode userId from JWT token")
            return
        }
        
        let socketURL = URLEnvironment.socketURL
        
        connectionState = .connecting
        connectionRetryCount = 0
        print("🔌 Passenger socket connecting to \(socketURL.absoluteString)/ride")
        
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
                .reconnectAttempts(5),
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
            "userType": "passenger"
        ]
        
        print("")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║  🔌 PASSENGER SOCKET CONNECTION                              ║")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  URL: \(socketURL.absoluteString)/ride")
        print("║  Auth Payload: \(authPayload)")
        print("╚══════════════════════════════════════════════════════════════╝")
        print("")
        
        setupEventHandlers()
        
        // ✅ Connect with auth payload - this sends auth data to server's socket.handshake.auth
        socket?.connect(withPayload: authPayload)
    }
    
    func disconnect() {
        socket?.disconnect()
        manager = nil
        socket = nil
        connectionState = .disconnected
        isSearchingForDriver = false
        currentRideStatus = nil
        driverInfo = nil
        currentRideId = nil
    }
    
    // MARK: - Event Handlers Setup
    
    private func setupEventHandlers() {
        guard let socket = socket else {
            print("❌ setupEventHandlers: socket is nil!")
            return
        }
        
        print("")
        print("📡 PASSENGER: Setting up event handlers...")
        print("   Socket ID: \(socket.sid)")
        print("   Socket Status: \(socket.status)")
        print("")
        
        // Connection events
        socket.on(clientEvent: .connect) { [weak self] data, _ in
            print("")
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  ✅ PASSENGER SOCKET CONNECTED                               ║")
            print("╠══════════════════════════════════════════════════════════════╣")
            print("║  Connect Data: \(data)")
            print("║  Socket SID: \(socket.sid)")
            print("║  Socket Status: \(socket.status)")
            print("╚══════════════════════════════════════════════════════════════╝")
            print("")
            
            Task { @MainActor in
                self?.connectionState = .connected
                self?.connectionRetryCount = 0  // Reset retry count on successful connection
                print("🚶 Passenger: connectionState set to .connected")
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            print("")
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  ❌ PASSENGER SOCKET DISCONNECTED                            ║")
            print("╠══════════════════════════════════════════════════════════════╣")
            print("║  Disconnect Reason: \(data)")
            print("║  Socket Status: \(socket.status)")
            print("╚══════════════════════════════════════════════════════════════╝")
            print("")
            
            Task { @MainActor in
                self?.connectionState = .disconnected
                self?.isSearchingForDriver = false
            }
        }
        
        socket.on(clientEvent: .error) { [weak self] data, _ in
            print("")
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  ⚠️ PASSENGER SOCKET ERROR                                   ║")
            print("╠══════════════════════════════════════════════════════════════╣")
            print("║  Error Data: \(data)")
            print("║  Socket Status: \(socket.status)")
            print("╚══════════════════════════════════════════════════════════════╝")
            print("")
            
            Task { @MainActor in
                let errorMsg = (data.first as? String) ?? "Unknown socket error"
                self?.connectionState = .error(errorMsg)
                self?.errorMessage = errorMsg
                self?.onError?(errorMsg)
            }
        }
        
        // Listen for server-sent errors (different from client errors)
        socket.on("error") { [weak self] data, _ in
            print("")
            print("⚠️ PASSENGER: Server sent 'error' event:")
            print("   Data: \(data)")
            print("")
            
            Task { @MainActor in
                let errorMsg = (data.first as? [String: Any])?["message"] as? String ?? "An error occurred"
                self?.errorMessage = errorMsg
                self?.onError?(errorMsg)
            }
        }
        
        // Listen for 'connect_error' which often contains auth failure reasons
        socket.on("connect_error") { data, _ in
            print("")
            print("❌ PASSENGER: connect_error event:")
            print("   Data: \(data)")
            print("")
        }
        
        // Listen for ALL events to debug
        socket.onAny { event in
            print("🔔 PASSENGER SOCKET EVENT: \(event.event) with items: \(event.items ?? [])")
        }
        
        // NEW: Listen for ride:requestReceived (acknowledgment from server)
        socket.on("ride:requestReceived") { [weak self] data, _ in
            print("")
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  📨 PASSENGER: ride:requestReceived                           ║")
            print("╠══════════════════════════════════════════════════════════════╣")
            if let responseData = data.first as? [String: Any] {
                if let jsonData = try? JSONSerialization.data(withJSONObject: responseData, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            } else {
                print("   Data: \(data)")
            }
            print("╚══════════════════════════════════════════════════════════════╝")
            print("")
            
            Task { @MainActor in
                self?.handleRideRequestResponse(data)
            }
        }
        
        // NEW: Listen for ride:accepted (driver accepted the ride)
        socket.on("ride:accepted") { [weak self] data, _ in
            print("")
            print("╔══════════════════════════════════════════════════════════════╗")
            print("║  🎉 PASSENGER: ride:accepted - DRIVER FOUND!                ║")
            print("╠══════════════════════════════════════════════════════════════╣")
            if let responseData = data.first as? [String: Any] {
                if let jsonData = try? JSONSerialization.data(withJSONObject: responseData, options: .prettyPrinted),
                   let jsonString = String(data: jsonData, encoding: .utf8) {
                    print(jsonString)
                }
            } else {
                print("   Data: \(data)")
            }
            print("╚══════════════════════════════════════════════════════════════╝")
            print("")
            
            Task { @MainActor in
                self?.handleDriverFound(data)
            }
        }
        
        // Ride request response (original listener)
        socket.on(RideSocketEvent.rideRequestResponse.rawValue) { [weak self] data, _ in
            print("📨 RECEIVED ride:requestResponse with data: \(data)")
            Task { @MainActor in
                self?.handleRideRequestResponse(data)
            }
        }
        
        // Driver found
        socket.on(RideSocketEvent.driverFound.rawValue) { [weak self] data, _ in
            print("🚗 RECEIVED ride:driverFound with data: \(data)")
            Task { @MainActor in
                self?.handleDriverFound(data)
            }
        }
        
        // Status updates
        socket.on(RideSocketEvent.statusUpdate.rawValue) { [weak self] data, _ in
            print("📊 RECEIVED ride:statusUpdate with data: \(data)")
            Task { @MainActor in
                self?.handleStatusUpdate(data)
            }
        }
        
        // No driver found
        socket.on(RideSocketEvent.noDriverFound.rawValue) { [weak self] data, _ in
            print("😢 RECEIVED ride:noDriverFound with data: \(data)")
            Task { @MainActor in
                self?.handleNoDriverFound(data)
            }
        }
        
        // Generic error event
        socket.on(RideSocketEvent.error.rawValue) { [weak self] data, _ in
            print("⚠️ RECEIVED ride:error with data: \(data)")
            Task { @MainActor in
                let errorMsg = (data.first as? [String: Any])?["message"] as? String ?? "An error occurred"
                self?.errorMessage = errorMsg
                self?.onError?(errorMsg)
            }
        }
    }
    
    // MARK: - Emit Events
    
    /// Request a ride with the given parameters
    func requestRide(
        pickupLatitude: Double,
        pickupLongitude: Double,
        pickupAddress: String,
        dropoffLatitude: Double,
        dropoffLongitude: Double,
        dropoffAddress: String,
        serviceTypeId: Int,
        selectedRideOptionId: Int,
        estimatedPrice: Double,
        couponId: Int? = nil
    ) {
        guard connectionState == .connected else {
            // Auto-connect if not connected
            connectionRetryCount += 1
            
            if connectionRetryCount > maxConnectionRetries {
                print("❌ Max connection retries reached, giving up")
                isSearchingForDriver = false
                errorMessage = "Failed to connect to server"
                onError?("Failed to connect to server")
                return
            }
            
            print("🔄 Socket not connected, connecting... (attempt \(connectionRetryCount)/\(maxConnectionRetries))")
            connect()
            
            // Retry after connection delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.requestRide(
                    pickupLatitude: pickupLatitude,
                    pickupLongitude: pickupLongitude,
                    pickupAddress: pickupAddress,
                    dropoffLatitude: dropoffLatitude,
                    dropoffLongitude: dropoffLongitude,
                    dropoffAddress: dropoffAddress,
                    serviceTypeId: serviceTypeId,
                    selectedRideOptionId: selectedRideOptionId,
                    estimatedPrice: estimatedPrice,
                    couponId: couponId
                )
            }
            return
        }
        
        // Reset retry count on successful connection
        connectionRetryCount = 0
        isSearchingForDriver = true
        errorMessage = nil
        
        let payload = RideRequestPayload(
            pickupLatitude: pickupLatitude,
            pickupLongitude: pickupLongitude,
            pickupAddress: pickupAddress,
            dropoffLatitude: dropoffLatitude,
            dropoffLongitude: dropoffLongitude,
            dropoffAddress: dropoffAddress,
            role: "passenger",
            serviceTypeId: serviceTypeId,
            selectedPreferences: [selectedRideOptionId],
            estimatedPrice: estimatedPrice,
            couponId: couponId
        )
        
        let socketData = payload.toSocketData()
        
        print("")
        print("╔══════════════════════════════════════════════════════════════╗")
        print("║  🚀 EMITTING: passenger:requestRide                          ║")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  Event: \(RideSocketEvent.requestRide.rawValue)")
        print("║  Connection State: \(connectionState)")
        print("║  Socket Status: \(socket?.status.description ?? "nil")")
        print("╠══════════════════════════════════════════════════════════════╣")
        print("║  PAYLOAD (JSON):")
        if let jsonData = try? JSONSerialization.data(withJSONObject: socketData, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print(jsonString)
        } else {
            print("   Raw: \(socketData)")
        }
        print("╚══════════════════════════════════════════════════════════════╝")
        print("")
        
        socket?.emit(RideSocketEvent.requestRide.rawValue, socketData)
        currentRideStatus = .searching
    
    }
    
    /// Cancel the current ride search
    func cancelRideSearch() {
        guard let rideId = currentRideId else {
            isSearchingForDriver = false
            currentRideStatus = nil
            return
        }
        
        socket?.emit(RideSocketEvent.cancelRide.rawValue, ["rideId": rideId])
        isSearchingForDriver = false
        currentRideStatus = .rideCancelled
        currentRideId = nil
    }
    
    // MARK: - Response Handlers
    
    private func handleRideRequestResponse(_ data: [Any]) {
        guard let responseData = data.first as? [String: Any] else { return }
        
        let success = responseData["success"] as? Bool ?? false
        let message = responseData["message"] as? String
        let rideId = responseData["rideId"] as? String
        
        if success {
            currentRideId = rideId
            currentRideStatus = .searching
            if let rideId = rideId {
                onRideRequestSuccess?(rideId)
            }
            print("Ride request successful. Ride ID: \(rideId ?? "N/A")")
        } else {
            isSearchingForDriver = false
            errorMessage = message ?? "Failed to request ride"
            onError?(errorMessage ?? "Unknown error")
            print("Ride request failed: \(message ?? "Unknown error")")
        }
    }
    
    private func handleDriverFound(_ data: [Any]) {
        guard let driverData = data.first as? [String: Any] else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: driverData)
            let driver = try JSONDecoder().decode(DriverFoundResponse.self, from: jsonData)
            
            isSearchingForDriver = false
            currentRideStatus = .driverFound
            driverInfo = driver
            onDriverFound?(driver)
            
            print("Driver found: \(driver.driverName)")
        } catch {
            print("Failed to decode driver info: \(error)")
        }
    }
    
    private func handleStatusUpdate(_ data: [Any]) {
        guard let statusData = data.first as? [String: Any] else { return }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: statusData)
            let update = try JSONDecoder().decode(RideStatusUpdate.self, from: jsonData)
            
            currentRideStatus = update.status
            onRideStatusUpdate?(update)
            
            // Handle specific status changes
            if update.status == .noDriverFound {
                isSearchingForDriver = false
                onNoDriverFound?()
            }
            
            print("Ride status update: \(update.status.rawValue)")
        } catch {
            print("Failed to decode status update: \(error)")
        }
    }
    
    private func handleNoDriverFound(_ data: [Any]) {
        isSearchingForDriver = false
        currentRideStatus = .noDriverFound
        onNoDriverFound?()
        print("No driver found")
    }
}

// MARK: - URL Environment Extension
extension URLEnvironment {
    /// Socket server URL
    static var socketURL: URL {
        // Use the same base URL host for WebSocket
        // Extract the scheme and host from baseURL
        guard let host = baseURL.host else {
            return URL(string: "https://api.hezzni.com")!
        }
        let scheme = baseURL.scheme ?? "https"
        let socketURLString = "\(scheme)://\(host)"
        return URL(string: socketURLString) ?? URL(string: "https://api.hezzni.com")!
    }
}
