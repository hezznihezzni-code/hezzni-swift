//
//  JWTHelper.swift
//  Hezzni
//
//  JWT Token Helper - Decodes JWT tokens to extract userId
//

import Foundation

struct JWTHelper {
    /// Decode JWT token and extract userId from payload
    /// - Parameter token: JWT token string
    /// - Returns: userId if found, nil otherwise
    static func extractUserId(from token: String) -> Int? {
        let segments = token.components(separatedBy: ".")
        
        // JWT has 3 parts: header.payload.signature
        guard segments.count == 3 else {
            print("❌ Invalid JWT format")
            return nil
        }
        
        // Decode the payload (second segment)
        let payloadSegment = segments[1]
        
        // Add padding if needed (Base64 requires length to be multiple of 4)
        var base64String = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let paddingLength = 4 - base64String.count % 4
        if paddingLength < 4 {
            base64String += String(repeating: "=", count: paddingLength)
        }
        
        // Decode from Base64
        guard let data = Data(base64Encoded: base64String) else {
            print("❌ Failed to decode JWT payload from base64")
            return nil
        }
        
        // Parse JSON
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("🔍 JWT Payload: \(json)")
                
                // Try userId field first (as Int)
                if let userId = json["userId"] as? Int {
                    print("✅ Found userId (Int): \(userId)")
                    return userId
                }
                
                // Try userId field as String
                if let userIdString = json["userId"] as? String, let userId = Int(userIdString) {
                    print("✅ Found userId (String): \(userId)")
                    return userId
                }
                
                // Try id field (as Int)
                if let userId = json["id"] as? Int {
                    print("✅ Found id (Int): \(userId)")
                    return userId
                }
                
                // Try id field as String
                if let idString = json["id"] as? String, let userId = Int(idString) {
                    print("✅ Found id (String): \(userId)")
                    return userId
                }
                
                // Try sub field (as Int) - common in JWT
                if let userId = json["sub"] as? Int {
                    print("✅ Found sub (Int): \(userId)")
                    return userId
                }
                
                // Try sub field as String (most common JWT format)
                if let subString = json["sub"] as? String {
                    print("🔍 sub value is String: '\(subString)'")
                    if let userId = Int(subString) {
                        print("✅ Converted sub to Int: \(userId)")
                        return userId
                    }
                }
                
                // Try sub as NSNumber (JSON numbers can be parsed as NSNumber)
                if let subNumber = json["sub"] as? NSNumber {
                    let userId = subNumber.intValue
                    print("✅ Found sub (NSNumber): \(userId)")
                    return userId
                }
                
                print("❌ userId not found in JWT payload.")
                print("   Available keys: \(json.keys)")
                print("   sub value: \(String(describing: json["sub"]))")
                print("   sub type: \(type(of: json["sub"]))")
            }
        } catch {
            print("❌ Failed to parse JWT payload JSON: \(error)")
        }
        
        return nil
    }
}
