//
//  Buttons.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/7/25.
//

import SwiftUI

struct PrimaryButton: View {
    var text: String
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var buttonColor: Color?
    var icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                HStack{
                    Text(text)
                        .font(.poppins(.medium, size: 16))
                        .foregroundColor(isEnabled ? .white : Color(hex: "#AAAAAA"))
                    if icon != nil {
                        Image(systemName: icon!)
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(isEnabled ? buttonColor ?? Color.hezzniGreen : Color(hex: "#EEEEEE"))
            .cornerRadius(12)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .shadow(
            color: Color(buttonColor ?? .hezzniGreen).opacity(isEnabled ? 0.40 : 0.0), radius: 15, y: 3
        )
        .disabled(!isEnabled || isLoading)
    }
}

struct NotificationButton: View {
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Image(systemName: "bell")
                .foregroundStyle(.foreground)
                .padding()
                .background(
                    Circle()
                        .fill(.whiteblack)
                        .stroke(.white200, lineWidth: 1)
                )
        }
    }
}
struct NowReservationToggleButton: View {
    @State private var isNowSelected = true
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Now Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isNowSelected = true
                }
            }) {
                HStack(alignment: .center, spacing: 8) {
                    Image("time_icon")
                        .foregroundStyle(isNowSelected ? .white : .gray)
                        .frame(width: 20, height: 20)
                    Text("Now")
                        .font(
                            Font.custom("Poppins", size: 16)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(isNowSelected ? .white : Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isNowSelected ? Color(red: 0.09, green: 0.09, blue: 0.09) : Color.clear)
                .cornerRadius(100)
            }
            
            // Reservation Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isNowSelected = false
                }
            }) {
                HStack(alignment: .center, spacing: 8) {
                    Image("reservation_icon")
                        .foregroundStyle(isNowSelected ? .gray : .white)
                        .frame(width: 20, height: 20)
                    Text("Reservation")
                        .font(
                            Font.custom("Poppins", size: 16)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(isNowSelected ? Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6) : .white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isNowSelected ? Color.clear : Color(red: 0.09, green: 0.09, blue: 0.09))
                .cornerRadius(100)
            }
        }
        .padding(4)
        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
        .cornerRadius(100)
    }
}

#Preview{
    NowReservationToggleButton()
}

#Preview{
    PrimaryButton(text: "Find a Ride", isEnabled: true, isLoading: false, buttonColor: Color.black, icon: "arrow.right"){
        
    }
}

func circularButton(icon: String) -> some View {
    HStack(spacing: 10) { }
        .padding(14)
        .frame(width: 48, height: 48)
        .background(.white)
        .cornerRadius(800)
        .overlay(
            RoundedRectangle(cornerRadius: 800)
                .stroke(Color(red: 0.90, green: 0.90, blue: 0.90), lineWidth: 0.40)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 12, y: 1)
        .overlay(
            Image(icon)
                .foregroundColor(.black)
        )
}

var notificationBadge: some View {
    Text("5")
        .font(Font.custom("Poppins", size: 10).weight(.medium))
        .foregroundColor(.white)
        .frame(width: 18, height: 18)
        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
        .cornerRadius(9)
        .frame(width: 20, height: 20)
        .foregroundColor(.white)
        .offset(x: 15, y: -17)
}
