//
//  URLEnvironment.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/12/25.
//


import Foundation
internal import Combine

enum URLEnvironment {
    static let baseURL: URL = {
        let urlString = EnvironmentLoader.shared.get("BASE_API_URL") ?? "https://api.hezzni.com"
        
        guard let url = URL(string: urlString) else {
            fatalError("Invalid base URL: \(urlString)")
        }
        
        return url
    }()
    
    static var healthCheckURL: URL {
        baseURL.appendingPathComponent("/api/health")
    }
    
    // Helper to construct image URLs
    static func imageURL(for path: String?) -> URL? {
        guard let path = path, !path.isEmpty else { return nil }
        return URL(string: "https://api.hezzni.com" + path)
    }
}
