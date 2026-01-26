//
//  NewProfileCard.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/3/25.
//

import SwiftUI

struct NewProfileCard: View {
    let person: Person
    
    var body: some View {
        VStack(spacing: 26) {
            // Profile Image with overlapping elements
            ZStack(alignment: .bottomTrailing) {
                // Profile Image
                AsyncImage(url: URL(string: person.imageUrl!)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 90, height: 90)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                
            }
            .frame(height: 90)
            
            // Name and Phone Number
            VStack(spacing: 0) {
                Text(person.name)
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    .lineLimit(1)
                
                Text(person.phoneNumber)
                    .font(Font.custom("Poppins", size: 11).weight(.medium))
                    .foregroundColor(Color(red: 0.45, green: 0.44, blue: 0.44))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .overlay(
            // Rating card positioned to overlap the bottom of the image
            GeometryReader { geometry in
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    
                    Text("\(person.rating, specifier: "%.1f")")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(
                    color: Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 0.05), radius: 4, y: 1
                )
                .position(
                    x: geometry.size.width / 2,
                    y: 120 - 10 // Positioned to overlap the bottom of the 90pt high image
                )
            }
        )
        .overlay(
            GeometryReader{geometry in
                Image("person_verified")
//                    .offset(x: 90, y: 4)
                    .position(
                        x: geometry.size.width / 1.73,
                        y: 105 - 80 // Positioned to overlap the bottom of the 90pt high image
                    )
            }
            
            
        )
    }
}

struct ReviewProfileCard: View {
    let person: Person
    
    var body: some View {
        VStack(spacing: 26) {
            // Profile Image with overlapping elements
            ZStack(alignment: .bottomTrailing) {
                // Profile Image
                AsyncImage(url: URL(string: person.imageUrl!)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 90, height: 90)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 90, height: 90)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                
            }
            .frame(height: 90)
            
            // Name and Trips
            VStack(spacing: 8) {
                HStack{
                    Text(person.name)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        .lineLimit(1)
                    Image("person_verified")
                }
                Text(person.tripCount > 1 ? "(\(person.tripCount) Trips)" : "(\(person.tripCount) Trip)")
                    .font(Font.custom("Poppins", size: 11).weight(.medium))
                    .foregroundColor(Color(red: 0.45, green: 0.44, blue: 0.44))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.white)
        .overlay(
            // Rating card positioned to overlap the bottom of the image
            GeometryReader { geometry in
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    
                    Text("\(person.rating, specifier: "%.1f")")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(15)
                .shadow(
                    color: Color(red: 0.05, green: 0.05, blue: 0.05, opacity: 0.05), radius: 4, y: 1
                )
                .position(
                    x: geometry.size.width / 2,
                    y: 120 - 10 // Positioned to overlap the bottom of the 90pt high image
                )
            }
        )
        
    }
}

#Preview {
    NewProfileCard(
        person: Person(
            id: "C-0003",
            name: "Ahmed Hassan",
            phoneNumber: "+212 666 666 6666",
            rating: 4.8,
            tripCount: 2847,
            imageUrl: "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
        )
    )
    .padding()
}

#Preview {
    ReviewProfileCard(
        person: Person(
            id: "C-0003",
            name: "Ahmed Hassan",
            phoneNumber: "+212 666 666 6666",
            rating: 4.8,
            tripCount: 2847,
            imageUrl: "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
        )
    )
    .padding()
}
