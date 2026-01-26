//
//  ErrorSheet.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/31/25.
//
import SwiftUI

struct ErrorSheet: View {
    var imageName: String
    var title: String
    var message: String
    var buttonText: String
    var onButtonTap: () -> Void
    var onClose: () -> Void
    var extraView: AnyView? = nil
    var body: some View {
        VStack(spacing: 24) {
//            
            Image(imageName)
                .resizable()
                .scaledToFit()
            VStack(spacing: 16) {
                Text(title)
                    .font(Font.custom("Poppins", size: 18).weight(.semibold))
                    .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                Text(message)
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                    .opacity(0.70)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                if let extraView = extraView {
                    extraView
                }
                Spacer()
                Button(action: onButtonTap) {
                    Text(buttonText)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.hezzniGreen)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 24)
        .background(Color.white)
        .presentationDetents([.medium, .large])
    }
}

enum ErrorType: CaseIterable {
    case wifi
    case updateRequired
    case accountSuspended
    case highCancellation
    case rideCancelled
    case driverVerification
    
    var imageName: String {
        switch self {
        case .wifi: return "offline"
        case .updateRequired: return "update_required"
        case .accountSuspended: return "account_suspended"
        case .highCancellation: return "high_cancellation"
        case .rideCancelled: return "ride_cancelled"
        case .driverVerification: return "verification_popup"
        }
    }
    var title: String {
        switch self {
        case .wifi: return "You’re Offline"
        case .updateRequired: return "Update Required"
        case .accountSuspended: return "Account Suspended"
        case .highCancellation: return "High Cancellation Rate"
        case .rideCancelled: return "Trip Cancelled"
        case .driverVerification: return "Before You Begin"
        }
    }
    var message: String {
        switch self {
        case .wifi:
            return "Looks like your connection dropped. Reconnect to continue using Hezzni."
        case .updateRequired:
            return "A new version of Hezzni is available. Please update to continue."
        case .accountSuspended:
            return "Your account has been temporarily suspended due to a policy violation. Please contact support for more information."
        case .highCancellation:
            return "Frequent ride cancellations may lead to temporary suspension. Please confirm your rides carefully."
        case .rideCancelled:
            return "Your trip was cancelled. You can book a new ride anytime."
        case .driverVerification:
            return "Please make sure your details match your ID to avoid verification delays"
        }
    }
    var buttonText: String {
        switch self {
        case .wifi: return "Try Again"
        case .updateRequired: return "Update Now"
        case .accountSuspended: return "Contact Support"
        case .highCancellation: return "Understood"
        case .rideCancelled: return "Go Back Home"
        case .driverVerification: return "Continue"
        }
    }
}

struct ErrorSheet_Previews: View{
    @State private var showError: Bool = false
    @State private var selectedError: ErrorType? = nil
    var body: some View {
        VStack(spacing: 16) {
            ForEach(ErrorType.allCases, id: \.self) { error in
                Button(error.title) {
                    selectedError = error
                    showError = true
                }
                .font(.headline)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showError, onDismiss: { selectedError = nil }) {
            if let error = selectedError {
                ErrorSheet(
                    imageName: error.imageName,
                    title: error.title,
                    message: error.message,
                    buttonText: error.buttonText,
                    onButtonTap: { showError = false },
                    onClose: { showError = false },
                    extraView: error == .highCancellation ? AnyView(
                        HStack(spacing: 10) {
                            Text("12 Total cancellations")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(Color(red: 1, green: 0.51, blue: 0))
                        }
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                        .background(Color(red: 1, green: 0.51, blue: 0).opacity(0.15))
                        .cornerRadius(6)
                    ) : nil
                )
            }
        }
    }
}

#Preview{
    ErrorSheet_Previews()
}
