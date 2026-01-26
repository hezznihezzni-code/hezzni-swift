//
//  RideCancelScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 11/5/25.
//
//
import SwiftUI

struct CancelReason: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let isOther: Bool
}

struct RideCancelScreen: View {
    var onBack: (() -> Void)? = nil
    @State private var selectedReasons: Set<CancelReason> = []
    @State private var otherReasonText: String = ""
    
    private let reasons: [CancelReason] = [
        CancelReason(title: "Driver is taking too long", subtitle: "Driver hasn’t arrived within estimated time", isOther: false),
        CancelReason(title: "Driver is going in wrong direction", subtitle: "Driver appears to be moving away from pickup", isOther: false),
        CancelReason(title: "Emergency situation", subtitle: "Unexpected emergency has occurred", isOther: false),
        CancelReason(title: "Driver behavior concerns", subtitle: "Unprofessional or concerning driver behavior", isOther: false),
        CancelReason(title: "Vehicle doesn’t match", subtitle: "Different car or condition issues", isOther: false),
        CancelReason(title: "Found alternative transport", subtitle: "Unexpected emergency has occurred", isOther: false),
        CancelReason(title: "Other Reasons", subtitle: "Please Specify your reason below", isOther: true)
    ]
    
    var body: some View {
        VStack{
            CustomAppBar(title: "Cancel Ride", backButtonAction: {
                onBack?()
            })
                .padding(.horizontal, 16)
            ScrollView{
                VStack{
                    //Person Information
                    HStack{
                        //Person Card
                        Image("profile_placeholder")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                HStack(spacing: 0){
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.yellow)
                                    Text(String(format: "%.1f", 4.8))
                                        .font(Font.custom("Poppins", size: 10).weight(.medium))
                                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, y: 1)
                                .offset(y: 9),
                                alignment: .bottom
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            HStack{
                                Text("Ahmed Hassan")
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                //                            if let badgeImage = "verified_badge" {
                                Image("verified_badge")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                                //                            }
                            }
                            Text("(\("(2875)") trips)")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(Color(red: 0.45, green: 0.44, blue: 0.44))
                        }
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .background(.white)
                    .cornerRadius(16)
                    .overlay(
                    RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.50)
                    .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
                    )
                    .shadow(
                    color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4
                    )
                    .padding(.horizontal, 16)
                    //Ride Information
                    VStack(spacing: 12){
                        // Car info card
                        ReservationScheduleCard(
                            carInfo: "8 | أ | 26363",
                            carModel: "Toyota HR-V",
                            carColor: "White",
                            carType: "STANDARD",
                            carImage: "personal_car1"
                        )
                        // Pickup/Destination
                        PickupDestinationPathView(
                            pickupLocation: "Current Location, Marrakech",
                            destinationLocation: "Current Location, Marrakech"
                        )
                        HStack(spacing: 5) {
                            Spacer()
                            Image(systemName: "clock")
                                .font(.poppins(.regular, size: 10))
                            Text("Estimated time: 8 min")
                                .font(Font.custom("Poppins", size: 10))
                                .foregroundColor(Color(red: 0.50, green: 0.50, blue: 0.50))
                        }
                    }
                    .padding(14)
                    .background(.white)
                    .cornerRadius(16)
                    .overlay(
                    RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.50)
                    .stroke(
                    Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.10), lineWidth: 0.50
                    )
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    
                    //Details of cancel ride
                    VStack{
                        HStack{
                            Text("Why are you cancelling?")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .lineSpacing(25.60)
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                            Spacer()
                        }
                        HStack{
                            Text("Your reason helps us improve service. ")
                                .font(Font.custom("Poppins", size: 12))
                                .lineSpacing(20)
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                    // Reason cards
                    VStack(spacing: 12) {
                        ForEach(reasons) { reason in
                            Button(action: {
                                if selectedReasons.contains(reason) {
                                    selectedReasons.remove(reason)
                                } else {
                                    selectedReasons.insert(reason)
                                }
                            }) {
                                HStack(alignment: .center, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(reason.title)
                                            .font(Font.custom("Poppins", size: 15).weight(.medium))
                                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                        if let subtitle = reason.subtitle {
                                            Text(subtitle)
                                                .font(Font.custom("Poppins", size: 12))
                                                .foregroundColor(Color(red: 0.45, green: 0.44, blue: 0.44))
                                        }
                                    }
                                    Spacer()
                                    if selectedReasons.contains(reason) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color.green)
                                    }
                                }
                                .padding(14)
                                .background(selectedReasons.contains(reason) ? Color.white : Color.white)
                                
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedReasons.contains(reason) ? Color.green : Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                            .shadow(
                                color:selectedReasons.contains(reason) ? Color(red: 0.22, green: 0.65, blue: 0.33, opacity: 0.60) : .clear, radius: 4
                            )
                        }
                        
                        // Show text field if Other Reasons is selected
                        if let other = reasons.last, selectedReasons.contains(other) {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Give your reason", text: $otherReasonText)
                                    .font(Font.custom("Poppins", size: 14))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(4)
                                    .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
                                    .frame(width: 363, height: 100)
                                    .background(.white)
                                    .cornerRadius(10)
                                    .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                    .inset(by: 0.50)
                                    .stroke(otherReasonText.isEmpty ? Color(red: 0.89, green: 0.89, blue: 0.89) : Color(red: 0.27, green: 0.27, blue: 0.27), lineWidth: 0.50)
                                    )
                                    .shadow(
                                    color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4
                                    )
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 16)
                    // Continue to Cancel button
                    Spacer(minLength: 24)
                    Button(action: {
                        // Handle cancel action
                    }) {
                        Text("Continue to Cancel")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.hezzniGreen)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

#Preview {
    RideCancelScreen()
}
