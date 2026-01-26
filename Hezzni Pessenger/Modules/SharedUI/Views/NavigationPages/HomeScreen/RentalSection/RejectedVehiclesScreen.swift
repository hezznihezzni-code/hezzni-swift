//
//  RejectedVehiclesScreen.swift
//  Hezzni

import SwiftUI

struct RejectedVehiclesScreen: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Text("Rejected Vehicles")
                    .font(Font.custom("Poppins", size: 16).weight(.semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(16)
            
            ScrollView {
                VStack(spacing: 12) {
                    Text("4 vehicles rejected")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color.black.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    ForEach(0..<4, id: \.self) { index in
                        rejectedCard(index: index)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color.white)
    }
    
    private func rejectedCard(index: Int) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image("car_placeholder")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 60)
                    .cornerRadius(8)
                    .clipped()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dacia Logan")
                        .font(Font.custom("Poppins", size: 16).weight(.semibold))
                        .foregroundColor(.black)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 12))
                            Text("Photos are blurry")
                                .font(Font.custom("Poppins", size: 11))
                        }
                        .foregroundColor(Color(red: 0.83, green: 0.18, blue: 0.18))
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("MAD 380/day")
                        .font(Font.custom("Poppins", size: 14).weight(.semibold))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    
                    Button(action: {}) {
                        Text("Resubmit")
                            .font(Font.custom("Poppins", size: 10).weight(.medium))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
    }
}

#Preview {
    RejectedVehiclesScreen()
}
