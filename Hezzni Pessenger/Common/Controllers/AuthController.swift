//
//  AuthController.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/12/25.
//

import Foundation
import UIKit
import SwiftUI
internal import Combine

// MARK: - UserDefaults Helpers for User
extension UserDefaults {
    private static let loggedInUserKey = "LoggedInUser"
    
    func saveUser(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            set(data, forKey: UserDefaults.loggedInUserKey)
        }
    }
    
    func getUser() -> User? {
        if let data = data(forKey: UserDefaults.loggedInUserKey) {
            return try? JSONDecoder().decode(User.self, from: data)
        }
        return nil
    }
    func deleteUser() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.loggedInUserKey)
    }
}

// MARK: - Driver Persistence + Models
extension UserDefaults {
    private static let loggedInDriverKey = "LoggedInDriver"

    func saveDriverUser(_ user: DriverUser) {
        if let data = try? JSONEncoder().encode(user) {
            set(data, forKey: UserDefaults.loggedInDriverKey)
        }
    }

    func getDriverUser() -> DriverUser? {
        if let data = data(forKey: UserDefaults.loggedInDriverKey) {
            return try? JSONDecoder().decode(DriverUser.self, from: data)
        }
        return nil
    }
    
    func deleteDriverUser() {
        UserDefaults.standard.removeObject(forKey: UserDefaults.loggedInDriverKey)
    }
}

enum UserType {
    case passenger
    case driver
}

class AuthController: ObservableObject {
    static let shared = AuthController()
    @Published var activeUserType: UserType = .passenger
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var phoneNumber: String = ""
    @Published var authToken: String? // kept for compatibility if needed
    @Published var shouldNavigateToNextScreen = false
    
    // Cache of the current user from login/verify/complete profile
    @Published var currentUser: User?
    @Published var driverUser: DriverUser?
    
    private init() {}
    
    // MARK: - Health Check
    func checkServerHealth() async -> Bool {
        do {
            let (_, response) = try await URLSession.shared.data(from: URLEnvironment.healthCheckURL)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            return (200...299).contains(httpResponse.statusCode)
        } catch {
            return false
        }
    }
    
    // MARK: - Send OTP
    func sendOTP(phoneNumber: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
            self.phoneNumber = phoneNumber
        }
        print("checking the send otp")
        // First check server health
        let isServerHealthy = await checkServerHealth()
        guard isServerHealthy else {
            await MainActor.run {
                isLoading = false
                errorMessage = "Server is unavailable. Please try again later."
            }
            return false
        }

        do {
            // Updated parameters to match backend expectation
            let parameters = ["phone": phoneNumber]
            let endpoint = "/api/\(AppUserType.shared.userType == .driver ? "driver" : "passenger")/login"
            print("Calling :::: \(endpoint)")

            // Driver and Passenger have different response shapes.
            if AppUserType.shared.userType == .driver {
                let response: DriverSendOTPResponse = try await APIService.shared.request(
                    endpoint: endpoint,
                    method: "POST",
                    parameters: parameters
                )

                await MainActor.run {
                    isLoading = false
                    if response.status == "success" {
                        errorMessage = nil
                        successMessage = response.message

                        if let token = response.data.token {
                            TokenManager.shared.saveToken(token)
                        }
                        driverUser = DriverUser(
                            id: response.data.user.id,
                            phone: response.data.user.phone,
                            name: response.data.user.name,
                            email: response.data.user.email,
                            imageUrl: response.data.user.imageUrl,
                            dob: response.data.user.dob,
                            gender: response.data.user.gender,
                            cityId: response.data.user.cityId,
                            isRegistered: response.data.user.isRegistered,
                            serviceType: response.data.user.serviceType,
                            serviceTypeId: response.data.user.serviceTypeId,
                            createdAt: response.data.user.createdAt,
                            carRideStatus: response.data.user.carRideStatus,
                            motorcycleStatus: response.data.user.motorcycleStatus,
                            taxiStatus: response.data.user.taxiStatus,
                            rentalProfile: response.data.user.rentalProfile,
                        )
                        if let user = driverUser {
                            UserDefaults.standard.saveDriverUser(user)
                        }

                        
                        print("Congratulations: \(response.message)")
                    } else {
                        errorMessage = response.message
                        successMessage = nil
                        print("Failed to send OTP: \(response.message)")
                    }
                }

                return response.status == "success"
            } else {
                let response: SendOTPResponse = try await APIService.shared.request(
                    endpoint: endpoint,
                    method: "POST",
                    parameters: parameters
                )
                print(response)
                await MainActor.run {
                    isLoading = false
                    if response.status == "success" {
                        errorMessage = nil
                        successMessage = response.message
                        if let token = response.data.token {
                            TokenManager.shared.saveToken(token)
                        }
                        if (response.data.isRegistered) {
                            currentUser = response.data.user
                            if let user = currentUser {
                                UserDefaults.standard.saveUser(user)
                            }
                        }

                        print("Congratulations: \(response.message)")
                    } else {
                        errorMessage = response.message
                        successMessage = nil
                        print("Failed to send OTP: \(response.message)")
                    }
                }

                return response.status == "success"
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = handleAPIError(error)
                successMessage = nil
                print("API Error: \(error.localizedDescription)")
            }
            return false
        }
    }
    
    // MARK: - Verify OTP (dummy logic)
        func verifyOTP(phoneNumber: String, otp: String) async -> Bool {
            await MainActor.run {
                isLoading = true
                errorMessage = nil
                successMessage = nil
            }
            defer {
                Task { @MainActor in isLoading = false }
            }
            // Dummy logic: OTP is valid only if it is "000000"
            if otp == "000000" {
                await MainActor.run {
                    successMessage = "OTP verified successfully."
                    errorMessage = nil
                    shouldNavigateToNextScreen = true
                }
                return true
            } else {
                await MainActor.run {
                    errorMessage = "Invalid OTP. Please try again."
                    successMessage = nil
                    shouldNavigateToNextScreen = false
                }
                return false
            }
        }
    


    // MARK: - Complete registration using new API
    func completeRegistration(
        name: String,
        email: String?,
        image: UIImage?,
        dob: String?,
        gender: String?,
        cityId: Int?
    ) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }
        do {
            let response = try await APIService.shared.completeProfile(
                name: name,
                email: email,
                dob: dob,
                gender: gender,
                cityId: cityId,
                image: image
            )
            await MainActor.run {
                isLoading = false
                if response.status == "success" {
                    successMessage = response.message
                    errorMessage = nil
                    currentUser = response.data.user
                    if let user = currentUser {
                        UserDefaults.standard.saveUser(user)
                    }
                    UserDefaults.standard.set(true, forKey: "isUserRegistered")
                    shouldNavigateToNextScreen = true
                } else {
                    errorMessage = response.message
                    successMessage = nil
                }
            }
            return response.status == "success"
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = handleAPIError(error)
                successMessage = nil
            }
            return false
        }
    }

    func updateProfile(
        name: String,
        email: String?,
        phone: String,
        image: UIImage?,
        dob: String?,
        gender: String,
        cityId: Int
    ) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            successMessage = nil
        }
        do {
            let response = try await APIService.shared.updatePassengerProfile(
                name: name,
                email: email,
                phone: phone,
                dob: dob,
                gender: gender,
                cityId: cityId,
                image: image
            )
            await MainActor.run {
                isLoading = false
                if response.status == "success" {
                    successMessage = response.message
                    errorMessage = nil
                    currentUser = response.data.user
                    if let user = currentUser {
                        UserDefaults.standard.saveUser(user)
                    }
                } else {
                    errorMessage = response.message
                    successMessage = nil
                }
            }
            return response.status == "success"
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = handleAPIError(error)
                successMessage = nil
            }
            return false
        }
    }

    // Helper used by OTPScreen navigation
    func isUserRegistered() -> Bool {
        if AppUserType.shared.userType == .passenger {
            if let user = UserDefaults.standard.getUser() {
                return user.isRegistered
            }
        }
        else {
            if let user = UserDefaults.standard.getDriverUser() {
                return user.isRegistered
            }
        }
        return UserDefaults.standard.bool(forKey: "isUserRegistered")
    }
    // Helper used by OTPScreen navigation
    func isServiceTypeExists() -> Bool {
        if AppUserType.shared.userType == .passenger {
            guard let user = UserDefaults.standard.getUser() else {
                print("No current user found when checking service type existence.")
                return UserDefaults.standard.bool(forKey: "isUserRegistered")
            }
            // No service selected at all
            guard user.serviceTypeId != nil || user.serviceType != nil else {
                return false
            }
            
            // Check whichever service status object is present. If any present status is PENDING, return false.
            let statuses: [ServiceVerificationStatus?] = [user.motorcycleStatus, user.taxiStatus, user.carRideStatus, user.rentalProfile]
            for s in statuses {
                if let s, s.status.uppercased() == "PENDING" {
                    return false
                }
            }
            
            // If a status object exists and it is not PENDING, treat it as completed/verified enough.
            // If none of the status objects exist, fall back to just having a serviceType.
            return true
        } else {
            guard let user = UserDefaults.standard.getDriverUser() else {
                print("No current user found when checking service type existence.")
                return UserDefaults.standard.bool(forKey: "isUserRegistered")
            }
            // No service selected at all
            guard user.serviceTypeId != nil || user.serviceType != nil else {
                return false
            }

            // Check whichever service status object is present. If any present status is PENDING, return false.
            let statuses: [ServiceVerificationStatus?] = [user.motorcycleStatus, user.taxiStatus, user.carRideStatus, user.rentalProfile]
            for s in statuses {
                if let s, s.status.uppercased() == "PENDING" {
                    return false
                }
            }

            // If a status object exists and it is not PENDING, treat it as completed/verified enough.
            // If none of the status objects exist, fall back to just having a serviceType.
            return true
        }

    }
    // MARK: - Resend OTP
    func resendOTP() async -> Bool {
        await sendOTP(phoneNumber: phoneNumber)
    }
    
    // MARK: - Error Handling
    private func handleAPIError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            switch apiError {
            case .apiError(let message):
                return message
            case .httpError(let statusCode):
                switch statusCode {
                case 400:
                    return "Invalid request. Please check your input."
                case 401:
                    return "Authentication failed. Please try again."
                case 404:
                    return "Service not found. Please contact support."
                case 500:
                    return "Server error. Please try again later."
                default:
                    return "Network error (\(statusCode)). Please try again."
                }
            case .serverError:
                return "Server is temporarily unavailable. Please try again later."
            case .decodingError:
                return "Unexpected response from server. Please try again."
            default:
                return "Network error. Please check your connection."
            }
        }
        return "An unexpected error occurred. Please try again."
    }
    
    // MARK: - Reset State
    func resetState() {
        isLoading = false
        errorMessage = nil
        successMessage = nil
        shouldNavigateToNextScreen = false
    }
}

// MARK: - User Model (matches backend response)
struct User: Codable { // Codable for UserDefaults
    let id: Int
    let phone: String
    let name: String?
    let email: String?
    let imageUrl: String?

    // Passenger fields (may be null for driver)
    let dob: String?
    let gender: String?
    let cityId: Int?

    let isRegistered: Bool
    let createdAt: String?

    // Driver-specific fields
    let serviceTypeId: Int?
    let serviceType: DriverServiceType?

    let carRideStatus: ServiceVerificationStatus?
    let motorcycleStatus: ServiceVerificationStatus?
    let rentalProfile: ServiceVerificationStatus?
    let taxiStatus: ServiceVerificationStatus?
}

/// Generic service verification object returned by the backend for different driver services.
/// (motorcycleStatus, taxiStatus, carRideStatus, rentalProfile)
struct ServiceVerificationStatus: Codable {
    let id: Int?
    let driverId: Int?
    let status: String
    let rejectionReason: String?

    // Document completion flags
    let isNationalIdCompleted: Bool?
    let isDriverLicenseCompleted: Bool?
    let isProfessionalCardCompleted: Bool?
    let isVehicleRegistrationCompleted: Bool?
    let isVehicleInsuranceCompleted: Bool?
    let isVehicleDetailsCompleted: Bool?
    let isVehiclePhotosCompleted: Bool?
    let isFaceVerificationCompleted: Bool?

    let createdAt: String?
    let updatedAt: String?
}

// MARK: - Driver Services APIs
struct DriverServicesResponse: Decodable {
    let status: String
    let message: String
    let data: DriverServicesOuterData
    let timestamp: String

    struct DriverServicesOuterData: Decodable {
        let status: String
        let data: [DriverService]
        let timestamp: String?
    }
}

struct DriverService: Decodable, Identifiable {
    let id: Int
    let name: String
    let displayName: String
    let description: String?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?
}

struct DriverSetServiceTypeResponse: Decodable {
    let status: String
    let message: String
    let data: DriverSetServiceTypeData
    let timestamp: String

    struct DriverSetServiceTypeData: Decodable {
        let token: String?
        let user: DriverUser
        let isRegistered: Bool?
    }
}

struct SetDriverServiceTypeRequest: Encodable {
    let serviceTypeId: Int
}

struct DriverServiceType: Codable {
    let id: Int
    let name: String
    let displayName: String
    let description: String?
    let isActive: Bool?
    let createdAt: String?
    let updatedAt: String?
}

struct DriverUser: Codable {
    let id: Int
    let phone: String
    let name: String?
    let email: String?
    let imageUrl: String?
    let dob: String?
    let gender: String?
    let cityId: Int?
    let isRegistered: Bool
    let serviceType: DriverServiceType?
    let serviceTypeId: Int?
    let createdAt: String?
    let carRideStatus: ServiceVerificationStatus?
    let motorcycleStatus: ServiceVerificationStatus?
    let taxiStatus: ServiceVerificationStatus?
    let rentalProfile: ServiceVerificationStatus?
}

struct DriverSendOTPResponse: Decodable {
    let status: String
    let message: String
    let data: DriverData
    let timestamp: String

    struct DriverData: Decodable {
        let token: String?
        let user: DriverUser
        let isRegistered: Bool?

        var resolvedIsRegistered: Bool { isRegistered ?? user.isRegistered }
    }
}

struct SendOTPResponse: Decodable {
    let status: String
    let message: String
    let data: DataClass
    let timestamp: String

    struct DataClass: Decodable {
        let token: String?
        let user: User?
        let isRegistered: Bool
    }
}

extension DriverUser {
    static func fromUser(_ user: User) -> DriverUser? {
        // Map User fields to DriverUser fields as best as possible
        return DriverUser(
            id: user.id,
            phone: user.phone,
            name: user.name,
            email: user.email,
            imageUrl: user.imageUrl,
            dob: user.dob,
            gender: user.gender,
            cityId: user.cityId,
            isRegistered: user.isRegistered,
            serviceType: user.serviceType,
            serviceTypeId: user.serviceTypeId,
            createdAt: user.createdAt,
            carRideStatus: user.carRideStatus,
            motorcycleStatus: user.motorcycleStatus,
            taxiStatus: user.taxiStatus,
            rentalProfile: user.rentalProfile
            
        )
    }
}
