//
//  RideCancelScreen.swift
//  Hezzni
//
//  Shared cancellation screen for both driver and passenger
//

import SwiftUI

struct CancelReason: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let isOther: Bool
}


struct RideCancelScreen: View {
    let isDriver: Bool
    var onCancel: (String) -> Void = { _ in }
    var onDismiss: () -> Void = {}
    
    @State private var selectedReason: String? = nil
    @State private var otherReasonText: String = ""
    
    private var driverReasons: [String] {
        [
            "Passenger not at pickup",
            "Safety concern",
            "Vehicle issue",
            "Emergency",
            "Wrong address",
            "Other"
        ]
    }
    
    private var passengerReasons: [String] {
        [
            "Changed plans",
            "Driver too far",
            "Wrong pickup location",
            "Found another ride",
            "Emergency",
            "Other"
        ]
    }
    
    private var reasons: [String] {
        isDriver ? driverReasons : passengerReasons
    }
    
    private var cancelReason: String {
        if selectedReason == "Other" {
            return otherReasonText.isEmpty ? "Other" : otherReasonText
        }
        return selectedReason ?? ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Cancel Ride")
                    .font(Font.custom("Poppins", size: 20).weight(.semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.05))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // Subtitle
            Text("Please select a reason for cancellation")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color.black.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            
            // Reason list
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(reasons, id: \.self) { reason in
                        reasonRow(reason)
                    }
                    
                    // Other reason text field
                    if selectedReason == "Other" {
                        TextEditor(text: $otherReasonText)
                            .font(Font.custom("Poppins", size: 14))
                            .frame(height: 80)
                            .padding(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if otherReasonText.isEmpty {
                                        Text("Please describe your reason...")
                                            .font(Font.custom("Poppins", size: 14))
                                            .foregroundColor(Color.black.opacity(0.3))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 20)
                                            .allowsHitTesting(false)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Cancel button
            VStack(spacing: 12) {
                Button(action: {
                    onCancel(cancelReason)
                }) {
                    Text("Cancel Ride")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            selectedReason != nil
                                ? Color(red: 0.83, green: 0.18, blue: 0.18)
                                : Color(red: 0.83, green: 0.18, blue: 0.18).opacity(0.4)
                        )
                        .cornerRadius(12)
                }
                .disabled(selectedReason == nil)
                
                Button(action: onDismiss) {
                    Text("Go Back")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color.white)
    }
    
    private func reasonRow(_ reason: String) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedReason = reason
            }
        }) {
            HStack(spacing: 14) {
                // Radio button
                ZStack {
                    Circle()
                        .stroke(
                            selectedReason == reason
                                ? Color(red: 0.83, green: 0.18, blue: 0.18)
                                : Color.black.opacity(0.2),
                            lineWidth: 1.5
                        )
                        .frame(width: 22, height: 22)
                    
                    if selectedReason == reason {
                        Circle()
                            .fill(Color(red: 0.83, green: 0.18, blue: 0.18))
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(reason)
                    .font(Font.custom("Poppins", size: 15))
                    .foregroundColor(.black.opacity(0.85))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(selectedReason == reason ? Color(red: 0.83, green: 0.18, blue: 0.18).opacity(0.05) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selectedReason == reason
                            ? Color(red: 0.83, green: 0.18, blue: 0.18).opacity(0.3)
                            : Color.black.opacity(0.08),
                        lineWidth: 1
                    )
            )
        }
    }
}

#Preview {
    RideCancelScreen(isDriver: true)
}
