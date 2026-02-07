//
//  NowRide.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/1/26.
//
import SwiftUI

let rideOptions = [
    VehicleSubOptionsView.RideOption(
        id: 1,
        text_id: "standard",
        icon: "car-service-icon",
        title: "Hezzni Standard",
        subtitle: "Comfortable vehicles",
        seats: 4,
        timeEstimate: "3-8 min",
        price: 25
    ),
    VehicleSubOptionsView.RideOption(
        id: 2,
        text_id: "comfort",
        icon: "car-service-comfort-icon",
        title: "Hezzni Comfort",
        subtitle: "Luxury vehicles",
        seats: 4,
        timeEstimate: "5-10 min",
        price: 45
    ),
    VehicleSubOptionsView.RideOption(
        id: 3,
        text_id: "xl",
        icon: "car-service-xl-icon",
        title: "Hezzni  XL",
        subtitle: "Confortable vehicles",
        seats: 6,
        timeEstimate: "5-10 min",
        price: 45
    )
]
// Car ride options (with Taxi)
let carRideOptions = [
    VehicleSubOptionsView.RideOption(
        id: 1,
        text_id: "standard",
        icon: "car-service-icon",
        title: "Hezzni Standard",
        subtitle: "Comfortable vehicles",
        seats: 4,
        timeEstimate: "3-8 min",
        price: 25
    ),
    VehicleSubOptionsView.RideOption(
        id: 2,
        text_id: "comfort",
        icon: "car-service-comfort-icon",
        title: "Hezzni Comfort",
        subtitle: "Comfortable vehicles",
        seats: 4,
        timeEstimate: "3-8 min",
        price: 35
    ),
    VehicleSubOptionsView.RideOption(
        id: 3,
        text_id: "xl",
        icon: "car-service-xl-icon",
        title: "Hezzni XL",
        subtitle: "Comfortable vehicles",
        seats: 6,
        timeEstimate: "3-8 min",
        price: 50
    ),
    VehicleSubOptionsView.RideOption(
        id: 5,
        text_id: "taxi",
        icon: "taxi-service-icon",
        title: "Taxi",
        subtitle: "Comfortable vehicles",
        seats: 6,
        timeEstimate: "3-8 min",
        price: 100
    )
]

// Bike ride option
let bikeRideOptions = [
    VehicleSubOptionsView.RideOption(
        id: 6,
        text_id: "bike-standard",
        icon: "motorcycle-service-icon",
        title: "Hezzni Standard",
        subtitle: "Comfortable vehicles",
        seats: 1,
        timeEstimate: "3-8 min",
        price: 25
    )
]

// Taxi ride option (if you want a separate array)
let taxiRideOptions = [
    VehicleSubOptionsView.RideOption(
        id: 5,
        text_id: "taxi",
        icon: "taxi-service-icon",
        title: "Taxi",
        subtitle: "Comfortable vehicles",
        seats: 6,
        timeEstimate: "3-8 min",
        price: 100
    )
]
//
//struct NowRideDetailScreen : View {
//    var pickup: String
//    var destination: String
//    @Binding var bottomSheetState: BottomSheetState
//    var rideInformation: [CalculateRidePriceResponse.RideOption]
//    var namespace: Namespace.ID?
//    var selectedService: String = "Car"
//    @State private var selectedOption: String? = "standard"
//    @State var couponField: String = ""
//    @State private var showCouponError: Bool = false
//    @State private var appliedCoupon: AppliedCoupon? = nil
//    
//    
//    
//    //    @Namespace private var animations
//    // Valid coupon
//    private let validCoupon = "ABC123"
//    
//    
//    // Computed properties for coupon logic
//    private var isCouponFieldEmpty: Bool {
//        couponField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
//    
//    private var shouldShowError: Bool {
//        !isCouponFieldEmpty && couponField != validCoupon && showCouponError
//    }
//    
//    private var isApplyButtonEnabled: Bool {
//        !isCouponFieldEmpty && !shouldShowError
//    }
//    
//   
//    // Apply coupon action
//    private func applyCoupon() {
//        if couponField == validCoupon {
//            appliedCoupon = AppliedCoupon(
//                code: couponField,
//                discount: "5% off",
//                validity: "Valid for 7 days"
//            )
//            couponField = ""
//            showCouponError = false
//        } else {
//            showCouponError = true
//        }
//    }
//    
//    // Remove applied coupon
//    private func removeCoupon() {
//        appliedCoupon = nil
//        couponField = ""
//        showCouponError = false
//    }
//    private var options: [VehicleSubOptionsView.RideOption] {
//        let baseOptions: [VehicleSubOptionsView.RideOption]
//        switch selectedService.lowercased() {
//        case "car":
//            baseOptions = carRideOptions
//        case "motorcycle":
//            baseOptions = bikeRideOptions
//        case "taxi":
//            baseOptions = taxiRideOptions
//        default:
//            baseOptions = rideOptions
//        }
//        // Map and update price from rideInformation
//        return baseOptions.map { option in
//            if let info = rideInformation.first(where: { $0.id == option.id }) {
//                return VehicleSubOptionsView.RideOption(
//                    id: option.id,
//                    text_id: option.text_id,
//                    icon: option.icon,
//                    title: option.title,
//                    subtitle: option.subtitle,
//                    seats: option.seats,
//                    timeEstimate: option.timeEstimate,
//                    price: info.price // Use price from rideInformation
//                )
//            } else {
//                return option
//            }
//        }
//    }
//    
//    var body: some View {
//        
//        ZStack {
//            VStack{
//                ScrollView {
//                    ZStack {
//                        VStack(spacing: 16){
//                            Text("Trip Routes")
//                                .font(
//                                    Font.custom("Poppins", size: 16)
//                                        .weight(.medium)
//                                )
//                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
//                                .frame(maxWidth: .infinity, alignment: .topLeading)
//                            LocationCardView(
//                                imageName: "pickup_ellipse",
//                                heading: "Pickup Location",
//                                content: pickup,
//                                roundedEdges: .top
//                            )
//                            .matchedGeometryEffect(id: "pickup", in: namespace!)
//                            HStack(spacing: 10) {
//                                Image("pickup_destination_separator_icon")
//                                    .frame(width: 24, height: 24)
//                            }
//                            .padding(14)
//                            .frame(width: 40, height: 40)
//                            .background(.white)
//                            .cornerRadius(800)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 800)
//                                    .inset(by: 0.40)
//                                    .stroke(Color(red: 0.90, green: 0.92, blue: 0.98), lineWidth: 0.40)
//                            )
//                            LocationCardView(
//                                imageName: "dropoff_ellipse",
//                                heading: "Destination",
//                                content: destination,
//                                roundedEdges: .bottom
//                            )
//                            .matchedGeometryEffect(id: "destination", in: namespace!)
//                            
//                            // MARK: - Vehicle Option
//                            Text("Vehicle Options")
//                                .font(
//                                    Font.custom("Poppins", size: 16)
//                                        .weight(.medium)
//                                )
//                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
//                                .frame(maxWidth: .infinity, alignment: .topLeading)
////                            ServiceSelectorView(services: services, selectedService: $selectedService)
//                            VehicleSubOptionsView(
//                                selectedOption: $selectedOption,
//                                options: options
//                            )
//                                .matchedGeometryEffect(id: "selected_vehicle", in: namespace!)
//                            // MARK: - Coupon section
//                            CouponView(
//                                couponField: $couponField,
//                                showCouponError: $showCouponError,
//                                appliedCoupon: $appliedCoupon,
//                                validCoupon: validCoupon,
//                                isCouponFieldEmpty: isCouponFieldEmpty,
//                                shouldShowError: shouldShowError,
//                                isApplyButtonEnabled: isApplyButtonEnabled,
//                                applyCoupon: applyCoupon,
//                                removeCoupon: removeCoupon
//                            )
//                            // MARK: Trip Summary
//                            VStack(spacing: 48){
//                                TripSummaryView(
//                                    serviceType: selectedService,
//                                    vehicle: options.first(where: { $0.text_id == selectedOption })?.title ?? "-",
//                                    estimatedTime: options.first(where: { $0.text_id == selectedOption })?.timeEstimate ?? "-",
//                                    price: options.first(where: { $0.text_id == selectedOption }).flatMap { String(format: "%.0f", $0.price) } ?? "-"
//                                )
//                                PrimaryButton(text: "Confirm Trip", action: {
//                                    withAnimation{
//                                        bottomSheetState = .payment
//                                    }
//                                })
//                            }
//                            Spacer()
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                }
//            }
//            .navigationBarBackButtonHidden(true)
//            
//        }
//    }
//    
//    // MARK: - Reusable Components
//    
//    
//    
//    
//    
//}
//
//#Preview {
//    NowRideDetailScreen(
//        pickup: "Current",
//        destination: "Morrocco",
//        bottomSheetState: .constant(.nowRide),
//        rideInformation: []
//    )
//}
struct TripSummaryView: View {
    let serviceType: String
    let vehicle: String
    let estimatedTime: String
    let price: String
    var discountedPrice: String? = nil  // Optional discounted price when coupon applied
    var discountText: String? = nil      // Optional discount label (e.g., "10% off")
    
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
            
            // Price section - shows discounted price if coupon applied
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Estimate price")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    if let discountText = discountText {
                        Text(discountText)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    if let discountedPrice = discountedPrice {
                        // Show original price with strikethrough
                        Text(price + " MAD")
                            .font(Font.custom("Poppins", size: 14))
                            .strikethrough()
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.5))
                        // Show discounted price
                        Text(discountedPrice + " MAD")
                            .font(Font.custom("Poppins", size: 18).weight(.semibold))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    } else {
                        Text(price + " MAD")
                            .font(Font.custom("Poppins", size: 18).weight(.semibold))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    }
                }
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
struct VehicleSubOptionsView: View {
    @Binding var selectedOption: String?
    @Binding var rideInfo: RideOption
    let options: [RideOption]
    struct RideOption {
        let id: Int
        let text_id: String
        let icon: String
        let title: String
        let subtitle: String
        let seats: Int
        let timeEstimate: String
        let price: Double
    }
    var body: some View {
        VStack(spacing: 16) {
            ForEach(options, id: \ .text_id) { option in
                RideOptionCard(
                    icon: option.icon,
                    title: option.title,
                    subtitle: option.subtitle,
                    seats: option.seats,
                    timeEstimate: option.timeEstimate,
                    price: option.price,
                    isSelected: Binding(
                        get: {
                            selectedOption == option.text_id
                        },
                        set: {
                            if $0 {
                                selectedOption = option.text_id
                                rideInfo = option
                            } }
                    )
                    
                )
                
            }
        }
    }
}
