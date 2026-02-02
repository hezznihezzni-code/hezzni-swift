//
//  APIService.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/12/25.
//

import Foundation
import UIKit
internal import Combine

class APIService {
    static let shared = APIService()
    
    private let baseURL = URLEnvironment.baseURL
    
    private init() {}
    
    // MARK: - Public convenience APIs
    
    /// Login with phone number, stores auth token in TokenManager on success
    func login(phone: String) async throws -> LoginResponse {
        let response: LoginResponse = try await request(
            endpoint: "auth/login", // adjust to actual path if needed
            method: "POST",
            parameters: ["phone": phone]
        )
        if let token = response.data.token {
            TokenManager.shared.saveToken(token)
        }
        return response
    }
    
    /// Fetch full driver profile including onboarding statuses for all services
    func fetchDriverProfile() async throws -> DriverProfileResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/profile",
            method: "GET",
            parameters: nil,
            authToken: token
        )
    }
    
    
    // MARK: - Passenger Services

    /// Fetch passenger services list.
    func fetchPassengerServices() async throws -> [PassengerService] {
        let token = TokenManager.shared.token
        let response: PassengerServicesResponse = try await requestWithBearerAuth(
            endpoint: "/api/passenger/services",
            method: "GET",
            parameters: nil,
            authToken: token
        )
        return response.data.data.map(PassengerService.init(dto:))
    }

    /// Calculate ride price and get available ride options
    func calculateRidePrice(
        pickupLatitude: Double,
        pickupLongitude: Double,
        pickupAddress: String,
        dropoffLatitude: Double,
        dropoffLongitude: Double,
        dropoffAddress: String,
        passengerServiceId: Int
    ) async throws -> CalculateRidePriceResponse {
        let token = TokenManager.shared.token
        let parameters: [String: Any] = [
            "pickup": [
                "latitude": pickupLatitude,
                "longitude": pickupLongitude,
                "address": pickupAddress
            ],
            "dropoff": [
                "latitude": dropoffLatitude,
                "longitude": dropoffLongitude,
                "address": dropoffAddress
            ],
            "passengerServiceId": passengerServiceId
        ]
        return try await requestWithBearerAuth(
            endpoint: "/api/passenger/calculate-ride-price",
            method: "POST",
            parameters: parameters,
            authToken: token
        )
    }
    
    // MARK: - Driver Preferences + Presence

    /// Fetch driver ride preferences.
    func fetchDriverPreferences() async throws -> DriverPreferencesResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/preferences",
            method: "GET",
            parameters: nil,
            authToken: token
        )
    }

    /// Set driver online with selected preference IDs.
    func driverGoOnline(preferenceIds: [Int]) async throws -> DriverGoOnlineResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/status/online",
            method: "POST",
            parameters: ["preferenceIds": preferenceIds],
            authToken: token
        )
    }

    /// Set driver offline.
    func driverGoOffline() async throws -> DriverGoOfflineResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/status/offline",
            method: "POST",
            parameters: nil,
            authToken: token
        )
    }
// MARK: - Driver Profile Response Models
    struct DriverProfileResponse: Decodable {
        struct DriverProfileData: Decodable {
            let user: DriverUser
        }
        let status: String
        let message: String
        let data: DriverProfileData
        let timestamp: String
    }

    

    /// Complete profile (multipart: JSON fields + optional image). Uses stored token.
    func completeProfile(
        name: String,
        email: String?,
        dob: String?,
        gender: String?,
        cityId: Int?,
        image: UIImage?
    ) async throws -> CompleteProfileResponse {
        var params: [String: Any] = [
            "name": name
        ]
        if let email = email { params["email"] = email }
        if let dob = dob { params["dob"] = dob }
        if let gender = gender { params["gender"] = gender }
        if let cityId = cityId { params["cityId"] = cityId }
        
        let token = TokenManager.shared.token
        return try await uploadRequestPOST(
            endpoint: "/api/passenger/complete-registration",
            parameters: params,
            image: image,
            imageKey: "image",
            authToken: token
        )
    }
    /// Complete driver profile (multipart: JSON fields + optional image). Uses stored token.
        func completeDriverProfile(
            name: String,
            email: String?,
            dob: String?,
            gender: String?,
            
            cityId: Int?,
            image: UIImage?
        ) async throws -> CompleteProfileResponse {
            var params: [String: Any] = [
                "name": name
            ]
            if let email = email { params["email"] = email }
            if let dob = dob { params["dob"] = dob }
            if let gender = gender { params["gender"] = gender }
            if let cityId = cityId { params["cityId"] = cityId }
            
            let token = TokenManager.shared.token
            return try await uploadRequestPOST(
                endpoint: "/api/driver/complete-registration",
                parameters: params,
                image: image,
                imageKey: "image",
                authToken: token
            )
        }
    /// Fetch all cities
    func fetchCities() async throws -> [City] {
        let response: CitiesResponse = try await request(endpoint: "/api/cities", method: "GET")
        return response.data.data
    }
    
    /// Update passenger profile (multipart: fields + optional image). Uses stored bearer token.
    func updatePassengerProfile(
        name: String,
        email: String?,
        phone: String,
        dob: String?,
        gender: String,
        cityId: Int,
        image: UIImage?
    ) async throws -> UpdateProfileResponse {
        var params: [String: Any] = [
            "name": name,
            "phone": phone,
            "gender": gender,
            "cityId": cityId
        ]
        if let email = email { params["email"] = email }
        if let dob = dob { params["dob"] = dob }

        let token = TokenManager.shared.token
        return try await uploadRequestPUT(
            endpoint: "/api/passenger/profile",
            parameters: params,
            image: image,
            imageKey: "image",
            authToken: token
        )
    }
    
    // MARK: - Multipart form data upload methods
    func uploadRequestPOST<T: Decodable>(
        endpoint: String,
        parameters: [String: Any],
        image: UIImage?,
        imageKey: String,
        authToken: String? = nil
    ) async throws -> T {
        let fullURL = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let authToken = authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        var body = Data()
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        print("API Upload Request: POST \(fullURL.absoluteString)")
        print("Parameters: \(parameters)")
        print("Image included: \(image != nil)")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        print("Status Code: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "Unable to decode response")")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        case 400:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.apiError(message: errorResponse.message)
            } else {
                throw APIError.httpError(statusCode: 400)
            }
        case 401...499:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.invalidResponse
        }
    }
    func uploadRequestPUT<T: Decodable>(
        endpoint: String,
        parameters: [String: Any],
        image: UIImage?,
        imageKey: String,
        authToken: String? = nil
    ) async throws -> T {
        let fullURL = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: fullURL)
        request.httpMethod = "PUT"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let authToken = authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        var body = Data()
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        print("API Upload Request: PUT \(fullURL.absoluteString)")
        print("Parameters: \(parameters)")
        print("Image included: \(image != nil)")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        print("Status Code: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                print("Raw API Response: \(String(data: data, encoding: .utf8) ?? "Unable to decode response")")
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        case 400:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.apiError(message: errorResponse.message)
            } else {
                throw APIError.httpError(statusCode: 400)
            }
        case 401...499:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.invalidResponse
        }
    }
    func request<T: Decodable>(endpoint: String, method: String = "GET", parameters: [String: Any]? = nil, authToken: String? = nil
) async throws -> T {
        let fullURL = baseURL.appendingPathComponent(endpoint)
        
        var request = URLRequest(url: fullURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let authToken = authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        if let parameters = parameters, method != "GET" {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }
        
        print("API Request: \(method) \(fullURL.absoluteString)")
        if let parameters = parameters {
            print("Parameters: \(parameters)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Print response for debugging
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        print("Status Code: \(httpResponse.statusCode)")
        
        // Handle different status codes
        switch httpResponse.statusCode {
        case 200...299:
            // Success - parse response
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
            
        case 400:
            // Bad Request - try to parse error message
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.apiError(message: errorResponse.message)
            } else {
                throw APIError.httpError(statusCode: 400)
            }
            
        case 401...499:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
            
        case 500...599:
            throw APIError.serverError
            
        default:
            throw APIError.invalidResponse
        }
    }
    
    // MARK: - Driver Services
    func fetchDriverServices() async throws -> [DriverService] {
        let token = TokenManager.shared.token
        let response: DriverServicesResponse = try await request(
            endpoint: "/api/driver/services",
            method: "GET",
            parameters: nil,
            authToken: token
            
        )
        return response.data.data
    }

    func setDriverServiceType(serviceTypeId: Int) async throws -> DriverSetServiceTypeResponse {
        let token = TokenManager.shared.token
        let response: DriverSetServiceTypeResponse = try await requestWithBearerAuth(
            endpoint: "/api/driver/service-type",
            method: "POST",
            parameters: ["serviceTypeId": serviceTypeId],
            authToken: token
        )

        // If backend returns a token again, refresh it.
        if let newToken = response.data.token {
            TokenManager.shared.saveToken(newToken)
        }

        // Persist updated driver user if possible.
        UserDefaults.standard.saveDriverUser(response.data.user)

        return response
    }

    // MARK: - Authenticated JSON request helper
    func requestWithBearerAuth<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        parameters: [String: Any]? = nil,
        authToken: String?
    ) async throws -> T {
        let fullURL = baseURL.appendingPathComponent(endpoint)

        var request = URLRequest(url: fullURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        if let parameters = parameters, method != "GET" {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }

        print("API Request: \(method) \(fullURL.absoluteString)")
        if let parameters { print("Parameters: \(parameters)") }
        if authToken != nil { print("Auth: Bearer <redacted>") }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("Status Code: \(httpResponse.statusCode)")

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        case 400:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.apiError(message: errorResponse.message)
            } else {
                throw APIError.httpError(statusCode: 400)
            }
        case 401...499:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.invalidResponse
        }
    }
    // MARK: - Rental Profile APIs
    /// Create rental profile (multipart: fields + logo + CR document)
    func createRentalProfile(
        companyName: String,
        businessAddress: String,
        operatingCityId: Int,
        website: String?,
        crNumber: String,
        logo: UIImage,
        crDocument: UIImage
    ) async throws -> RentalProfileResponse {
        var params: [String: Any] = [
            "companyName": companyName,
            "businessAddress": businessAddress,
            "operatingCityId": operatingCityId,
            "crNumber": crNumber
        ]
        if let website = website { params["website"] = website }
        let token = TokenManager.shared.token
        // Compose multipart with two images
        return try await uploadRentalProfileMultipart(
            endpoint: "/api/driver/rental/profile",
            parameters: params,
            logo: logo,
            crDocument: crDocument,
            authToken: token
        )
    }

    /// Fetch rental profile
    func fetchRentalProfile() async throws -> RentalProfileResponse {
        let token = TokenManager.shared.token
        return try await request(
            endpoint: "/api/driver/rental/profile",
            method: "GET",
            parameters: nil,
            authToken: token
        )
    }

    /// Multipart upload for rental profile (logo + CR document)
    private func uploadRentalProfileMultipart<T: Decodable>(
        endpoint: String,
        parameters: [String: Any],
        logo: UIImage,
        crDocument: UIImage,
        authToken: String? = nil
    ) async throws -> T {
        let fullURL = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: fullURL)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let authToken = authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        var body = Data()
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        // Logo
        if let logoData = logo.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"logo\"; filename=\"logo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(logoData)
            body.append("\r\n".data(using: .utf8)!)
        }
        // CR Document
        if let crDocData = crDocument.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"crDocument\"; filename=\"cr_document.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(crDocData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        print("API Upload Request: POST \(fullURL.absoluteString)")
        print("Parameters: \(parameters)")
        print("Logo included: true, CR Document included: true")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        print("Status Code: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError(error)
            }
        case 400:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.apiError(message: errorResponse.message)
            } else {
                throw APIError.httpError(statusCode: 400)
            }
        case 401...499:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.invalidResponse
        }
    }

    // MARK: - Driver Car Rides / Motorcycle / Taxi Onboarding

    // Shared status response model (car-rides + motorcycle). Taxi adds rejectionReason + taxi license flag.
    func fetchCarRidesOnboardingStatus() async throws -> CarRidesOnboardingStatusResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/car-rides/status",
            method: "GET",
            parameters: nil,
            authToken: token
        )
    }

    func fetchMotorcycleOnboardingStatus() async throws -> MotorcycleOnboardingStatusResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/motorcycle/status",
            method: "GET",
            parameters: nil,
            authToken: token
        )
    }

    func fetchTaxiOnboardingStatus() async throws -> TaxiOnboardingStatusResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/taxi/status",
            method: "GET",
            parameters: nil,
            authToken: token
        )
    }

    // MARK: Car rides uploads

    func uploadCarRidesNationalId(_ payload: NationalIdPayload, frontImage: UIImage, backImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadTwoImagesWithParameters(
            endpoint: "/api/driver/car-rides/national-id",
            method: "POST",
            parameters: payload.asParameters,
            firstImage: frontImage,
            firstImageKey: "frontImage",
            secondImage: backImage,
            secondImageKey: "backImage",
            authToken: token
        )
    }

    func uploadCarRidesDriverLicense(_ payload: DriverLicensePayload, frontImage: UIImage, backImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadTwoImagesWithParameters(
            endpoint: "/api/driver/car-rides/driver-license",
            method: "POST",
            parameters: payload.asParameters,
            firstImage: frontImage,
            firstImageKey: "frontImage",
            secondImage: backImage,
            secondImageKey: "backImage",
            authToken: token
        )
    }

    func uploadCarRidesProfessionalCard(cardImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/car-rides/professional-card",
            method: "POST",
            parameters: [:],
            image: cardImage,
            imageKey: "cardImage",
            authToken: token
        )
    }

    func uploadCarRidesVehicleRegistration(registrationImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/car-rides/vehicle-registration",
            method: "POST",
            parameters: [:],
            image: registrationImage,
            imageKey: "registrationImage",
            authToken: token
        )
    }

    func uploadCarRidesVehicleInsurance(insuranceImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/car-rides/insurance",
            method: "POST",
            parameters: [:],
            image: insuranceImage,
            imageKey: "insuranceImage",
            authToken: token
        )
    }

    func updateCarRidesVehicleDetails(_ details: CarVehicleDetailsPayload) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/car-rides/vehicle-details",
            method: "POST",
            parameters: details.asParameters,
            authToken: token
        )
    }

    func uploadCarRidesVehiclePhotos(frontView: UIImage, rearView: UIImage, leftView: UIImage, rightView: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadFourImagesWithParameters(
            endpoint: "/api/driver/car-rides/vehicle-photos",
            method: "POST",
            parameters: [:],
            images: [
                (key: "frontView", image: frontView),
                (key: "rearView", image: rearView),
                (key: "leftView", image: leftView),
                (key: "rightView", image: rightView)
            ],
            authToken: token
        )
    }

    func uploadCarRidesFaceVerification(selfieImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/car-rides/face-verification",
            method: "POST",
            parameters: [:],
            image: selfieImage,
            imageKey: "selfieImage",
            authToken: token
        )
    }

    // MARK: Motorcycle uploads

    func uploadMotorcycleNationalId(_ payload: NationalIdPayload, frontImage: UIImage, backImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadTwoImagesWithParameters(
            endpoint: "/api/driver/motorcycle/national-id",
            method: "POST",
            parameters: payload.asParameters,
            firstImage: frontImage,
            firstImageKey: "frontImage",
            secondImage: backImage,
            secondImageKey: "backImage",
            authToken: token
        )
    }

    func uploadMotorcycleDriverLicense(_ payload: DriverLicensePayload, frontImage: UIImage, backImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadTwoImagesWithParameters(
            endpoint: "/api/driver/motorcycle/driver-license",
            method: "POST",
            parameters: payload.asParameters,
            firstImage: frontImage,
            firstImageKey: "frontImage",
            secondImage: backImage,
            secondImageKey: "backImage",
            authToken: token
        )
    }

    func uploadMotorcycleProfessionalCard(cardImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/motorcycle/professional-card",
            method: "POST",
            parameters: [:],
            image: cardImage,
            imageKey: "cardImage",
            authToken: token
        )
    }

    func uploadMotorcycleVehicleRegistration(registrationImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/motorcycle/vehicle-registration",
            method: "POST",
            parameters: [:],
            image: registrationImage,
            imageKey: "registrationImage",
            authToken: token
        )
    }

    func uploadMotorcycleVehicleInsurance(insuranceImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/motorcycle/insurance",
            method: "POST",
            parameters: [:],
            image: insuranceImage,
            imageKey: "insuranceImage",
            authToken: token
        )
    }

    func updateMotorcycleVehicleDetails(_ details: MotorcycleVehicleDetailsPayload) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/motorcycle/vehicle-details",
            method: "POST",
            parameters: details.asParameters,
            authToken: token
        )
    }

    func uploadMotorcycleVehiclePhotos(frontView: UIImage, rearView: UIImage, leftView: UIImage, rightView: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadFourImagesWithParameters(
            endpoint: "/api/driver/motorcycle/vehicle-photos",
            method: "POST",
            parameters: [:],
            images: [
                (key: "frontView", image: frontView),
                (key: "rearView", image: rearView),
                (key: "leftView", image: leftView),
                (key: "rightView", image: rightView)
            ],
            authToken: token
        )
    }

    func uploadMotorcycleFaceVerification(selfieImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/motorcycle/face-verification",
            method: "POST",
            parameters: [:],
            image: selfieImage,
            imageKey: "selfieImage",
            authToken: token
        )
    }

    // MARK: Taxi uploads

    func uploadTaxiNationalId(_ payload: NationalIdPayload, frontImage: UIImage, backImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadTwoImagesWithParameters(
            endpoint: "/api/driver/taxi/national-id",
            method: "POST",
            parameters: payload.asParameters,
            firstImage: frontImage,
            firstImageKey: "frontImage",
            secondImage: backImage,
            secondImageKey: "backImage",
            authToken: token
        )
    }

    func uploadTaxiDriverLicense(_ payload: DriverLicensePayload, frontImage: UIImage, backImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadTwoImagesWithParameters(
            endpoint: "/api/driver/taxi/driver-license",
            method: "POST",
            parameters: payload.asParameters,
            firstImage: frontImage,
            firstImageKey: "frontImage",
            secondImage: backImage,
            secondImageKey: "backImage",
            authToken: token
        )
    }

    func uploadTaxiLicense(licenseImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/taxi/taxi-license",
            method: "POST",
            parameters: [:],
            image: licenseImage,
            imageKey: "licenseImage",
            authToken: token
        )
    }

    func uploadTaxiProfessionalCard(cardImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/taxi/professional-card",
            method: "POST",
            parameters: [:],
            image: cardImage,
            imageKey: "cardImage",
            authToken: token
        )
    }

    func uploadTaxiVehicleRegistration(registrationImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/taxi/vehicle-registration",
            method: "POST",
            parameters: [:],
            image: registrationImage,
            imageKey: "registrationImage",
            authToken: token
        )
    }

    func uploadTaxiVehicleInsurance(insuranceImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/taxi/insurance",
            method: "POST",
            parameters: [:],
            image: insuranceImage,
            imageKey: "insuranceImage",
            authToken: token
        )
    }

    func updateTaxiVehicleDetails(_ details: CarVehicleDetailsPayload) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await requestWithBearerAuth(
            endpoint: "/api/driver/taxi/vehicle-details",
            method: "POST",
            parameters: details.asParameters,
            authToken: token
        )
    }

    func uploadTaxiVehiclePhotos(frontView: UIImage, rearView: UIImage, leftView: UIImage, rightView: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadFourImagesWithParameters(
            endpoint: "/api/driver/taxi/vehicle-photos",
            method: "POST",
            parameters: [:],
            images: [
                (key: "frontView", image: frontView),
                (key: "rearView", image: rearView),
                (key: "leftView", image: leftView),
                (key: "rightView", image: rightView)
            ],
            authToken: token
        )
    }

    func uploadTaxiFaceVerification(selfieImage: UIImage) async throws -> EmptyResponse {
        let token = TokenManager.shared.token
        return try await uploadSingleImageWithParameters(
            endpoint: "/api/driver/taxi/face-verification",
            method: "POST",
            parameters: [:],
            image: selfieImage,
            imageKey: "selfieImage",
            authToken: token
        )
    }

    // MARK: - Multipart helpers (generic)

    private func uploadSingleImageWithParameters<T: Decodable>(
        endpoint: String,
        method: String,
        parameters: [String: Any],
        image: UIImage,
        imageKey: String,
        authToken: String?
    ) async throws -> T {
        return try await uploadMultipart(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            images: [(key: imageKey, image: image)],
            authToken: authToken
        )
    }

    private func uploadTwoImagesWithParameters<T: Decodable>(
        endpoint: String,
        method: String,
        parameters: [String: Any],
        firstImage: UIImage,
        firstImageKey: String,
        secondImage: UIImage,
        secondImageKey: String,
        authToken: String?
    ) async throws -> T {
        return try await uploadMultipart(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            images: [(key: firstImageKey, image: firstImage), (key: secondImageKey, image: secondImage)],
            authToken: authToken
        )
    }

    private func uploadFourImagesWithParameters<T: Decodable>(
        endpoint: String,
        method: String,
        parameters: [String: Any],
        images: [(key: String, image: UIImage)],
        authToken: String?
    ) async throws -> T {
        // Ensure exactly 4 images to avoid backend surprises.
        guard images.count == 4 else {
            throw APIError.apiError(message: "Expected 4 images, got \(images.count)")
        }
        return try await uploadMultipart(
            endpoint: endpoint,
            method: method,
            parameters: parameters,
            images: images,
            authToken: authToken
        )
    }

    private func uploadMultipart<T: Decodable>(
        endpoint: String,
        method: String,
        parameters: [String: Any],
        images: [(key: String, image: UIImage)],
        authToken: String?
    ) async throws -> T {
        let fullURL = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: fullURL)
        request.httpMethod = method

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let authToken {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()

        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        for (key, image) in images {
            guard let imageData = image.jpegData(compressionQuality: 0.8) else { continue }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(key).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("API Upload Request: \(method) \(fullURL.absoluteString)")
        print("Parameters: \(parameters)")
        print("Images included: \(images.map { $0.key })")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let responseString = String(data: data, encoding: .utf8) {
            print("API Response: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            // Some endpoints return empty body; attempt decode but fall back to EmptyResponse.
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            if data.isEmpty {
                // If endpoint returns empty and T isn't EmptyResponse, this is a contract mismatch.
                throw APIError.invalidResponse
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 400:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.apiError(message: errorResponse.message)
            } else {
                throw APIError.httpError(statusCode: 400)
            }
        case 401...499:
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        case 500...599:
            throw APIError.serverError
        default:
            throw APIError.invalidResponse
        }
    }
}

// MARK: - Auth Models

struct LoginResponse: Decodable {
    struct LoginData: Decodable {
        let token: String?
        let user: User
        let isRegistered: Bool
    }
    let status: String
    let message: String
    let data: LoginData
    let timestamp: String
}

struct CompleteProfileResponse: Decodable {
    struct CompleteData: Decodable {
        let user: User
    }
    let status: String
    let message: String
    let data: CompleteData
    let timestamp: String
}

// MARK: - Cities API Models
struct CitiesResponse: Decodable {
    let status: String
    let message: String
    let data: CitiesData
    let timestamp: String
}

struct CitiesData: Decodable {
    let status: String
    let data: [City]
    let timestamp: String
}

struct City: Decodable {
    let id: Int
    let name: String
    let isActive: Bool
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?
}

// MARK: - Update Profile API Model
struct UpdateProfileResponse: Decodable {
    struct UpdateProfileData: Decodable {
        let user: User
    }

    let status: String
    let message: String
    let data: UpdateProfileData
    let timestamp: String
}

// MARK: - Token Manager

final class TokenManager {
    static let shared = TokenManager()
    private let tokenKey = "authToken"
    
    private init() {}
    
    var token: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }
    
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}

// Error Models
struct ErrorResponse: Decodable {
    let status: String
    let message: String
    let timestamp: String
}

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case serverError
    case decodingError(Error)
    case apiError(message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .serverError:
            return "Server error. Please try again later."
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .apiError(let message):
            return message
        }
    }
}

// MARK: - Rental Profile Models
struct RentalProfileResponse: Codable {
    struct RentalProfileData: Decodable {
        let id: Int
        let companyName: String
        let logoUrl: String
        let businessAddress: String
        let operatingCityId: Int
        let website: String?
        let crNumber: String
        let crDocumentUrl: String
        let status: String
        let createdAt: String
    }
    let status: String
    let message: String
    let data: RentalProfileData
    let timestamp: String
}

// MARK: - Onboarding Models

/// Generic API wrapper used by many endpoints: { status, message, data, timestamp }
struct APIWrappedResponse<T: Decodable>: Decodable {
    let status: String
    let message: String
    let data: T
    let timestamp: String?
}

/// The payload we care about from /api/driver/*/status endpoints.
/// Note: keep everything optional to avoid keyNotFound crashes if the backend omits a field.
struct DriverOnboardingStatusData: Decodable {
    let id: Int?
    let driverId: Int?
    let status: String?
    let rejectionReason: String?

    let isNationalIdCompleted: Bool?
    let isDriverLicenseCompleted: Bool?
    let isProfessionalCardCompleted: Bool?
    let isVehicleRegistrationCompleted: Bool?
    let isVehicleInsuranceCompleted: Bool?
    let isVehicleDetailsCompleted: Bool?
    let isVehiclePhotosCompleted: Bool?
    let isFaceVerificationCompleted: Bool?

    // Taxi-only field
    let isTaxiLicenseCompleted: Bool?

    // Motorcycle status includes nested objects
    let documents: DriverOnboardingDocuments?
    let vehicle: DriverOnboardingVehicle?

    let createdAt: String?
    let updatedAt: String?
}

struct DriverOnboardingDocuments: Decodable {
    let id: Int?
    let requestId: Int?

    let nicFrontUrl: String?
    let nicBackUrl: String?
    let nicFullName: String?
    let nicNumber: String?
    let nicDob: String?
    let nicGender: String?
    let nicExpiry: String?
    let nicAddress: String?

    let licenseFrontUrl: String?
    let licenseBackUrl: String?
    let licenseFullName: String?
    let licenseNumber: String?
    let licenseDob: String?
    let licenseExpiry: String?
    let licenseAuthority: String?
    let licenseAddress: String?

    let proCardUrl: String?
    let registrationUrl: String?
    let insuranceUrl: String?
    let selfieUrl: String?

    let createdAt: String?
    let updatedAt: String?
}

struct DriverOnboardingVehicle: Decodable {
    let id: Int?
    let requestId: Int?

    let make: String?
    let model: String?
    let year: Int?

    let plateNumber: String?
    let plateLetter: String?
    let plateCode: String?

    let cityId: Int?

    let photoFrontUrl: String?
    let photoRearUrl: String?
    let photoLeftUrl: String?
    let photoRightUrl: String?

    let createdAt: String?
    let updatedAt: String?
}

/// These are the response types used by the APIService fetch*Status() methods.
/// They match the real server shape (wrapped response).
typealias CarRidesOnboardingStatusResponse = APIWrappedResponse<DriverOnboardingStatusData>
typealias MotorcycleOnboardingStatusResponse = APIWrappedResponse<DriverOnboardingStatusData>
typealias TaxiOnboardingStatusResponse = APIWrappedResponse<DriverOnboardingStatusData>

// MARK: - Onboarding Payloads

struct NationalIdPayload {
    /// Backend expects: nationalIdNumber (string, non-empty)
    let number: String
    let fullName: String
    /// Backend expects ISO-8601 date string
    let dob: String
    /// Backend expects specific enum values (coordinate with backend); we send the string as-is.
    let gender: String
    /// Backend expects ISO-8601 date string and key `expiryDate`
    let expiry: String
    let address: String

    var asParameters: [String: Any] {
        [
            // Keep legacy keys for safety if older backend versions still accept them
            "number": number,
            "expiry": expiry,

            // Preferred keys (per backend validation errors)
            "nationalIdNumber": number,
            "fullName": fullName,
            "dob": dob,
            "gender": gender,
            "expiryDate": expiry,
            "address": address
        ]
    }
}

struct DriverLicensePayload {
    /// Backend expects: driverLicenseNumber (string, non-empty)
    let number: String
    let fullName: String
    /// Backend expects ISO-8601 date string
    let dob: String
    /// Backend expects ISO-8601 date string and key `expiryDate`
    let expiry: String
    /// Backend expects issuingAuthority
    let authority: String
    let address: String

    var asParameters: [String: Any] {
        [
            // Legacy keys
            "number": number,
            "expiry": expiry,
            "authority": authority,

            // Preferred keys
            "driverLicenseNumber": number,
            "fullName": fullName,
            "dob": dob,
            "expiryDate": expiry,
            "issuingAuthority": authority,
            "address": address
        ]
    }
}

/// Some onboarding endpoints return 201 with an empty body.
struct EmptyResponse: Decodable {
    init() {}
}

// Ensure all nested types are Encodable (for persistence)
//extension CarRidesOnboardingStatusResponse: Encodable {}
//extension TaxiOnboardingStatusResponse: Encodable {}
extension RentalProfileResponse.RentalProfileData: Encodable {}

struct CarVehicleDetailsPayload {
    let make: String
    let model: String
    let year: Int
    let plateNumber: String
//    let color: String
//    let seats: Int
//    let region: String
    let cityId: Int

    var asParameters: [String: Any] {
        [
            "make": make,
            "model": model,
            "year": year,
            "plateNumber": plateNumber,
//            "color": color,
//            "seats": seats,
//            "region": region,
            "cityId": cityId
        ]
    }
}

struct MotorcycleVehicleDetailsPayload {
    let make: String
    let model: String
    let year: Int
    let plateNumber: String
    let plateLetter: String
    let plateCode: String
    let cityId: Int

    var asParameters: [String: Any] {
        [
            "make": make,
            "model": model,
            "year": year,
            "plateNumber": plateNumber,
            "plateLetter": plateLetter,
            "plateCode": plateCode,
            "cityId": cityId
        ]
    }
}

// MARK: - Ride Price Calculation Models

struct CalculateRidePriceResponse: Decodable {
    struct RideOption: Decodable {
        let id: Int
        let ridePreference: String
        let ridePreferenceKey: String
        let description: String
        let price: Double
    }
    
    struct LocationData: Decodable {
        let latitude: Double
        let longitude: Double
        let address: String
    }
    
    struct PriceData: Decodable {
        let passengerService: PassengerServiceInfo
        let distance: Double
        let estimatedDuration: Int
        let pickup: LocationData
        let dropoff: LocationData
        let options: [RideOption]
    }
    
    struct PassengerServiceInfo: Decodable {
        let id: Int
        let name: String
    }
    
    let status: String
    let message: String
    let data: PriceData
    let timestamp: String
}
