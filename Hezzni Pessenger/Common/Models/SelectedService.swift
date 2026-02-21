//
//  SelectedService.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 2/3/26.
//

import Foundation

/// Represents a selected passenger service with its ID and name.
/// Used to pass service information throughout the app for API calls.
struct SelectedService: Equatable, Hashable {
    let id: Int
    let name: String
    
    /// Icon asset name based on service name
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
            return "car-service-icon"
        }
    }
    
    /// Display name for UI (shortened version)
    var displayName: String {
        return name
//        switch name.lowercased() {
//        case "car rides":
//            return "Car"
//        case "airport ride":
//            return "Ride to Airport"
//        case "city to city":
//            return "City to City"
//        case "group ride":
//            return "Group Ride"
//        default:
//            return name
//        }
    }
    
    /// Default service when nothing is selected
    static let defaultService = SelectedService(id: 1, name: "Car Rides")
    
    /// Create from PassengerService model
    init(from service: PassengerService) {
        self.id = service.id
        self.name = service.name
    }
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
