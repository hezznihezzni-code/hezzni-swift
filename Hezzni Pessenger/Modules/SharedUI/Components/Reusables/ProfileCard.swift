//
//  ProfileCard.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/26/25.
//

import SwiftUI

struct ProfileCard: View {
    let person: Person
    let cardStyle: CardStyle
    
    init(person: Person, style: CardStyle = .default) {
        self.person = person
        self.cardStyle = style
    }
    
    var body: some View {
        HStack(alignment: .bottom) {
            // Left Section - person Info
            personInfoSection
            
            Spacer()
            
            // Right Section - person ID
            personIdSection
        }
        .padding(cardStyle.padding)
        .background(backgroundView)
    }
    
    // MARK: - Subviews
    
    private var personInfoSection: some View {
        HStack(alignment: .top) {
            ProfileImage(imageUrl: person.imageUrl, size: cardStyle.profileImageSize)
            
            VStack(alignment: .leading, spacing: 5) {
                nameAndPhoneSection
                ratingSection
                verifiedBadge
            }
        }
    }
    
    private var nameAndPhoneSection: some View {
        VStack(alignment: .leading) {
            Text(person.name)
                .font(.poppins(.medium, size: cardStyle.nameFontSize))
            
            Text(person.phoneNumber)
                .font(.poppins(.regular, size: cardStyle.phoneFontSize))
                .foregroundColor(.secondary)
        }
    }
    
    private var ratingSection: some View {
        HStack(spacing: 2) {
            Image(systemName: "star.fill")
                .font(.poppins(.medium, size: cardStyle.ratingFontSize))
                .foregroundColor(.yellow)
            
            Text(person.rating.formatted())
                .font(.poppins(.medium, size: cardStyle.ratingFontSize))
            
            Text("(\(person.tripCount.formatted()) trips)")
                .font(.poppins(.medium, size: cardStyle.ratingFontSize))
                .padding(.horizontal, 5)
        }
        .font(.subheadline)
    }
    
    private var verifiedBadge: some View {
        HStack(alignment: .top, spacing: 8) {
            GradientBadge(
                text: "Verified",
                fontSize: cardStyle.badgeFontSize,
                horizontalPadding: 12,
                verticalPadding: 4
            )
        }
        .padding(0)
    }
    
    private var personIdSection: some View {
        HStack(alignment: .top, spacing: 7.51402) {
            GradientBadge(
                text: person.id,
                fontSize: cardStyle.idBadgeFontSize,
                horizontalPadding: 11.27103,
                verticalPadding: 3.75701
            )
        }
        .padding(0)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: cardStyle.cornerRadius)
            .stroke(Color(hex: "#E3E3E3"))
            .shadow(color: Color(hex: "#04060F").opacity(0.06), radius: 50, x: 0, y: 3.76)
    }
}



struct CardStyle {
    let padding: CGFloat
    let cornerRadius: CGFloat
    let profileImageSize: CGFloat
    let nameFontSize: CGFloat
    let phoneFontSize: CGFloat
    let ratingFontSize: CGFloat
    let badgeFontSize: CGFloat
    let idBadgeFontSize: CGFloat
    
    static let `default` = CardStyle(
        padding: 18.79,
        cornerRadius: 15,
        profileImageSize: 40,
        nameFontSize: 15.03,
        phoneFontSize: 9.39,
        ratingFontSize: 11.27,
        badgeFontSize: 10,
        idBadgeFontSize: 9.39252
    )
    
    static let compact = CardStyle(
        padding: 12,
        cornerRadius: 10,
        profileImageSize: 32,
        nameFontSize: 13,
        phoneFontSize: 8,
        ratingFontSize: 10,
        badgeFontSize: 8,
        idBadgeFontSize: 8
    )
    
    static let large = CardStyle(
        padding: 24,
        cornerRadius: 20,
        profileImageSize: 50,
        nameFontSize: 18,
        phoneFontSize: 12,
        ratingFontSize: 14,
        badgeFontSize: 12,
        idBadgeFontSize: 11
    )
}

// MARK: - Reusable Gradient Badge Component

struct GradientBadge: View {
    let text: String
    let fontSize: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    
    var body: some View {
        HStack(alignment: .center, spacing: 9.39252) {
            Text(text)
                .font(.poppins(.medium, size: fontSize))
                .foregroundColor(.white)
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(gradientBackground)
        .cornerRadius(93.92523)
    }
    
    private var gradientBackground: some View {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color(red: 0.18, green: 0.21, blue: 0.27), location: 0.00),
                Gradient.Stop(color: Color(red: 0.44, green: 0.48, blue: 0.54), location: 1.00),
            ],
            startPoint: UnitPoint(x: -0.02, y: 0.09),
            endPoint: UnitPoint(x: 1.11, y: 0.89)
        )
    }
}

// MARK: - Profile Image Component

struct ProfileImage: View {
    let imageUrl: String?
    let size: CGFloat
    
    var body: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                placeholderImage
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            placeholderImage
        }
    }
    
    private var placeholderImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFill()
            .frame(width: size, height: size)
            .foregroundColor(.gray.opacity(0.3))
    }
}

// MARK: - Usage Examples

struct personProfileCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Default style
            ProfileCard(
                person: Person(
                    id: "C-0003",
                    name: "Ahmed Hassan",
                    phoneNumber: "+212 666 666 6666",
                    rating: 4.8,
                    tripCount: 2847
                )
            )
            
            // Compact style
            ProfileCard(
                person: Person(
                    id: "C-0004",
                    name: "John Doe",
                    phoneNumber: "+212 777 777 7777",
                    rating: 4.9,
                    tripCount: 1500
                ),
                style: .compact
            )
            
            // Large style
            ProfileCard(
                person: Person(
                    id: "C-0005",
                    name: "Jane Smith",
                    phoneNumber: "+212 888 888 8888",
                    rating: 4.7,
                    tripCount: 3200
                ),
                style: .large
            )
        }
        .padding()
    }
}

#Preview{
    ProfileCard(
        person: Person(
            id: "C-0003",
            name: "Ahmed Hassan",
            phoneNumber: "+212 666 666 6666",
            rating: 4.8,
            tripCount: 2847,
            imageUrl: "https://randomuser.me/api/portraits/men/\(Int.random(in: 1...99)).jpg"
        )
    )
}
