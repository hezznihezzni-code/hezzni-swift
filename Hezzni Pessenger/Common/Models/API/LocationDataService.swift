// LocationDataService.swift
import Foundation
internal import Combine

/// Local lightweight city model for location UI (separate from the API `City` model).
struct LocationCity: Identifiable, Hashable {
    let id: UUID = UUID()
    let name: String
    let countryCode: String
    let latitude: Double
    let longitude: Double
}

extension LocationCity: CustomStringConvertible {
    var description: String { name }
}

class LocationDataService: ObservableObject {
    @Published var countries: [Country] = []
    @Published var cities: [LocationCity] = []
    @Published var isLoading = false
    
    init() {
        loadCountries()
        loadCities()
    }
    
    // Load countries from JSON or use default
    public func loadCountries() {
        // Use the static countries from your existing Country struct
        self.countries = Country.countries
    }
    
    // Load cities from JSON
    public func loadCities() {
        // Fallback to default cities
        self.cities = getDefaultCities()
    }
    
    // Filter cities by country code
    func getCities(for countryCode: String) -> [LocationCity] {
        return cities.filter { $0.countryCode == countryCode }
    }
    
    // Default cities fallback
    private func getDefaultCities() -> [LocationCity] {
        return [
            LocationCity(name: "Casablanca", countryCode: "MA", latitude: 33.5731, longitude: -7.5898),
            LocationCity(name: "Rabat", countryCode: "MA", latitude: 34.0209, longitude: -6.8416),
            LocationCity(name: "Marrakech", countryCode: "MA", latitude: 31.6295, longitude: -7.9811),
            LocationCity(name: "Fes", countryCode: "MA", latitude: 34.0181, longitude: -5.0078),
            LocationCity(name: "Tangier", countryCode: "MA", latitude: 35.7595, longitude: -5.8340),
            
            LocationCity(name: "Karachi", countryCode: "PK", latitude: 24.8607, longitude: 67.0011),
            LocationCity(name: "Lahore", countryCode: "PK", latitude: 31.5204, longitude: 74.3587),
            LocationCity(name: "Islamabad", countryCode: "PK", latitude: 33.6844, longitude: 73.0479),
            LocationCity(name: "Rawalpindi", countryCode: "PK", latitude: 33.5651, longitude: 73.0169),
            LocationCity(name: "Faisalabad", countryCode: "PK", latitude: 31.4504, longitude: 73.1350),
            
            LocationCity(name: "New York", countryCode: "US", latitude: 40.7128, longitude: -74.0060),
            LocationCity(name: "Los Angeles", countryCode: "US", latitude: 34.0522, longitude: -118.2437),
            LocationCity(name: "Chicago", countryCode: "US", latitude: 41.8781, longitude: -87.6298),
            LocationCity(name: "Houston", countryCode: "US", latitude: 29.7604, longitude: -95.3698),
            
            LocationCity(name: "Paris", countryCode: "FR", latitude: 48.8566, longitude: 2.3522),
            LocationCity(name: "Marseille", countryCode: "FR", latitude: 43.2965, longitude: 5.3698),
            LocationCity(name: "Lyon", countryCode: "FR", latitude: 45.7640, longitude: 4.8357),
            
            LocationCity(name: "Madrid", countryCode: "ES", latitude: 40.4168, longitude: -3.7038),
            LocationCity(name: "Barcelona", countryCode: "ES", latitude: 41.3851, longitude: 2.1734),
            LocationCity(name: "Valencia", countryCode: "ES", latitude: 39.4699, longitude: -0.3763)
        ]
    }
}
