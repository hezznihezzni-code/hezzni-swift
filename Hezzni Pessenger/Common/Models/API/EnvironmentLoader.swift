//
//  EnvironmentLoader.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/12/25.
//

import Foundation
internal import Combine

class EnvironmentLoader {
    static let shared = EnvironmentLoader()
    
    private var env: [String: String] = [:]
    
    private init() {
        loadEnvironment()
    }
    
    private func loadEnvironment() {
        // Get the path to the .env file
        if let envPath = Bundle.main.path(forResource: ".env", ofType: nil) {
            do {
                let envContent = try String(contentsOfFile: envPath)
                let lines = envContent.split(separator: "\n")
                
                for line in lines {
                    let parts = line.split(separator: "=", maxSplits: 1)
                    if parts.count == 2 {
                        let key = String(parts[0]).trimmingCharacters(in: .whitespaces)
                        let value = String(parts[1]).trimmingCharacters(in: .whitespaces)
                        env[key] = value
                    }
                }
            } catch {
                print("Error loading .env file: \(error)")
            }
        } else {
            print(".env file not found in bundle")
        }
    }
    
    func get(_ key: String) -> String? {
        return env[key]
    }
    
    func get(_ key: String, defaultValue: String) -> String {
        return env[key] ?? defaultValue
    }
}
