//
//  ReservationDetailScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/23/25.
//

import SwiftUI

// Applied coupon model
struct AppliedCoupon {
    let code: String
    let discount: String
    let validity: String
}


struct ReservationDetailScreen : View {
    var pickup: String
    var destination: String
    @Binding var bottomSheetState: BottomSheetState
    var rideInformation: [CalculateRidePriceResponse.RideOption] = []
    var namespace: Namespace.ID?
    @State private var selectedOption: String? = "standard"
    @State var couponField: String = ""
    @State private var showCouponError: Bool = false
    @State private var appliedCoupon: AppliedCoupon? = nil
    @Binding var selectedService: String
    @Binding var showSchedulePicker: Bool
    @Binding var selectedDate: Date  // Changed from @State to @Binding
    
    //    @Namespace private var animations
    // Valid coupon
    private let validCoupon = "ABC123"
    
    
    private let services = [
        Service(id: "car", icon: "car-service-icon", title: "Car"),
        Service(id: "motorcycle", icon: "motorcycle-service-icon", title: "Motorcycle"),
        Service(id: "airport", icon: "airport-service-icon", title: "Ride to Airport"),
        
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
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: selectedDate)
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
        let baseOptions: [VehicleSubOptionsView.RideOption]
        switch selectedService.lowercased() {
        case "car":
            baseOptions = carRideOptions
        case "motorcycle":
            baseOptions = bikeRideOptions
        case "taxi":
            baseOptions = taxiRideOptions
        default:
            baseOptions = rideOptions
        }
        // Map and update price from rideInformation
        return baseOptions.map { option in
            if let info = rideInformation.first(where: { $0.id == option.id }) {
                return VehicleSubOptionsView.RideOption(
                    id: option.id,
                    text_id: option.text_id,
                    icon: option.icon,
                    title: option.title,
                    subtitle: option.subtitle,
                    seats: option.seats,
                    timeEstimate: option.timeEstimate,
                    price: info.price // Use price from rideInformation
                )
            } else {
                return option
            }
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
                                content: pickup,
                                roundedEdges: .top
                            )
                            .matchedGeometryEffect(id: "pickup", in: namespace!)
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
                                content: destination,
                                roundedEdges: .bottom
                            )
                            .matchedGeometryEffect(id: "destination", in: namespace!)
                            ScheduleCardView(
                                dateTime: formattedDate + " at " + formattedTime,
                                trailingIcon: "pencil_icon",
                                onTap: {
                                    withAnimation {
                                        showSchedulePicker = true
                                    }
                                }
                            )
                            // MARK: - Vehicle Option
                            Text("Vehicle Options")
                                .font(
                                    Font.custom("Poppins", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            ServiceSelectorView(
                                services: services,
                                selectedService: $selectedService,
                            )
                            VehicleSubOptionsView(selectedOption: $selectedOption, options: options)
                                .matchedGeometryEffect(id: "selected_vehicle", in: namespace!)
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
                                    vehicle: options.first(where: { $0.text_id == selectedOption })?.title ?? "-",
                                    estimatedTime: options.first(where: { $0.text_id == selectedOption })?.timeEstimate ?? "-",
                                    price: options.first(where: { $0.text_id == selectedOption }).flatMap { String(format: "%.0f", $0.price) } ?? "-"
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
    
    struct ServiceSelectorView: View {
        let services: [Service]
        @Binding var selectedService: String
        var body: some View {
            HorizontalServicesScrollView(items: services) { service in
                ServiceCardBuilder.createCard(
                    icon: service.icon,
                    title: service.title,
                    isSelected: selectedService == service.title,
                    action: {
                        selectedService = service.title
                    }
                )
            }
        }
    }
    
}

#Preview {
    ReservationDetailScreen(
        pickup: "pickupLocation",
        destination: "destinationLocation",
        bottomSheetState: .constant(.reservation),
        selectedService: .constant("Car"),
        showSchedulePicker: .constant(false),
        selectedDate: .constant(Date())
    )
}

// MARK: - BottomSheetContent for dynamic height
struct BottomSheetContent: View {
    @Binding var showSchedulePicker: Bool
    @Binding var selectedDate: Date
    @State private var contentHeight: CGFloat = 0
    var body: some View {
        VStack(spacing: 0) {
            SchedulePickerScreen(showSchedulePicker: $showSchedulePicker, selectedDate: $selectedDate)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                contentHeight = proxy.size.height
                            }
                            .onChange(of: proxy.size.height) { newHeight in
                                contentHeight = newHeight
                            }
                    }
                )
        }
        .frame(maxWidth: .infinity)
        .frame(height: contentHeight > 0 ? contentHeight + 48 : nil) // 48 for close button spacing
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
