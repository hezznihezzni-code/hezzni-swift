//
//  PassengerService.swift
//  Hezzni Pessenger
//
//  Created by GitHub Copilot on 1/20/26.
//

import Foundation

/// Raw item returned by `GET /api/passenger/services`.
struct PassengerServiceDTO: Decodable, Identifiable {
    let id: Int
    let name: String
    let createdAt: String?
    let updatedAt: String?
}

/// Full response envelope returned by `GET /api/passenger/services`.
struct PassengerServicesResponse: Decodable {
    let status: String
    let message: String
    let data: OuterData
    let timestamp: String?

    struct OuterData: Decodable {
        let status: String
        let data: [PassengerServiceDTO]
    }
}

/// App-facing model used by SwiftUI.
struct PassengerService: Identifiable, Hashable {
    let id: Int
    let name: String

    /// Local asset name for an icon. Backend doesn't send icons yet, so we map common names.
    var iconAssetName: String {
        switch name.lowercased() {
        case "car rides", "car", "car ride", "car rides service":
            return "car-service-icon"
        case "motorcycle", "bike", "bikes":
            return "motorcycle-service-icon"
        case "taxi":
            return "taxi-service-icon"
        case "airport ride", "ride to airport", "airport":
            return "airport-service-icon"
        case "rental car", "rental":
            return "rental-service-icon"
        case "reservation":
            return "reservation-service-icon"
        case "city to city taxi", "city to city":
            return "city-service-icon"
        case "delivery":
            return "delivery-service-icon"
        case "group ride", "shared ride":
            return "shared-service-icon"
        default:
            // Fallback to a safe, existing icon if name is unknown.
            return "car-service-icon"
        }
    }

    init(dto: PassengerServiceDTO) {
        self.id = dto.id
        self.name = dto.name
    }
}
