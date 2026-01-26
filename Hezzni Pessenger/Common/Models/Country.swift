// Country.swift
import SwiftUI

struct Country: Identifiable, Hashable, Codable {
    let id = UUID()
    let code: String
    let name: String
    let flag: String
    let dialCode: String
    let pattern: String
    let placeholder: String
    
    enum CodingKeys: String, CodingKey {
        case code, name, flag, dialCode, pattern, placeholder
    }
    
    static let morocco = Country(
        code: "MA",
        name: "Morocco",
        flag: "🇲🇦",
        dialCode: "+212",
        pattern: "^[6-7]\\d{8}$",
        placeholder: "Enter your 9-digit mobile number starting with 6 or 7"
    )
    
    static let pakistan = Country(
        code: "PK",
        name: "Pakistan",
        flag: "🇵🇰",
        dialCode: "+92",
        pattern: "^3\\d{9}$",
        placeholder: "Enter your 10-digit mobile number starting with 3"
    )
    
    static let countries = [
        morocco,
        pakistan,
        Country(
            code: "US",
            name: "United States",
            flag: "🇺🇸",
            dialCode: "+1",
            pattern: "^\\d{10}$",
            placeholder: "Enter your 10-digit phone number"
        ),
        Country(
            code: "FR",
            name: "France",
            flag: "🇫🇷",
            dialCode: "+33",
            pattern: "^[6-7]\\d{8}$",
            placeholder: "Enter your 9-digit mobile number"
        ),
        Country(
            code: "ES",
            name: "Spain",
            flag: "🇪🇸",
            dialCode: "+34",
            pattern: "^[6-7]\\d{8}$",
            placeholder: "Enter your 9-digit mobile number"
        ),
        Country(
            code: "GB",
            name: "United Kingdom",
            flag: "🇬🇧",
            dialCode: "+44",
            pattern: "^7\\d{9}$",
            placeholder: "Enter your 10-digit mobile number"
        ),
        Country(
            code: "DE",
            name: "Germany",
            flag: "🇩🇪",
            dialCode: "+49",
            pattern: "^[1-9]\\d{10}$",
            placeholder: "Enter your phone number"
        ),
        Country(
            code: "IT",
            name: "Italy",
            flag: "🇮🇹",
            dialCode: "+39",
            pattern: "^[3]\\d{9}$",
            placeholder: "Enter your 10-digit mobile number"
        )
    ]
    
    var phonePlaceholder: String {
        // Try to extract starting digit and length from pattern
        // Examples:
        // ^[6-7]\d{8}$  => 6XXXXXXXX
        // ^3\d{9}$      => 3XXXXXXXXX
        // ^\d{10}$      => XXXXXXXXXX
        let pattern = self.pattern
        // 1. Try to match ^[digit(s)]\\d{N}$
        let regex1 = try? NSRegularExpression(pattern: "\\^\\[([0-9])-?([0-9])?\\]\\\\d\\{(\\d+)\\}\\$")
        if let match = regex1?.firstMatch(in: pattern, options: [], range: NSRange(location: 0, length: pattern.utf16.count)) {
            // Use the lower bound of the range as the first digit
            if let range1 = Range(match.range(at: 1), in: pattern), let range3 = Range(match.range(at: 3), in: pattern), let length = Int(pattern[range3]) {
                let firstDigit = String(pattern[range1])
                return firstDigit + String(repeating: "X", count: length)
            }
        }
        // 2. Try to match ^digit\\d{N}$
        let regex2 = try? NSRegularExpression(pattern: "\\^([0-9])\\\\d\\{(\\d+)\\}\\$")
        if let match = regex2?.firstMatch(in: pattern, options: [], range: NSRange(location: 0, length: pattern.utf16.count)) {
            if let range1 = Range(match.range(at: 1), in: pattern), let range2 = Range(match.range(at: 2), in: pattern), let length = Int(pattern[range2]) {
                let firstDigit = String(pattern[range1])
                return firstDigit + String(repeating: "X", count: length)
            }
        }
        // 3. Try to match ^\\d{N}$
        let regex3 = try? NSRegularExpression(pattern: "\\^\\\\d\\{(\\d+)\\}\\$")
        if let match = regex3?.firstMatch(in: pattern, options: [], range: NSRange(location: 0, length: pattern.utf16.count)) {
            if let range1 = Range(match.range(at: 1), in: pattern), let length = Int(pattern[range1]) {
                return String(repeating: "X", count: length)
            }
        }
        // Fallback: just 9 Xs
        return "XXXXXXXXX"
    }
}

