//
//  DeliveryDetailScreen.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/1/26.
//
import SwiftUI
import FlagsKit

//struct DeliveryDetailScreen : View {
//    var pickup: String
//    var destination: String
//    @Binding var bottomSheetState: BottomSheetState
//    // Present the picker at HomeScreen level (full-screen)
//    @Binding var showCountryPicker: Bool
//    var namespace: Namespace.ID?
//    
//    @State private var selectedOption: String? = "standard"
//    @State var couponField: String = ""
//    @State private var showCouponError: Bool = false
//    @State private var couponErrorMessage: String = "Invalid coupon code"
//    @State private var appliedCoupon: AppliedCoupon? = nil
//    @State private var isValidatingCoupon: Bool = false
//    @State private var reciverName: String = ""
//    @State private var parcelDescription: String = ""
//    @State private var isPhoneFieldInvalid: Bool = false
//    @State private var isReceiverNameValid: Bool = false
//    @State private var isPhoneNumberValid: Bool = false
//    @Binding var selectedCountry: Country
//    
//    @State private var phoneNumber: String = ""
//    @FocusState private var isPhoneFieldFocused: Bool
//    
//    var selectedService: String = "Car"
//    let deliveryService = CalculateRidePriceResponse.RideOption(
//        id: 1,
//        text_id: "standard",
//        icon: "car-service-icon",
//        title: "Hezzni Standard",
//        subtitle: "Comfortable vehicles",
//        seats: 4,
//        timeEstimate: "3-8 min",
//        ridePreference: "None",
//        ridePreferenceKey: "Hezzni Standards",
//        description: "Affordable rides for everyday travel",
//        price: 25
//    );
//    //    @Namespace private var animations
//    
//    // Computed properties for coupon logic
//    private var isCouponFieldEmpty: Bool {
//        couponField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//    }
//    
//    private var shouldShowError: Bool {
//        !isCouponFieldEmpty && showCouponError
//    }
//    
//    private var isApplyButtonEnabled: Bool {
//        !isCouponFieldEmpty && !isValidatingCoupon
//    }
//    
//   
//    // Apply coupon action - validates via API
//    private func applyCoupon() {
//        let couponCode = couponField.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !couponCode.isEmpty else { return }
//        
//        // Get the current price from deliveryService
//        let currentPrice = deliveryService.price
//        
//        isValidatingCoupon = true
//        showCouponError = false
//        
//        Task {
//            do {
//                let response = try await APIService.shared.validateCoupon(code: couponCode, price: currentPrice)
//                
//                await MainActor.run {
//                    isValidatingCoupon = false
//                    
//                    if response.data.isValid {
//                        // Coupon is valid
//                        let discountPercentage = currentPrice > 0 
//                            ? Int((response.data.discountAmount / currentPrice) * 100) 
//                            : 0
//                        
//                        appliedCoupon = AppliedCoupon(
//                            code: couponCode,
//                            discount: "\(discountPercentage)% off",
//                            validity: "Applied successfully",
//                            couponId: response.data.couponId,
//                            discountAmount: response.data.discountAmount,
//                            newPrice: response.data.newPrice
//                        )
//                        couponField = ""
//                        showCouponError = false
//                    } else {
//                        // Coupon is not valid
//                        couponErrorMessage = "Invalid coupon code"
//                        showCouponError = true
//                    }
//                }
//            } catch {
//                await MainActor.run {
//                    isValidatingCoupon = false
//                    couponErrorMessage = error.localizedDescription
//                    showCouponError = true
//                }
//            }
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
//        switch selectedService.lowercased() {
//        case "car":
//            return carRideOptions
//        case "motorcycle":
//            return bikeRideOptions
//        case "taxi":
//            return taxiRideOptions
//        default:
//            return rideOptions
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
//                            
//                            Text("Delivery Details")
//                                .font(
//                                    Font.custom("Poppins", size: 16)
//                                        .weight(.medium)
//                                )
//                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
//                                .frame(maxWidth: .infinity, alignment: .topLeading)
//                            // Full Name Field
//                            FormField(
//                                title: "Receiver’s Name",
//                                placeholder: "Enter your Full name",
//                                text: $reciverName,
//                                icon: "username_icon"
//                            )
//                            .onChange(of: reciverName) {
//                                validateFields()
//                            }
//                            
//                            
//                            VStack{
//                                HStack {
//                                    Text("Receiver’s Phone Number")
//                                        .font(.poppins(.medium, size: 12))
//                                        .foregroundColor(.black)
//                                    Spacer()
//                                }
//                                .padding(.horizontal, 5)
//                               PhoneNumberInputView(
//                                   selectedCountry: $selectedCountry,
//                                   phoneNumber: $phoneNumber,
//                                   isPhoneFieldInvalid: $isPhoneFieldInvalid,
//                                   showCountryPicker: $showCountryPicker,
//                                   isPhoneFieldFocused: _isPhoneFieldFocused,
//                                   validatePhoneNumber: validatePhoneNumber,
//                                   validatePhoneFirstDigit: validatePhoneFirstDigit
//                               )
//                            }
//                            // Full Name Field
//                            FormField(
//                                title: "What are you sending?",
//                                placeholder: "Tell about the product...",
//                                text: $parcelDescription,
//                                isMultiline: true
//                            )
//                            .onChange(of: reciverName) {
//                                validateFields()
//                            }
//                            Text("Vehicle Option")
//                                .font(
//                                    Font.custom("Poppins", size: 16)
//                                        .weight(.medium)
//                                )
//                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
//                                .frame(maxWidth: .infinity, alignment: .topLeading)
//                            RideOptionCard(
//                                icon: deliveryService.icon,
//                                title: deliveryService.title,
//                                subtitle: deliveryService.subtitle,
//                                seats: deliveryService.seats,
//                                timeEstimate: deliveryService.timeEstimate,
//                                price: deliveryService.price,
//                                isSelected: .constant(true)
//                                
//                            )
//                                .matchedGeometryEffect(id: "selected_vehicle", in: namespace!)
//                            // MARK: - Coupon section
//                            CouponView(
//                                couponField: $couponField,
//                                showCouponError: $showCouponError,
//                                appliedCoupon: $appliedCoupon,
//                                errorMessage: couponErrorMessage,
//                                isCouponFieldEmpty: isCouponFieldEmpty,
//                                shouldShowError: shouldShowError,
//                                isApplyButtonEnabled: isApplyButtonEnabled,
//                                isLoading: isValidatingCoupon,
//                                applyCoupon: applyCoupon,
//                                removeCoupon: removeCoupon
//                            )
//                            // MARK: Trip Summary
//                            VStack(spacing: 48){
//                                TripSummaryView(
//                                    serviceType: selectedService,
//                                    vehicle: options.first(where: { $0.text_id == selectedOption })?.title ?? "-",
//                                    estimatedTime: options.first(where: { $0.text_id == selectedOption })?.timeEstimate ?? "-",
//                                    price: options.first(where: { $0.text_id == selectedOption }).flatMap { String(format: "%.0f", $0.price) } ?? "-",
//                                    discountedPrice: appliedCoupon.flatMap { String(format: "%.0f", $0.newPrice) },
//                                    discountText: appliedCoupon?.discount
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
//            .allowsHitTesting(!showCountryPicker)
//
//            // NOTE: picker overlay is now owned by HomeScreen
//        }
//        .onChange(of: selectedCountry) {
//            validateFields()
//        }
//        .onChange(of: phoneNumber) {
//            validateFields()
//        }
//        .onAppear {
//            validateFields()
//        }
//    }
//    
//    // MARK: - Validation
//
//    private func validatePhoneNumber() {
//        let pattern = selectedCountry.pattern
//        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
//        isPhoneNumberValid = predicate.evaluate(with: phoneNumber)
//
//        if phoneNumber.isEmpty {
//            isPhoneFieldInvalid = false
//        }
//    }
//
//    private func validatePhoneFirstDigit() {
//        let pattern = selectedCountry.pattern
//        var validFirstDigits: [Character] = []
//
//        if let match = pattern.range(of: "\\^\\[([0-9])-?([0-9])?\\]", options: .regularExpression) {
//            let range = pattern[match]
//            let digits = range.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
//            validFirstDigits = Array(digits)
//        } else if let match = pattern.range(of: "\\^([0-9])", options: .regularExpression) {
//            let digit = pattern[match].replacingOccurrences(of: "^", with: "")
//            validFirstDigits = [Character(digit)]
//        }
//
//        if !validFirstDigits.isEmpty, let first = phoneNumber.first {
//            isPhoneFieldInvalid = !validFirstDigits.contains(first)
//        } else {
//            isPhoneFieldInvalid = false
//        }
//
//        if phoneNumber.isEmpty { isPhoneFieldInvalid = false }
//    }
//
//    private func validateFields() {
//        let trimmedName = reciverName.trimmingCharacters(in: .whitespacesAndNewlines)
//        isReceiverNameValid = trimmedName.count >= 2
//
//        validatePhoneNumber()
//        validatePhoneFirstDigit()
//    }
//}
//

//#Preview {
//    DeliveryDetailScreen_PreviewWrapper()
//}
//
//private struct DeliveryDetailScreen_PreviewWrapper: View {
//    @State private var bottomSheetState: BottomSheetState = .deliveryService
//    @State private var selectedCountry: Country = .morocco
//
//    var body: some View {
//        DeliveryDetailScreen(
//            bottomSheetState: $bottomSheetState,
//            showCountryPicker: .constant(false),
//            selectedCountry: $selectedCountry
//        )
//    }
//}

struct PhoneNumberInputView: View {
    @Binding var selectedCountry: Country
    @Binding var phoneNumber: String
    @Binding var isPhoneFieldInvalid: Bool
    @Binding var showCountryPicker: Bool
    @FocusState var isPhoneFieldFocused: Bool

    var validatePhoneNumber: () -> Void
    var validatePhoneFirstDigit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ZStack {
                    FlagView(countryCode: selectedCountry.code, style: .circle)
                        .frame(width: 22, height: 22)
                }
                Button {
                    showCountryPicker = true
                } label: {
                    HStack(spacing: 4) {
                        Text(selectedCountry.dialCode)
                            .font(.custom("Poppins", size: 14))
                            .foregroundColor(.black)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .frame(minWidth: 40)
                Rectangle()
                    .frame(width: 1, height: 56)
                    .foregroundColor(Color.black.opacity(0.1))
                    .padding(.horizontal, 4)
                ZStack(alignment: .leading) {
                    if phoneNumber.isEmpty {
                        Text(selectedCountry.phonePlaceholder)
                            .font(.custom("Poppins", size: 16))
                            .foregroundColor(Color.black.opacity(0.4))
                    }
                    TextField("", text: $phoneNumber)
                        .keyboardType(.numberPad)
                        .font(.custom("Poppins", size: 16))
                        .foregroundColor(.black)
                        .focused($isPhoneFieldFocused)
                        .onChange(of: phoneNumber) {
                            validatePhoneNumber()
                            validatePhoneFirstDigit()
                        }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 12)
            .frame(height: 50)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.50)
                    .stroke(isPhoneFieldInvalid ? Color.red : (isPhoneFieldFocused ? Color.black : Color.black.opacity(0.2)), lineWidth: 0.50)
            )
            .shadow(
                color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.006), radius: 50, y: 4
            )
            if isPhoneFieldInvalid {
                Text("Invalid phone number")
                    .font(.custom("Poppins", size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 5)
            }
//            else {
//                Text(selectedCountry.placeholder)
//                    .font(.custom("Poppins", size: 12))
//                    .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
//                    .padding(.leading, 5)
//            }
        }
    }
}
