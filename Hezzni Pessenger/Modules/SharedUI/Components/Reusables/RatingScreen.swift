//
//  RatingScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/31/25.
//

import SwiftUI

struct RatingScreen: View {
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    var body: some View {
        VStack(spacing: 15) {
            Text("How was your ride?")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .lineSpacing(25.60)
                .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.80))
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    HStack(alignment: .center, spacing: 16) {
                        ForEach(1...5, id: \ .self) { index in
                            Image(systemName: index <= rating ? "star.fill" : "star")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .foregroundColor(Color.gray)
                                .onTapGesture {
                                    rating = index
                                }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
            .shadow(
                color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4
            )
            VStack(alignment: .leading, spacing: 8) {
                Text("Tell us about your ride...")
                    .font(Font.custom("Poppins", size: 14))
                    .lineSpacing(22.40)
                    .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.50))
                TextEditor(text: $reviewText)
                    .font(Font.custom("Poppins", size: 14))
                    .frame(height: 60)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(8)
            }
            .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
            .background(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.50)
                    .stroke(
                        Color(red: 0, green: 0, blue: 0).opacity(0.20), lineWidth: 0.50
                    )
            )
            .shadow(
                color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4
            )
            Button(action: {
                // Handle submit action here
            }) {
                Text("Submit Review")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
            .padding(EdgeInsets(top: 14, leading: 10, bottom: 14, trailing: 10))
            .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.60))
            .cornerRadius(8)
        }
        .padding(EdgeInsets(top: 20, leading: 20, bottom: 35, trailing: 20))
        .background(.white)
        .ignoresSafeArea()
    }
}


struct RatingScreen_Previews: View {
    @State private var showRatingSheet: Bool = true
    var body: some View {
        ZStack{
            
        }
        .sheet(isPresented: $showRatingSheet) {
            if #available(iOS 16.0, *) {
                RatingScreen()
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(35)
            } else {
                RatingScreen()
            }
        }
    }
}


#Preview{
    RatingScreen_Previews()
}
