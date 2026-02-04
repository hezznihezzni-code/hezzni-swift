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
    
    // MARK: - Connection Management
    
    func connect() {
        guard let token = TokenManager.shared.token else {
            connectionState = .error("No authentication token found")
            return
        }
        
        let socketURL = URLEnvironment.socketURL
        
        connectionState = .connecting
        
        // Configure socket with authentication
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
        
        setupEventHandlers()
        socket?.connect()
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
        guard let socket = socket else { return }
        
        // Connection events
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            Task { @MainActor in
                self?.connectionState = .connected
                print("✅ Passenger socket connected to /ride namespace")
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] _, _ in
            Task { @MainActor in
                self?.connectionState = .disconnected
                self?.isSearchingForDriver = false
                print("❌ Passenger socket disconnected from /ride namespace")
            }
        }
        
        socket.on(clientEvent: .error) { [weak self] data, _ in
            Task { @MainActor in
                let errorMsg = (data.first as? String) ?? "Unknown socket error"
                self?.connectionState = .error(errorMsg)
                self?.errorMessage = errorMsg
                self?.onError?(errorMsg)
                print("⚠️ Passenger socket error: \(errorMsg)")
            }
        }
        
        // Listen for ALL events to debug
        socket.onAny { event in
            print("🔔 PASSENGER SOCKET EVENT: \(event.event) with items: \(event.items ?? [])")
        }
        
        // Ride request response
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
            connect()
            // Retry after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
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
        print("🚀 EMITTING passenger:requestRide with data:")
        print("   Event: \(RideSocketEvent.requestRide.rawValue)")
        print("   Payload: \(socketData)")
        
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
