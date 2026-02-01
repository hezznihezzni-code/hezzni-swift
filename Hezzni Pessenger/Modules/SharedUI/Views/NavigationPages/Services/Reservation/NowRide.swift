//
//  NowRide.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/1/26.
//
import SwiftUI

let rideOptions = [
    VehicleSubOptionsView.RideOption(
        id: "standard",
        icon: "car-service-icon",
        title: "Hezzni Standard",
        subtitle: "Comfortable vehicles",
        seats: 4,
        timeEstimate: "3-8 min",
        price: "25 MAD"
    ),
    VehicleSubOptionsView.RideOption(
        id: "comfort",
        icon: "car-service-comfort-icon",
        title: "Hezzni Comfort",
        subtitle: "Luxury vehicles",
        seats: 4,
        timeEstimate: "5-10 min",
        price: "45 MAD"
    ),
    VehicleSubOptionsView.RideOption(
        id: "xl",
        icon: "car-service-xl-icon",
        title: "Hezzni  XL",
        subtitle: "Confortable vehicles",
        seats: 6,
        timeEstimate: "5-10 min",
        price: "45 MAD"
    )
]
// Car ride options (with Taxi)
let carRideOptions = [
    VehicleSubOptionsView.RideOption(
        id: "standard",
        icon: "car-service-icon",
        title: "Hezzni Standard",
        subtitle: "Comfortable vehicles",
        seats: 4,
        timeEstimate: "3-8 min",
        price: "25 MAD"
    ),
    VehicleSubOptionsView.RideOption(
        id: "comfort",
        icon: "car-service-comfort-icon",
        title: "Hezzni Comfort",
        subtitle: "Comfortable vehicles",
        seats: 4,
        timeEstimate: "3-8 min",
        price: "35 MAD"
    ),
    VehicleSubOptionsView.RideOption(
        id: "xl",
        icon: "car-service-xl-icon",
        title: "Hezzni XL",
        subtitle: "Comfortable vehicles",
        seats: 6,
        timeEstimate: "3-8 min",
        price: "50 MAD"
    ),
    VehicleSubOptionsView.RideOption(
        id: "taxi",
        icon: "taxi-service-icon",
        title: "Taxi",
        subtitle: "Comfortable vehicles",
        seats: 6,
        timeEstimate: "3-8 min",
        price: "100 MAD"
    )
]

// Bike ride option
let bikeRideOptions = [
    VehicleSubOptionsView.RideOption(
        id: "bike-standard",
        icon: "motorcycle-service-icon",
        title: "Hezzni Standard",
        subtitle: "Comfortable vehicles",
        seats: 1,
        timeEstimate: "3-8 min",
        price: "25 MAD"
    )
]

// Taxi ride option (if you want a separate array)
let taxiRideOptions = [
    VehicleSubOptionsView.RideOption(
        id: "taxi",
        icon: "taxi-service-icon",
        title: "Taxi",
        subtitle: "Comfortable vehicles",
        seats: 6,
        timeEstimate: "3-8 min",
        price: "100 MAD"
    )
]

struct NowRideDetailScreen : View {
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    var selectedService: String = "Car"
    @State private var selectedOption: String? = "standard"
    @State var couponField: String = ""
    @State private var showCouponError: Bool = false
    @State private var appliedCoupon: AppliedCoupon? = nil
    
    
    
    //    @Namespace private var animations
    // Valid coupon
    private let validCoupon = "ABC123"
    
    
    private let services = [
        Service(id: "car", icon: "car-service-icon", title: "Car"),
        Service(id: "motorcycle", icon: "motorcycle-service-icon", title: "Motorcycle"),
        Service(id: "airport", icon: "airport-service-icon", title: "Ride to Airport"),
        Service(id: "rental", icon: "rental-service-icon", title: "Rental Car"),
        Service(id: "reservation", icon: "reservation-service-icon", title: "Reservation"),
        Service(id: "city", icon: "city-service-icon", title: "City to City"),
        Service(id: "taxi", icon: "taxi-service-icon", title: "Taxi"),
        Service(id: "delivery", icon: "delivery-service-icon", title: "Delivery"),
        Service(id: "group", icon: "shared-service-icon", title: "Group Ride")
    ]
    
    
    // Computed properties for coupon logic
    private var isCouponFieldEmpty: Bool {
        couponField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var shouldShowError: Bool {
        !isCouponFieldEmpty && couponField != validCoupon && showCouponError
    }
    
    private var isApplyButtonEnabled: Bool {
        !isCouponFieldEmpty && !shouldShowError
    }
    
   
    // Apply coupon action
    private func applyCoupon() {
        if couponField == validCoupon {
            appliedCoupon = AppliedCoupon(
                code: couponField,
                discount: "5% off",
                validity: "Valid for 7 days"
            )
            couponField = ""
            showCouponError = false
        } else {
            showCouponError = true
        }
    }
    
    // Remove applied coupon
    private func removeCoupon() {
        appliedCoupon = nil
        couponField = ""
        showCouponError = false
    }
    private var options: [VehicleSubOptionsView.RideOption] {
        switch selectedService.lowercased() {
        case "car":
            return carRideOptions
        case "motorcycle":
            return bikeRideOptions
        case "taxi":
            return taxiRideOptions
        default:
            return rideOptions
        }
    }
    
    var body: some View {
        
        ZStack {
            VStack{
                ScrollView {
                    ZStack {
                        VStack(spacing: 16){
                            Text("Trip Routes")
                                .font(
                                    Font.custom("Poppins", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            LocationCardView(
                                imageName: "pickup_ellipse",
                                heading: "Pickup Location",
                                content: "Current Location, Marrakech",
                                roundedEdges: .top
                            )
//                            .matchedGeometryEffect(id: "pickup", in: namespace!)
                            HStack(spacing: 10) {
                                Image("pickup_destination_separator_icon")
                                    .frame(width: 24, height: 24)
                            }
                            .padding(14)
                            .frame(width: 40, height: 40)
                            .background(.white)
                            .cornerRadius(800)
                            .overlay(
                                RoundedRectangle(cornerRadius: 800)
                                    .inset(by: 0.40)
                                    .stroke(Color(red: 0.90, green: 0.92, blue: 0.98), lineWidth: 0.40)
                            )
                            LocationCardView(
                                imageName: "dropoff_ellipse",
                                heading: "Destination",
                                content: "Menara Mall, Gueliz District",
                                roundedEdges: .bottom
                            )
//                            .matchedGeometryEffect(id: "destination", in: namespace!)
                            
                            // MARK: - Vehicle Option
                            Text("Vehicle Options")
                                .font(
                                    Font.custom("Poppins", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
//                            ServiceSelectorView(services: services, selectedService: $selectedService)
                            VehicleSubOptionsView(
                                selectedOption: $selectedOption,
                                options: options
                            )
//                                .matchedGeometryEffect(id: "selected_vehicle", in: namespace!)
                            // MARK: - Coupon section
                            CouponView(
                                couponField: $couponField,
                                showCouponError: $showCouponError,
                                appliedCoupon: $appliedCoupon,
                                validCoupon: validCoupon,
                                isCouponFieldEmpty: isCouponFieldEmpty,
                                shouldShowError: shouldShowError,
                                isApplyButtonEnabled: isApplyButtonEnabled,
                                applyCoupon: applyCoupon,
                                removeCoupon: removeCoupon
                            )
                            // MARK: Trip Summary
                            VStack(spacing: 48){
                                TripSummaryView(
                                    serviceType: selectedService,
                                    vehicle: options.first(where: { $0.id == selectedOption })?.title ?? "-",
                                    estimatedTime: options.first(where: { $0.id == selectedOption })?.timeEstimate ?? "-",
                                    price: options.first(where: { $0.id == selectedOption })?.price ?? "-"
                                )
                                PrimaryButton(text: "Confirm Trip", action: {
                                    withAnimation{
                                        bottomSheetState = .payment
                                    }
                                })
                            }
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationBarBackButtonHidden(true)
            
        }
    }
    
    // MARK: - Reusable Components
    
    struct TripSummaryView: View {
        let serviceType: String
        let vehicle: String
        let estimatedTime: String
        let price: String
        var body: some View {
            VStack(alignment: .leading, spacing: 24) {
                Text("Trip Summary")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Service Type")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                        Spacer()
                        Text(serviceType)
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    }
                    HStack {
                        Text("Vehicle")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                        Spacer()
                        Text(vehicle)
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    }
                    HStack {
                        Text("Estimated tme")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                        Spacer()
                        Text(estimatedTime)
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    }
                }
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 322, height: 1)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                HStack(alignment: .top) {
                    Text("Estimate price")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    Spacer()
                    Text(price)
                        .font(Font.custom("Poppins", size: 18).weight(.semibold))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                }
            }
            .padding(14)
            .background(.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 5, x: 0, y: 0)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    
    
}

#Preview {
    NowRideDetailScreen(
        bottomSheetState: .constant(.nowRide) // Provide a default BottomSheetState value
    )
}

struct VehicleSubOptionsView: View {
    @Binding var selectedOption: String?
    let options: [RideOption]
    struct RideOption {
        let id: String
        let icon: String
        let title: String
        let subtitle: String
        let seats: Int
        let timeEstimate: String
        let price: String
    }
    var body: some View {
        VStack(spacing: 16) {
            ForEach(options, id: \ .id) { option in
                RideOptionCard(
                    icon: option.icon,
                    title: option.title,
                    subtitle: option.subtitle,
                    seats: option.seats,
                    timeEstimate: option.timeEstimate,
                    price: option.price,
                    isSelected: Binding(
                        get: { selectedOption == option.id },
                        set: { if $0 { selectedOption = option.id } }
                    )
                    
                )
                
            }
        }
    }
}
