//
//  ReservationDetailScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/23/25.
//

import SwiftUI

struct ReservationDetailScreen : View {
    @Binding var bottomSheetState: BottomSheetState
    var namespace: Namespace.ID?
    @State private var selectedService: String = "Car"
    @State private var selectedOption: String? = "standard"
    @State var couponField: String = ""
    @State private var showCouponError: Bool = false
    @State private var appliedCoupon: AppliedCoupon? = nil
    @Binding var showSchedulePicker: Bool
    @Binding var selectedDate: Date  // Changed from @State to @Binding
    
    //    @Namespace private var animations
    // Valid coupon
    private let validCoupon = "ABC123"
    
    // Applied coupon model
    struct AppliedCoupon {
        let code: String
        let discount: String
        let validity: String
    }
    
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
    
    private let rideOptions = [
        VehicleOptionsView.RideOption(id: "standard", icon: "car-service-icon", title: "Hezzni Standard", subtitle: "Comfortable vehicles", timeEstimate: "3-8 min", price: "25 MAD"),
        VehicleOptionsView.RideOption(id: "comfort", icon: "car-service-comfort-icon", title: "Hezzni Comfort", subtitle: "Luxury vehicles", timeEstimate: "5-10 min", price: "45 MAD"),
        VehicleOptionsView.RideOption(id: "xl", icon: "car-service-xl-icon", title: "Hezzni  XL", subtitle: "Confortable vehicles", timeEstimate: "5-10 min", price: "45 MAD")
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
                            ).matchedGeometryEffect(id: "pickup", in: namespace!)
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
                            ).matchedGeometryEffect(id: "destination", in: namespace!)
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
                            ServiceSelectorView(services: services, selectedService: $selectedService)
                            VehicleOptionsView(selectedOption: $selectedOption, options: rideOptions)
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
                                    vehicle: rideOptions.first(where: { $0.id == selectedOption })?.title ?? "-",
                                    estimatedTime: rideOptions.first(where: { $0.id == selectedOption })?.timeEstimate ?? "-",
                                    price: rideOptions.first(where: { $0.id == selectedOption })?.price ?? "-"
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
    
    struct CouponView: View {
        @Binding var couponField: String
        @Binding var showCouponError: Bool
        @Binding var appliedCoupon: ReservationDetailScreen.AppliedCoupon?
        let validCoupon: String
        let isCouponFieldEmpty: Bool
        let shouldShowError: Bool
        let isApplyButtonEnabled: Bool
        let applyCoupon: () -> Void
        let removeCoupon: () -> Void
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Coupon Code")
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                if let coupon = appliedCoupon {
                    ZStack(alignment: .trailing) {
                        HStack(spacing: 0) {
                            HStack(alignment: .center, spacing: 10) {
                                Image("gift_box")
                            }
                            .padding(.leading, 17)
                            .padding(.trailing, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 13)
                            .frame(width: 70, height: 65, alignment: .center)
                            .background(
                                LinearGradient(
                                    stops: [
                                        Gradient.Stop(color: Color(red: 0.22, green: 0.65, blue: 0.33), location: 0.00),
                                        Gradient.Stop(color: Color(red: 0.11, green: 0.45, blue: 0.2), location: 1.00),
                                    ],
                                    startPoint: UnitPoint(x: 0.42, y: 0),
                                    endPoint: UnitPoint(x: 0.98, y: 1)
                                )
                            )
                            VStack(alignment: .leading, spacing: 0) {
                                Text(coupon.discount)
                                    .font(Font.custom("Poppins", size: 18).weight(.semibold))
                                    .foregroundColor(.hezzniGreen)
                                Text(coupon.validity)
                                    .font(Font.custom("Poppins", size: 12))
                                    .foregroundColor(.hezzniGreen)
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 40)
                            .frame(height: 65, alignment: .center)
                            Spacer()
                        }
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.15))
                        .clipShape(CouponShape())
                        .overlay(
                            CouponShape()
                                .stroke(.hezzniGreen, style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                        )
                        Button(action: removeCoupon) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .font(.system(size: 10, weight: .bold))
                        }
                        .frame(width: 20, height: 20)
                        .background(.hezzniGreen)
                        .clipShape(Circle())
                        .offset(x: 10)
                    }
                    .frame(height: 80)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 0) {
                            TextField("Enter your coupon", text: $couponField)
                                .padding(.leading, 15)
                                .padding(.vertical, 5)
                                .frame(minHeight: 50, maxHeight: 50)
                                .font(Font.custom("Poppins", size: 18))
                                .foregroundColor(Color(.label))
                                .onChange(of: couponField) { oldValue, newValue in
                                    if showCouponError && newValue != oldValue {
                                        showCouponError = false
                                    }
                                }
                            Button(action: applyCoupon) {
                                Text("Apply")
                                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                                    .foregroundColor(isApplyButtonEnabled ? .white : Color(.systemGray3))
                                    .frame(maxWidth: 100, maxHeight: 40)
                                    .frame(minWidth: 80)
                                    .background(isApplyButtonEnabled ? Color.black : Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                            .disabled(!isApplyButtonEnabled)
                            .padding(.trailing, 8)
                        }
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 0.5)
                                .stroke(.black.opacity(0.2), lineWidth: 1)
                            
                        )
                        .cornerRadius(10)
                        if shouldShowError {
                            Text("Invalid Code")
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(0)
            .frame(width: 362, alignment: .topLeading)
        }
    }
    
    struct VehicleOptionsView: View {
        @Binding var selectedOption: String?
        let options: [RideOption]
        struct RideOption {
            let id: String
            let icon: String
            let title: String
            let subtitle: String
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
    
    struct ServiceSelectorView: View {
        let services: [Service]
        @Binding var selectedService: String
        var body: some View {
            HorizontalServicesScrollView(items: services) { service in
                ServiceCardBuilder.createCard(
                    icon: service.icon,
                    title: service.title,
                    isSelected: selectedService == service.title,
                    action: { selectedService = service.title }
                )
            }
        }
    }
    
    struct CouponShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            let cutoutRadius: CGFloat = 13
            let cornerRadius: CGFloat = 8
            let cutoutYOffset = rect.midY
            let minX = rect.minX
            let maxX = rect.maxX
            let minY = rect.minY
            let maxY = rect.maxY
            
            // Start at top-left corner (after rounding)
            path.move(to: CGPoint(x: minX + cornerRadius, y: minY))
            // Top edge to top-right corner (before rounding)
            path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
            // Top-right corner arc
            path.addArc(center: CGPoint(x: maxX - cornerRadius, y: minY + cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 270),
                        endAngle: Angle(degrees: 0),
                        clockwise: false)
            // Right edge to cutout start
            path.addLine(to: CGPoint(x: maxX, y: cutoutYOffset - cutoutRadius))
            // Right side cutout
            path.addArc(center: CGPoint(x: maxX, y: cutoutYOffset),
                        radius: cutoutRadius,
                        startAngle: Angle(degrees: 270),
                        endAngle: Angle(degrees: 90),
                        clockwise: true)
            // Right edge to bottom-right corner (before rounding)
            path.addLine(to: CGPoint(x: maxX, y: maxY - cornerRadius))
            // Bottom-right corner arc
            path.addArc(center: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 0),
                        endAngle: Angle(degrees: 90),
                        clockwise: false)
            // Bottom edge to bottom-left corner (before rounding)
            path.addLine(to: CGPoint(x: minX + cornerRadius, y: maxY))
            // Bottom-left corner arc
            path.addArc(center: CGPoint(x: minX + cornerRadius, y: maxY - cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 180),
                        clockwise: false)
            // Left edge to cutout start
            path.addLine(to: CGPoint(x: minX, y: cutoutYOffset + cutoutRadius))
            // Left side cutout
            path.addArc(center: CGPoint(x: minX, y: cutoutYOffset),
                        radius: cutoutRadius,
                        startAngle: Angle(degrees: 90),
                        endAngle: Angle(degrees: 270),
                        clockwise: true)
            // Left edge to top-left corner (before rounding)
            path.addLine(to: CGPoint(x: minX, y: minY + cornerRadius))
            // Top-left corner arc
            path.addArc(center: CGPoint(x: minX + cornerRadius, y: minY + cornerRadius),
                        radius: cornerRadius,
                        startAngle: Angle(degrees: 180),
                        endAngle: Angle(degrees: 270),
                        clockwise: false)
            path.closeSubpath()
            return path
        }
    }
}

#Preview {
    ReservationDetailScreen(
        bottomSheetState: .constant(.reservation),
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
