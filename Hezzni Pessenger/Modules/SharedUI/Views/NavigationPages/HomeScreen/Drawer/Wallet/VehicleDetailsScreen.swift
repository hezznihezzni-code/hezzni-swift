//
//  VehicleDetailsScreen.swift
//  Hezzni Driver
//

import SwiftUI

struct VehicleInfo {
    let vehicleType: String
    let makeModel: String
    let year: String
    let color: String
    let licensePlate: String
    let registrationExpiry: String
    let insuranceExpiry: String
}

struct RideEligibility: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let isEnabled: Bool
}

struct VehicleDetailsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showVehicleChange = false
    var onBack: (() -> Void)? = nil
    
    let vehicleInfo = VehicleInfo(
        vehicleType: "Sedan",
        makeModel: "Dacia Logan",
        year: "2020",
        color: "Silver",
        licensePlate: "12345-A-6",
        registrationExpiry: "12 Mar 2026",
        insuranceExpiry: "10 Mar 2026"
    )
    
    let rideEligibility: [RideEligibility] = [
        RideEligibility(icon: "car-service-icon",title: "Hezzni Standard", subtitle: "Affordable everyday rides", isEnabled: true),
        RideEligibility(icon: "car-service-comfort-icon",title: "Hezzni Comfort", subtitle: "Premium rides with higher fares", isEnabled: true),
        RideEligibility(icon: "car-service-xl-icon",title: "Hezzni XL", subtitle: "For group trips and extra space", isEnabled: false),
        RideEligibility(icon: "delivery-service-icon",title: "Hezzni Delivery", subtitle: "Deliver parcels and packages", isEnabled: false)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                OnboardingAppBar(title: "Vehicle Details", onBack: {
                    onBack?()
                    dismiss()
                })
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("View your registered vehicle information and eligibility.")
                            .font(Font.custom("Poppins", size: 13))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                            .padding(.horizontal, 16)
                        
                        VehicleInfoCard(vehicleInfo: vehicleInfo)
                            .padding(.horizontal, 16)
                        
                        VStack(alignment: .leading, spacing: 17) {
                            HStack {
                                Image("ride_eligibility_icon")
                                    .foregroundColor(.hezzniGreen)
                                Text("Ride Eligibility")
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(.black)
                            }
                            
                            Divider()
                            VStack(spacing: 12){
                                ForEach(rideEligibility) { ride in
                                    RideEligibilityRow(ride: ride)
                                }
                            }
                        }
                        .padding(17)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                        RoundedRectangle(cornerRadius: 12)
                        .inset(by: 0.50)
                        .stroke(
                        Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                        )
                        )
                        .shadow(
                        color: Color(red: 0, green: 0, blue: 0, opacity: 0.08), radius: 10
                        )
                        .padding(.horizontal, 16)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 16)
                }
                PrimaryButton(text: "Request Vehicle Change", action:{
                    showVehicleChange = true
                })
                .padding(.horizontal, 16)
                
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showVehicleChange) {
                VehicleChangeScreen()
            }
        }
    }
}

struct VehicleInfoCard: View {
    let vehicleInfo: VehicleInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image("vehicle_filled_icon")
                    .foregroundColor(.hezzniGreen)
                Text("Registered Vehicle")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.black)
            }
            Divider()
            
            VStack(spacing: 12) {
                InfoRow(label: "Vehicle Type", value: vehicleInfo.vehicleType)
                InfoRow(label: "Make & Model", value: vehicleInfo.makeModel)
                InfoRow(label: "Year", value: vehicleInfo.year)
                InfoRow(label: "Color", value: vehicleInfo.color)
                InfoRow(label: "License Plate", value: vehicleInfo.licensePlate)
                InfoRow(label: "Registration Expiry", value: vehicleInfo.registrationExpiry)
                InfoRow(label: "Insurance Expiry", value: vehicleInfo.insuranceExpiry)
            }
        }
        .padding(17)
        .background(.white)
        .cornerRadius(12)
        .overlay(
        RoundedRectangle(cornerRadius: 12)
        .inset(by: 0.50)
        .stroke(
        Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
        )
        )
        .shadow(
        color: Color(red: 0, green: 0, blue: 0, opacity: 0.08), radius: 10
        )
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            Spacer()
            Text(value)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(.black)
        }
    }
}

struct RideEligibilityRow: View {
    let ride: RideEligibility
    
    var body: some View {
        HStack(spacing: 12) {
            Image(ride.icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(.clear)
                .frame(width: 55, height: 55)
                .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(ride.title)
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.black)
                
                Text(ride.subtitle)
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.92, green: 0.92, blue: 0.92), lineWidth: 1)
        )
        
    }
}

#Preview {
    VehicleDetailsScreen()
}
