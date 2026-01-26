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
