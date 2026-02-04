//
//  RideDetailComponents.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 2/3/26.
//

import SwiftUI
internal import Combine

// MARK: - Trip Routes Section
struct TripRoutesSection: View {
    let pickup: String
    let destination: String
    var namespace: Namespace.ID?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Trip Routes")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            LocationCardView(
                imageName: "pickup_ellipse",
                heading: "Pickup Location",
                content: pickup,
                roundedEdges: .top
            )
            .applyMatchedGeometry(id: "pickup", namespace: namespace)
            
            LocationSeparator()
            
            LocationCardView(
                imageName: "dropoff_ellipse",
                heading: "Destination",
                content: destination,
                roundedEdges: .bottom
            )
            .applyMatchedGeometry(id: "destination", namespace: namespace)
        }
    }
}

// MARK: - Location Separator Icon
struct LocationSeparator: View {
    var body: some View {
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
    }
}

// MARK: - Coupon Logic Protocol
protocol CouponManaging {
    var couponField: String { get set }
    var showCouponError: Bool { get set }
    var appliedCoupon: AppliedCoupon? { get set }
    var validCoupon: String { get }
    
    var isCouponFieldEmpty: Bool { get }
    var shouldShowError: Bool { get }
    var isApplyButtonEnabled: Bool { get }
    
    mutating func applyCoupon()
    mutating func removeCoupon()
}

extension CouponManaging {
    var isCouponFieldEmpty: Bool {
        couponField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var shouldShowError: Bool {
        !isCouponFieldEmpty && couponField != validCoupon && showCouponError
    }
    
    var isApplyButtonEnabled: Bool {
        !isCouponFieldEmpty && !shouldShowError
    }
}

// MARK: - Coupon State Manager (ObservableObject version)
class CouponStateManager: ObservableObject {
    @Published var couponField: String = ""
    @Published var showCouponError: Bool = false
    @Published var appliedCoupon: AppliedCoupon? = nil
    
    let validCoupon: String
    
    init(validCoupon: String = "ABC123") {
        self.validCoupon = validCoupon
    }
    
    var isCouponFieldEmpty: Bool {
        couponField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var shouldShowError: Bool {
        !isCouponFieldEmpty && couponField != validCoupon && showCouponError
    }
    
    var isApplyButtonEnabled: Bool {
        !isCouponFieldEmpty && !shouldShowError
    }
    
    func applyCoupon() {
        if couponField == validCoupon {
           // In CouponStateManager's applyCoupon()
           appliedCoupon = AppliedCoupon(
               code: couponField,
               discount: "5% off",
               validity: "Valid for 7 days",
               couponId: 21,           // Provide a valid couponId
               discountAmount: 5.0,          // Provide a discount amount
               newPrice: 95.0                // Provide a new price after discount
           )
            couponField = ""
            showCouponError = false
        } else {
            showCouponError = true
        }
    }
    
    func removeCoupon() {
        appliedCoupon = nil
        couponField = ""
        showCouponError = false
    }
}

// MARK: - Ride Options Helper
struct RideOptionsHelper {
    static func getBaseOptions(for serviceName: String) -> [VehicleSubOptionsView.RideOption] {
        switch serviceName.lowercased() {
        case "car", "car rides":
            return carRideOptions
        case "motorcycle", "bike":
            return bikeRideOptions
        case "taxi":
            return taxiRideOptions
        default:
            return rideOptions
        }
    }
    
    static func mergeWithRideInformation(
        baseOptions: [VehicleSubOptionsView.RideOption],
        rideInformation: [CalculateRidePriceResponse.RideOption]
    ) -> [VehicleSubOptionsView.RideOption] {
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
                    price: info.price
                )
            } else {
                return option
            }
        }
    }
}

// MARK: - View Extension for Optional Matched Geometry
extension View {
    @ViewBuilder
    func applyMatchedGeometry(id: String, namespace: Namespace.ID?) -> some View {
        if let namespace = namespace {
            self.matchedGeometryEffect(id: id, in: namespace)
        } else {
            self
        }
    }
}

// MARK: - Date Formatting Helpers
struct DateFormattingHelper {
    static func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: date)
    }
    
    static func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    static func formattedDateTime(_ date: Date) -> String {
        return "\(formattedDate(date)) at \(formattedTime(date))"
    }
}

//// MARK: - Generic Ride Detail Screen Content
//struct RideDetailContent<AdditionalContent: View>: View {
//    let pickup: String
//    let destination: String
//    var namespace: Namespace.ID?
//    let selectedOption: Binding<String?>
//    let options: [VehicleSubOptionsView.RideOption]
//    let serviceType: String
//    @ObservedObject var couponManager: CouponStateManager
//    let onConfirm: () -> Void
//    let additionalContent: () -> AdditionalContent
//
//    init(
//        pickup: String,
//        destination: String,
//        namespace: Namespace.ID? = nil,
//        selectedOption: Binding<String?>,
//        options: [VehicleSubOptionsView.RideOption],
//        serviceType: String,
//        couponManager: CouponStateManager,
//        onConfirm: @escaping () -> Void,
//        @ViewBuilder additionalContent: @escaping () -> AdditionalContent
//    ) {
//        self.pickup = pickup
//        self.destination = destination
//        self.namespace = namespace
//        self.selectedOption = selectedOption
//        self.options = options
//        self.serviceType = serviceType
//        self.couponManager = couponManager
//        self.onConfirm = onConfirm
//        self.additionalContent = additionalContent
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 16) {
//                // Additional content at top (e.g., Trip Routes, Schedule)
//                additionalContent()
//
//                // Vehicle Options
//                VehicleSubOptionsView(selectedOption: selectedOption, options: options)
//                    .applyMatchedGeometry(id: "selected_vehicle", namespace: namespace)
//
//                // Coupon Section
//                CouponView(
//                    couponField: $couponManager.couponField,
//                    showCouponError: $couponManager.showCouponError,
//                    appliedCoupon: $couponManager.appliedCoupon,
//                    validCoupon: couponManager.validCoupon,
//                    isCouponFieldEmpty: couponManager.isCouponFieldEmpty,
//                    shouldShowError: couponManager.shouldShowError,
//                    isApplyButtonEnabled: couponManager.isApplyButtonEnabled,
//                    applyCoupon: couponManager.applyCoupon,
//                    removeCoupon: couponManager.removeCoupon
//                )
//
//                // Trip Summary
//                VStack(spacing: 48) {
//                    TripSummaryView(
//                        serviceType: serviceType,
//                        vehicle: options.first(where: { $0.text_id == selectedOption.wrappedValue })?.title ?? "-",
//                        estimatedTime: options.first(where: { $0.text_id == selectedOption.wrappedValue })?.timeEstimate ?? "-",
//                        price: options.first(where: { $0.text_id == selectedOption.wrappedValue }).flatMap { String(format: "%.0f", $0.price) } ?? "-"
//                    )
//
//                    PrimaryButton(text: "Confirm Trip", action: onConfirm)
//                }
//
//                Spacer()
//            }
//            .padding(.horizontal, 16)
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//}

//// MARK: - Convenience initializer for empty additional content
//extension RideDetailContent where AdditionalContent == EmptyView {
//    init(
//        pickup: String,
//        destination: String,
//        namespace: Namespace.ID? = nil,
//        selectedOption: Binding<String?>,
//        options: [VehicleSubOptionsView.RideOption],
//        serviceType: String,
//        couponManager: CouponStateManager,
//        onConfirm: @escaping () -> Void
//    ) {
//        self.init(
//            pickup: pickup,
//            destination: destination,
//            namespace: namespace,
//            selectedOption: selectedOption,
//            options: options,
//            serviceType: serviceType,
//            couponManager: couponManager,
//            onConfirm: onConfirm
//        ) {
//            EmptyView()
//        }
//    }
//}
