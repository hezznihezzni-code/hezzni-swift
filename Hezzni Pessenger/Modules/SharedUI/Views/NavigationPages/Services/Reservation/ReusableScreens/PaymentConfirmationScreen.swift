//
//  PaymentConfirmationScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/18/25.
//

import SwiftUI

struct PaymentConfirmationScreen: View {
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    var onContinue : () -> Void = {}
    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 20) {
                Spacer().frame(height: 15)
                // Trip Details Card
                VStack(spacing: 15) {
                    
                    HStack(alignment: .top, spacing: 10) {
                        HStack(spacing: 10) {
                            ZStack {
                                Image("location_pin_filled")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                                    .cornerRadius(7)
                                
                            }
                            
                            Text("Trip Details")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        HStack(spacing: 4) {
                            Text("CAR RIDE")
                                .font(Font.custom("Poppins", size: 11).weight(.medium))
                                .foregroundColor(.white)
                        }
                        .padding(EdgeInsets(top: 2.5, leading: 6, bottom: 2.5, trailing: 6))
                        .background(Color.black)
                        .cornerRadius(7)
                    }
                    .padding(.leading, 3)
                    // Trip Details
                    VStack(alignment: .leading, spacing: 10) {
//                        VStack(spacing: 0){
//                                LocationCardView(
//                                    imageName: "pickup_ellipse",
//                                    
//                                    content: "Current Location, Marrakech",
//                                    cornerRadius: 10,
//                                    roundedEdges: .top,
//                                    borderColor: Color(red: 0.89, green: 0.89, blue: 0.89),
//                                    expandToFill: true
//                                )
//                            LocationCardView(
//                                imageName: "dropoff_ellipse",
//                                content: "Menara Mall, Gueliz District",
//                                cornerRadius: 10,
//                                roundedEdges: .bottom,
//                                borderColor: Color(red: 0.89, green: 0.89, blue: 0.89),
//                                expandToFill: true
//                            )
//                            
//                        }
//                        .overlay(
//                            Line()
//                            .stroke(
//                                Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.25),
//                                style: StrokeStyle(
//                                    lineWidth: 2,
//                                    dash: [5,5]
//                                )
//                            )
//                            
//                            .frame(height: 50)
//                            .offset(x: 22)
//                            ,alignment: .leading
//                        )
                        PickupDestinationPathView(pickupLocation: "Current Location, Marrakech", destinationLocation: "Menara Mall, Gueliz District")
                        // Date/Time
                        HStack(spacing: 12) {
                            Image("reservation_icon")
                                .foregroundStyle(.hezzniGreen)
                            HStack(spacing: 50) {
                                Text("16 July, 2025 at 9:00 am")
                                    .font(Font.custom("Poppins", size: 12))
                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                    .padding(.vertical, 4)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                        }
                        .padding(.horizontal, 13)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.5)
                        )
                    }
                    // Estimated Time
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Estimated time: 15-20 min")
                            .font(Font.custom("Poppins", size: 10))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                }
                .padding(EdgeInsets(top: 15, leading: 14, bottom: 14, trailing: 14))
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.10), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10)
                // Cost Breakdown Card
                VStack(spacing: 12) {
                    HStack(alignment: .center, spacing: 10) {
                        ZStack {
                            Image("cost_breakdown_fill")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .cornerRadius(7)
                        }
                        Text("Cost Breakdown")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        Spacer()
                    }
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 4) {
                            Text("Trip")
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                            Spacer()
                            Text("25.00 MAD")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        }
                        HStack(spacing: 4) {
                            Text("TVA")
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                            Spacer()
                            Text("1%")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        }
                        HStack(spacing: 4) {
                            Text("Service fee")
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                            Spacer()
                            Text("0.00 MAD")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        }
                        HStack(spacing: 4) {
                            Text("Discount")
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                            Spacer()
                            Text("0%")
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        }
                    }
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                    HStack(spacing: 4) {
                        Text("Total")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                        Spacer()
                        Text("0.00 MAD")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    }
                }
                .padding(14)
                .background(Color.white)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.10), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10)
                // Payment Method Card
                PaymentMethodRow(
                    iconName: "cash_on_deliver_icon",
                    title: "Cash Payment",
                    subtitle: "pay the driver directly",
                    badge: nil,
                    cardNumber: nil,
                    isSelected: true,
                    isAddCard: false,
                    showCheckMark: false,
                    onTap: {}
                )
                .padding(.bottom, 20)
                
                PrimaryButton(text: "Continue", action: onContinue)
                    .padding(.bottom, 36)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.white))
    }
}
//
//struct PaymentConfirmationScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        PaymentConfirmationScreen(
//            bottomSheetState: .constant(.orderSummary),
//            onContinue: {}
//        )
//    }
//}
