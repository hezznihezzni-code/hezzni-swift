//
//  AuthControllerCommented.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/29/25.
//

// MARK: - Updated Response Models
// MARK: - Flexible Response Models with Optional Fields
// struct SendOTPResponse: Decodable {
//     let status: String
//     let message: String
//     let data: OTPData?
//     let timestamp: String
//
//     struct OTPData: Decodable {
//         let otp: String
//         let phone: String
//         let success: Bool? // Make optional
//
//         enum CodingKeys: String, CodingKey {
//             case otp, phone, success
//         }
//
//         init(from decoder: Decoder) throws {
//             let container = try decoder.container(keyedBy: CodingKeys.self)
//             otp = try container.decode(String.self, forKey: .otp)
//             phone = try container.decode(String.self, forKey: .phone)
//             success = try container.decodeIfPresent(Bool.self, forKey: .success)
//         }
//     }
// }


//    // MARK: - Verify OTP (real API)
//    func verifyOTP(phoneNumber: String, otp: String) async -> Bool {
//        await MainActor.run {
//            isLoading = true
//            errorMessage = nil
//            successMessage = nil
//        }
//
//        do {
//            let parameters: [String: Any] = [
//                "phone": phoneNumber,
//                "otp": otp
//            ]
//
//            // Backend returns token + user + isRegistered in the login-style payload
//            let response: LoginResponse = try await APIService.shared.request(
//                endpoint: "/passenger/verify-otp",
//                method: "POST",
//                parameters: parameters
//            )
//
//            await MainActor.run {
//                isLoading = false
//                if response.status == "success" {
//                    successMessage = response.message
//                    errorMessage = nil
//
//                    currentUser = response.data.user
//
//                    if let token = response.data.token {
//                        authToken = token
//                        TokenManager.shared.saveToken(token)
//                    }
//
//                    UserDefaults.standard.set(response.data.isRegistered, forKey: "isUserRegistered")
//                    shouldNavigateToNextScreen = true
//                } else {
//                    errorMessage = response.message
//                    successMessage = nil
//                    shouldNavigateToNextScreen = false
//                }
//            }
//
//            return response.status == "success"
//        } catch {
//            await MainActor.run {
//                isLoading = false
//                errorMessage = handleAPIError(error)
//                successMessage = nil
//                shouldNavigateToNextScreen = false
//            }
//            return false
//        }
//    }
//



//----------------------------- Ride Info inside rideSummary Homescreen -----------------------------//
//
//            HStack(spacing: 0) {
//                // Distance
//                HStack(spacing: 4) {
//                    Text(String(format: "%.1f", estimatedDistance))
//                        .font(Font.custom("Poppins", size: 16).weight(.bold))
//                        .foregroundColor(.white)
//                    Text("KM")
//                        .font(Font.custom("Poppins", size: 12).weight(.medium))
//                        .foregroundColor(.white)
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
//                .cornerRadius(8, corners: [.topLeft, .bottomLeft])
//
//                // Duration
//                HStack(spacing: 4) {
//                    Text("\(estimatedDuration)")
//                        .font(Font.custom("Poppins", size: 16).weight(.bold))
//                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
//                    Text("min")
//                        .font(Font.custom("Poppins", size: 12).weight(.medium))
//                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
//                }
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(Color.white)
//                .cornerRadius(8, corners: [.topRight, .bottomRight])
//                .overlay(
//                    RoundedCorner(radius: 8, corners: [.topRight, .bottomRight])
//                        .stroke(Color(red: 0.92, green: 0.92, blue: 0.92), lineWidth: 1)
//                )
//            }
            
