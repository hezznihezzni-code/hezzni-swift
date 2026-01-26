//
//  HezzniService.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/16/25.
//

// Service model
struct HezzniService: Identifiable {
    let id: String
    let icon: String
    let title: String
}

// List of services
let allHezzniServices = [
    HezzniService(id: "car", icon: "car-service-icon", title: "Car"),
    HezzniService(id: "motorcycle", icon: "motorcycle-service-icon", title: "Motorcycle"),
    HezzniService(id: "airport", icon: "airport-service-icon", title: "Ride to Airport"),
    HezzniService(id: "rental", icon: "rental-service-icon", title: "Rental Car"),
    HezzniService(id: "reservation", icon: "reservation-service-icon", title: "Reservation"),
    HezzniService(id: "city", icon: "city-service-icon", title: "City to City"),
    HezzniService(id: "taxi", icon: "taxi-service-icon", title: "Taxi"),
    HezzniService(id: "delivery", icon: "delivery-service-icon", title: "Delivery"),
    HezzniService(id: "group", icon: "shared-service-icon", title: "Group Ride")
]
