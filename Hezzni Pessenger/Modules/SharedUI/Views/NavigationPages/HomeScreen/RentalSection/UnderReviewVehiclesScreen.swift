//
//  UnderReviewVehiclesScreen.swift
//  Hezzni

import SwiftUI

struct UnderReviewVehiclesScreen: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Text("Vehicles Under Review")
                    .font(Font.custom("Poppins", size: 16).weight(.semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(16)
            
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.black.opacity(0.5))
                    TextField("Search your listed vehicles...", text: .constant(""))
                        .font(Font.custom("Poppins", size: 14))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                .cornerRadius(10)
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14))
                        Text("Filters")
                            .font(Font.custom("Poppins", size: 12).weight(.medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.black)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
            ScrollView {
                VStack(spacing: 12) {
                    Text("34 vehicles under review")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color.black.opacity(0.6))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                    
                    ForEach(0..<3, id: \.self) { _ in
                        underReviewCard
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background(Color.white)
    }
    
    private var underReviewCard: some View {
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
                    
                    Text("MAD 380/day")
                        .font(Font.custom("Poppins", size: 14).weight(.semibold))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                }
                
                Spacer()
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
    UnderReviewVehiclesScreen()
}
