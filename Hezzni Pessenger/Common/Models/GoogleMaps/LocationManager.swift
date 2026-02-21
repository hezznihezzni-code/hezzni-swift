//
//  LocationManager.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/10/25.
//

import SwiftUI
import GoogleMaps
internal import Combine

// Add this helper somewhere in your project
func getGoogleMapsAPIKey() -> String? {
    return Bundle.main.object(forInfoDictionaryKey: "AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0") as? String
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    private var geocoder = CLGeocoder()
    @Published var currentLocation: CLLocation?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    // Reverse geocode coordinates to get place name
    func reverseGeocode(coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first {
                var addressComponents: [String] = []
                
                if let name = placemark.name {
                    addressComponents.append(name)
                }
                if let locality = placemark.locality {
                    addressComponents.append(locality)
                }
                
                let address = addressComponents.joined(separator: ", ")
                completion(address.isEmpty ? "Selected Location" : address)
            } else {
                completion("Selected Location")
            }
        }
    }
    
    // Forward geocode address string to get coordinates
    func geocodeAddress(_ address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let placemark = placemarks?.first,
               let location = placemark.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    
    
    // Fetch directions from Google Directions API
    func fetchDirections(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D,
        completion: @escaping (GMSPath?, String?, String?) -> Void
    ) {
//        // Get API key from Google Services
//        guard let apiKey = "getGoogleMapsAPIKey()" else {
//            print("Google Maps API key not found 2")
//            completion(nil, nil, nil) // or appropriate default
//            return
//        }
        
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&key=AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0"
        
        guard let url = URL(string: urlString) else {
            completion(nil, nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Directions API error: \(error.localizedDescription)")
                completion(nil, nil, nil)
                return
            }
            
            guard let data = data else {
                completion(nil, nil, nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let route = routes.first,
                   let overviewPolyline = route["overview_polyline"] as? [String: Any],
                   let points = overviewPolyline["points"] as? String {
                    
                    // Parse duration and distance
                    var distanceText: String?
                    var durationText: String?
                    
                    if let legs = route["legs"] as? [[String: Any]],
                       let leg = legs.first {
                        if let distance = leg["distance"] as? [String: Any],
                           let distanceTextValue = distance["text"] as? String {
                            distanceText = distanceTextValue
                        }
                        if let duration = leg["duration"] as? [String: Any],
                           let durationTextValue = duration["text"] as? String {
                            durationText = durationTextValue
                        }
                    }
                    
                    let path = GMSPath(fromEncodedPath: points)
                    completion(path, distanceText, durationText)
                } else {
                    completion(nil, nil, nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(nil, nil, nil)
            }
        }.resume()
    }
    
    // Fetch place autocomplete suggestions from Google Places API
    func fetchPlacesSuggestions(
        query: String,
        location: CLLocationCoordinate2D? = nil,
        completion: @escaping ([PlaceSuggestion]) -> Void
    ) {
        guard !query.isEmpty else {
            completion([])
            return
        }
        
        // Minimum 3 characters for meaningful search
        guard query.count >= 2 else {
            completion([])
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        
        let apiKey = "AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0"
        
        // Build URL with optional location bias for better results
        var urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(encodedQuery)&key=\(apiKey)"
        
        // Add location bias if available (improves relevance of results)
        if let location = location ?? currentLocation?.coordinate {
            urlString += "&location=\(location.latitude),\(location.longitude)&radius=50000"
        }
        
        print("📍 Places API request: \(urlString.prefix(100))...") // Debug log
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL for Places API")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Places API error: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("❌ No data from Places API")
                completion([])
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Check API status
                    let status = json["status"] as? String ?? "UNKNOWN"
                    print("📍 Places API status: \(status)")
                    
                    if status != "OK" && status != "ZERO_RESULTS" {
                        if let errorMessage = json["error_message"] as? String {
                            print("❌ Places API error message: \(errorMessage)")
                        }
                        completion([])
                        return
                    }
                    
                    if let predictions = json["predictions"] as? [[String: Any]] {
                        print("📍 Found \(predictions.count) predictions")
                        
                        let suggestions = predictions.compactMap { prediction -> PlaceSuggestion? in
                            guard let placeId = prediction["place_id"] as? String,
                                  let description = prediction["description"] as? String else {
                                return nil
                            }
                            
                            let mainText = (prediction["structured_formatting"] as? [String: Any])?["main_text"] as? String ?? description
                            let secondaryText = (prediction["structured_formatting"] as? [String: Any])?["secondary_text"] as? String ?? ""
                            
                            return PlaceSuggestion(
                                placeId: placeId,
                                description: description,
                                mainText: mainText,
                                secondaryText: secondaryText
                            )
                        }
                        
                        completion(suggestions)
                    } else {
                        print("❌ No predictions in Places API response")
                        completion([])
                    }
                } else {
                    print("❌ Failed to parse Places API JSON")
                    completion([])
                }
            } catch {
                print("❌ JSON parsing error: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }
    
    // Get place details (coordinates) from place ID
    func fetchPlaceDetails(
        placeId: String,
        completion: @escaping (CLLocationCoordinate2D?, String?) -> Void
    ) {
//        guard let apiKey = getGoogleMapsAPIKey() else {
//            print("Google Maps API key not found 3")
//            completion(nil, nil)
//            return
//        }
        var apiKey: String = "AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0"
        
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeId)&fields=geometry,formatted_address&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Place Details API error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let geometry = result["geometry"] as? [String: Any],
                   let location = geometry["location"] as? [String: Any],
                   let lat = location["lat"] as? Double,
                   let lng = location["lng"] as? Double {
                    
                    let formattedAddress = result["formatted_address"] as? String
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                    completion(coordinate, formattedAddress)
                } else {
                    completion(nil, nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(nil, nil)
            }
        }.resume()
    }
}

// MARK: - Place Suggestion Model
struct PlaceSuggestion: Identifiable, Equatable, Codable {
    var id = UUID()
    let placeId: String
    let description: String
    let mainText: String
    let secondaryText: String
    var isFromHistory: Bool = false
}

// MARK: - Search History Manager
class SearchHistoryManager {
    static let shared = SearchHistoryManager()
    private let historyKey = "searchLocationHistory"
    
    func saveSuggestion(_ suggestion: PlaceSuggestion) {
        var historySuggestion = suggestion
        historySuggestion.isFromHistory = true
        
        var currentHistory = getHistory()
        // Remove if exists to move it to top
        currentHistory.removeAll { $0.placeId == suggestion.placeId }
        currentHistory.insert(historySuggestion, at: 0)
        // Keep max 10
        if currentHistory.count > 10 {
            currentHistory = Array(currentHistory.prefix(10))
        }
        
        if let encoded = try? JSONEncoder().encode(currentHistory) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    func getHistory() -> [PlaceSuggestion] {
        guard let data = UserDefaults.standard.data(forKey: historyKey),
              let history = try? JSONDecoder().decode([PlaceSuggestion].self, from: data) else {
            return []
        }
        return history
    }
    
    func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyKey)
    }
}
