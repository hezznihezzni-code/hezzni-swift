//
//  PaymentMethodScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/11/25.
//

import SwiftUI


// MARK: - PaymentMethodRow
struct PaymentMethodRow: View {
    let iconName: String?
    let title: String
    let subtitle: String
    let badge: String?
    let cardNumber: String?
    let isSelected: Bool
    let isAddCard: Bool
    let showCheckMark: Bool
    let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 11) {
                if let iconName = iconName {
                    ZStack{
                        Image(iconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(Color(hex: "#172B85"))
                            .frame(width: 34, height: 34)
                    }
                    .frame(width: 60, height: 50)
                } else if isAddCard {
                    ZStack {
                        Circle()
                            .stroke(Color(red: 0.84, green: 0.84, blue: 0.84), style: StrokeStyle(lineWidth: 1, dash: [4]))
                            .frame(width: 50, height: 50)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(.systemGray3))
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(.black)
                        if let badge = badge {
                            Text(badge)
                                .font(Font.custom("Poppins", size: 11).weight(.medium))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.10))
                                .cornerRadius(10)
                        }
                    }
                    if let cardNumber = cardNumber {
                        Text(cardNumber)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.70))
                    } else {
                        Text(subtitle)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.70))
                    }
                }
                .frame(width: 207, alignment: .leading)
                Spacer()
                if showCheckMark {
                    if isSelected && !isAddCard {
                        ZStack {
                            Ellipse()
                                .stroke(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.70), lineWidth: 1)
                                .frame(width: 16, height: 16)
                            Ellipse()
                                .frame(width: 7.2, height: 7.2)
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        }
                    } else if !isAddCard {
                        Ellipse()
                            .stroke(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.70), lineWidth: 1)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .frame(height: 90)
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(
                        isAddCard ? Color(red: 0.84, green: 0.84, blue: 0.84) :
                        (isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.89, green: 0.89, blue: 0.89)),
                        style: isAddCard ? StrokeStyle(lineWidth: 1, dash: [4]) : StrokeStyle(lineWidth: 1)
                    )
            )
            .shadow(color: isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33, opacity: 0.10) : Color.white, radius: isSelected ? 4 : 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Card
struct Card: Identifiable {
    let id = UUID()
    let iconName: String?
    let title: String
    let subtitle: String
    let badge: String?
    let cardNumber: String?
    let isAddCard: Bool
    let cardHolder: String? // Added for card detail sheet
    let expiry: String?     // Added for card detail sheet
}

// MARK: - PaymentMethodList
struct PaymentMethodList: View {
    
    let methods: [Card]
    @Binding var selectedIndex: Int
    var showCheckMark: Bool = true
    var onTap: ((Int) -> Void)? = nil // Fix: Accept Int, not [Int]
    var body: some View {
        VStack(spacing: 20) {
            ForEach(Array(methods.enumerated()), id: \.element.id) { idx, method in
                PaymentMethodRow(
                    iconName: method.iconName,
                    title: method.title,
                    subtitle: method.subtitle,
                    badge: method.badge,
                    cardNumber: method.cardNumber,
                    isSelected: selectedIndex == idx && !method.isAddCard,
                    isAddCard: method.isAddCard,
                    showCheckMark: showCheckMark,
                    onTap: {
                        if let onTap = onTap {
                            onTap(idx)
                        } else if !method.isAddCard {
                            selectedIndex = idx
                        }
                    }
                )
            }
        }
    }
}

// MARK: - PaymentMethodScreen
struct RidePaymentScreen: View {
    var rideInfo: CalculateRidePriceResponse.RideOption
    @Binding var selectedService: SelectedService
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    @Binding var selectedMethodIndex: Int
    var methods: [Card]
    var body: some View {
        ZStack{
            VStack{
                ScrollView(showsIndicators: false){
                    VStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 24) {
                            RideOptionCard(
                                icon: rideInfo.icon,
                                title: rideInfo.title,
                                subtitle: rideInfo.subtitle,
                                seats: rideInfo.seats,
                                timeEstimate: rideInfo.timeEstimate,
                                price: rideInfo.price,
                                isSelected: .constant(true)
                            )
                            .matchedGeometryEffect(id: "selected_vehicle", in: namespace!)
                            Text("Payment Methods")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                            PaymentMethodList(methods: methods, selectedIndex: $selectedMethodIndex)
                        }
                        .padding(.horizontal, 16)
                        Spacer()
                        PrimaryButton(text: "Continue", action: {
                            withAnimation{
                                bottomSheetState = .orderSummary
                            }
                        })
                            .padding(.horizontal, 16)
                            .padding(.bottom, 24)
                    }
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 35, trailing: 0))
                    .background(.white)
                }
            }
           
        }
        
    }
}
//
//#Preview {
//    RidePaymentScreen(bottomSheetState: .constant(.payment))
//}
