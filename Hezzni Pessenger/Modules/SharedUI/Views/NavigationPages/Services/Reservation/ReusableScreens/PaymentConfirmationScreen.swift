//
//  PaymentConfirmationScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/18/25.
//

import SwiftUI

struct PaymentConfirmationScreen: View {
    var rideInfo: CalculateRidePriceResponse.RideOption
    var pickupLocation: String
    var destinationLocation: String
    var isReservation: Bool
    @Binding var bottomSheetState: BottomSheetState
    var paymentMethod: Card
    
    var namespace: Namespace.ID?
    var onContinue: () -> Void = {}
    
    // MARK: - Subviews
    
    private var tripDetailsHeader: some View {
        HStack(alignment: .top, spacing: 10) {
            HStack(spacing: 10) {
                Image("location_pin_filled")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .cornerRadius(7)
                
                Text("Trip Details")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.black)
                Spacer()
            }
            HStack(spacing: 4) {
                Text(rideInfo.ridePreference)
                    .font(Font.custom("Poppins", size: 11).weight(.medium))
                    .foregroundColor(.white)
            }
            .padding(EdgeInsets(top: 2.5, leading: 6, bottom: 2.5, trailing: 6))
            .background(Color.black)
            .cornerRadius(7)
        }
        .padding(.leading, 3)
    }
    
    private var reservationDateView: some View {
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
    
    private var tripDetailsCard: some View {
        VStack(spacing: 15) {
            tripDetailsHeader
            
            VStack(alignment: .leading, spacing: 10) {
                PickupDestinationPathView(pickupLocation: pickupLocation, destinationLocation: destinationLocation)
                if isReservation {
                    reservationDateView
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Estimated time: \(rideInfo.timeEstimate)")
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
    }
    
    private var costBreakdownHeader: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("cost_breakdown_fill")
                .resizable()
                .frame(width: 28, height: 28)
                .cornerRadius(7)
            Text("Cost Breakdown")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
            Spacer()
        }
    }
    
    private var costBreakdownRows: some View {
        VStack(alignment: .leading, spacing: 8) {
            costRow(label: "Trip", value: "\(String(format: "%.2f", rideInfo.price)) MAD")
            costRow(label: "TVA", value: "1%")
            costRow(label: "Service fee", value: "0.00 MAD")
            costRow(label: "Discount", value: "0%")
        }
    }
    
    private func costRow(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label)
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
            Spacer()
            Text(value)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
        }
    }
    
    private var totalRow: some View {
        HStack(spacing: 4) {
            Text("Total")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
            Spacer()
            Text("\(String(format: "%.2f", rideInfo.price)) MAD")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
        }
    }
    
    private var costBreakdownCard: some View {
        VStack(spacing: 12) {
            costBreakdownHeader
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
            costBreakdownRows
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
            totalRow
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.10), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10)
    }
    
    private var paymentMethodCard: some View {
        PaymentMethodRow(
            iconName: paymentMethod.iconName,
            title: paymentMethod.title,
            subtitle: paymentMethod.subtitle,
            badge: paymentMethod.badge,
            cardNumber: paymentMethod.cardNumber,
            isSelected: true,
            isAddCard: false,
            showCheckMark: false,
            onTap: {}
        )
        .padding(.bottom, 20)
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 20) {
                Spacer().frame(height: 15)
                tripDetailsCard
                costBreakdownCard
                paymentMethodCard
                PrimaryButton(text: "Continue", action: onContinue)
                    .padding(.bottom, 36)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(.white))
    }
}

//struct PaymentConfirmationScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        PaymentConfirmationScreen(
//            bottomSheetState: .constant(.orderSummary),
//            onContinue: {}
//        )
//    }
//}
