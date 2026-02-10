//
//  Service.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/9/26.
//

import SwiftUI

// Service model
struct Service: Identifiable {
    let id: String
    let icon: String
    let title: String
}
// Horizontal service card
struct ServiceCardHorizontal: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                
                Text(title)
                    .font(.poppins(.medium, size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 112, height: 130)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white)
                    .shadow(color: Color(hex: "#04060F").opacity(0.06), radius: 10, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .hezzniGreen : .clear, lineWidth: 2)
            )
        }
    }
}

