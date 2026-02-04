////
////  ReservationDetailScreen.swift
////  Hezzni Pessenger
////
////  Created by Zohaib Ahmed on 9/23/25.
////
//
//import SwiftUI
//
//// Applied coupon model
//struct AppliedCoupon {
//    let code: String
//    let discount: String
//    let validity: String
//}
//
//// MARK: - Group Ride Passenger Model
//private struct GroupRidePassenger: Identifiable, Equatable {
//    let id: UUID
//    var name: String
//    /// Full phone number with country dial code (e.g. "+212 605884449")
//    var phone: String
//    var isYou: Bool
//
//    init(id: UUID = UUID(), name: String, phone: String, isYou: Bool = false) {
//        self.id = id
//        self.name = name
//        self.phone = phone
//        self.isYou = isYou
//    }
//}
//
//private struct PassengerDraft: Equatable {
//    var name: String = ""
//    var country: Country = .morocco
//    var phoneNumber: String = ""
//
//    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
//
//    var fullPhone: String {
//        let cleaned = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
//        if cleaned.isEmpty { return country.dialCode }
//        return "\(country.dialCode) \(cleaned)"
//    }
//}
//
//private enum PassengerValidationError: Equatable {
//    case name
//    case phone
//    case duplicate
//}
//
//private struct PassengerValidator {
//    static func validateName(_ name: String) -> Bool {
//        name.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
//    }
//
//    static func validatePhone(country: Country, phoneNumber: String) -> Bool {
//        let pattern = country.pattern
//        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
//        return predicate.evaluate(with: phoneNumber)
//    }
//
//    static func validateFirstDigit(country: Country, phoneNumber: String) -> Bool {
//        let pattern = country.pattern
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
//        guard let first = phoneNumber.first else { return true }
//        guard !validFirstDigits.isEmpty else { return true }
//        return validFirstDigits.contains(first)
//    }
//}
//
//struct GenericRideDetailScreen : View {
//    var isReservation: Bool = false
//    var pickup: String
//    var destination: String
//    @Binding var bottomSheetState: BottomSheetState
//    var rideInformation: [CalculateRidePriceResponse.RideOption] = []
//    @Binding var selectedRideInformation: VehicleSubOptionsView.RideOption
//    var namespace: Namespace.ID?
//    @State private var selectedOption: String? = "standard"
//    @State var couponField: String = ""
//    @State private var showCouponError: Bool = false
//    @State private var appliedCoupon: AppliedCoupon? = nil
//    /// Dummy valid coupon (consistent with other reservation screens)
//    private let validCoupon: String = "ABC123"
//    @Binding var selectedService: SelectedService
//    @Binding var showSchedulePicker: Bool
//    @Binding var selectedDate: Date  // Changed from @State to @Binding
//    
//    //------Delivery fields---------//
//    @State private var reciverName: String = ""
//    @State private var parcelDescription: String = ""
//    @State private var isPhoneFieldInvalid: Bool = false
//    @State private var isReceiverNameValid: Bool = false
//    @State private var isPhoneNumberValid: Bool = false
//    @State var selectedCountry: Country = .morocco
//    
//    // Present the picker at HomeScreen level (full-screen)
//    @Binding var showCountryPicker: Bool
//    @FocusState private var isPhoneFieldFocused: Bool
//    @State private var phoneNumber: String = ""
//    
//    // MARK: - Group Ride passengers
//    private let maxPassengers: Int = 4
//    @State private var passengers: [GroupRidePassenger] = [
//        GroupRidePassenger(name: "You", phone: "+212 605884449", isYou: true)
//    ]
//    @State private var showAddPassengerSheet: Bool = false
//    @State private var passengerDraft: PassengerDraft = PassengerDraft()
//    @State private var passengerValidationError: PassengerValidationError? = nil
//    @FocusState private var isAddPassengerPhoneFocused: Bool
//    @State private var isAddPassengerPhoneFieldInvalid: Bool = false
//
//    // Filtered services (excluding Rental Car and Reservation)
//    @StateObject private var servicesViewModel = PassengerServicesViewModel()
//    
//    private var filteredServices: [PassengerService] {
//        servicesViewModel.services.filter { service in
//            let name = service.name.lowercased()
//            return name != "rental car" && name != "reservation"
//        }
//    }
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
//    private var formattedDate: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d MMMM, yyyy"
//        return formatter.string(from: selectedDate)
//    }
//    
//    private var formattedTime: String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "h:mm a"
//        return formatter.string(from: selectedDate)
//    }
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
//    
//    private var options: [VehicleSubOptionsView.RideOption] {
//        let baseOptions: [VehicleSubOptionsView.RideOption]
//        switch selectedService.displayName.lowercased() {
//        case "car", "car rides":
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
//    var body: some View {
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
////                            .matchedGeometryEffect(id: "pickup", in: namespace!)
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
////                            .matchedGeometryEffect(id: "destination", in: namespace!)
//                            if isReservation{
//                                ScheduleCardView(
//                                    dateTime: formattedDate + " at " + formattedTime,
//                                    trailingIcon: "pencil_icon",
//                                    onTap: {
//                                        withAnimation {
//                                            showSchedulePicker = true
//                                        }
//                                    }
//                                )
//                            }
//                            if selectedService.name != "Delivery" || isReservation{
//                                // MARK: - Vehicle Option
//                                Text("Vehicle Options")
//                                    .font(
//                                        Font.custom("Poppins", size: 16)
//                                            .weight(.medium)
//                                    )
//                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
//                                    .frame(maxWidth: .infinity, alignment: .topLeading)
//                            }
//                            if isReservation {
//                                // Services selector with shimmer loading
//                                if servicesViewModel.isLoading {
//                                    ServicesShimmerView(itemCount: 4)
//                                } else {
//                                    HorizontalServicesScrollView(items: filteredServices) { service in
//                                        ServiceCardBuilder.createCard(
//                                            icon: service.iconAssetName,
//                                            title: getDisplayName(for: service.name),
//                                            isSelected: selectedService.id == service.id,
//                                            action: {
//                                                selectedService = SelectedService(from: service)
//                                            }
//                                        )
//                                    }
//                                }
//                            }
//                            if selectedService.name == "Delivery" {
//                                
//                                Text("Delivery Details")
//                                    .font(
//                                        Font.custom("Poppins", size: 16)
//                                            .weight(.medium)
//                                    )
//                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
//                                    .frame(maxWidth: .infinity, alignment: .topLeading)
//                                // Full Name Field
//                                FormField(
//                                    title: "Receiver’s Name",
//                                    placeholder: "Enter your Full name",
//                                    text: $reciverName,
//                                    icon: "username_icon"
//                                )
//                                .onChange(of: reciverName) {
//                                    validateFields()
//                                }
//                                
//                                
//                                VStack{
//                                    HStack {
//                                        Text("Receiver’s Phone Number")
//                                            .font(.poppins(.medium, size: 12))
//                                            .foregroundColor(.black)
//                                        Spacer()
//                                    }
//                                    .padding(.horizontal, 5)
//                                   PhoneNumberInputView(
//                                       selectedCountry: $selectedCountry,
//                                       phoneNumber: $phoneNumber,
//                                       isPhoneFieldInvalid: $isPhoneFieldInvalid,
//                                       showCountryPicker: $showCountryPicker,
//                                       isPhoneFieldFocused: _isPhoneFieldFocused,
//                                       validatePhoneNumber: validatePhoneNumber,
//                                       validatePhoneFirstDigit: validatePhoneFirstDigit
//                                   )
//                                }
//                                // Full Name Field
//                                FormField(
//                                    title: "What are you sending?",
//                                    placeholder: "Tell about the product...",
//                                    text: $parcelDescription,
//                                    isMultiline: true
//                                )
//                                .onChange(of: reciverName) {
//                                    validateFields()
//                                }
//                            }
//                            
//                            VehicleSubOptionsView(selectedOption: $selectedOption, rideInfo: $selectedRideInformation, options: options)
////                                .matchedGeometryEffect(id: "selected_vehicle", in: namespace!)
//                            if selectedService.name == "Group Ride" {
//                                groupRidePassengersSection
//                            }
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
//                                    serviceType: selectedService.displayName,
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
//            .onAppear {
//                Task {
//                    await servicesViewModel.loadServices()
//                }
//            }
//            .onChange(of: selectedCountry) {
//                validateFields()
//            }
//            .onChange(of: phoneNumber) {
//                validateFields()
//            }
//            .onAppear {
//                validateFields()
//            }
//        }
//        .sheet(isPresented: $showAddPassengerSheet, onDismiss: resetAddPassengerDraft) {
//            AddPassengerSheet(
//                draft: $passengerDraft,
//                isPhoneFieldInvalid: $isAddPassengerPhoneFieldInvalid,
//                showCountryPicker: $showCountryPicker,
//                isPhoneFieldFocused: _isAddPassengerPhoneFocused,
//                validationError: passengerValidationError,
//                canAdd: canAddPassenger,
//                onAdd: addPassengerFromDraft,
//                onCancel: {
//                    showAddPassengerSheet = false
//                }
//            )
//            .presentationDetents([.height(540)])
//            .presentationDragIndicator(.visible)
//        }
//    }
//
//    // MARK: - Group Ride UI
//
//    private var groupRidePassengersSection: some View {
//        VStack(spacing: 12) {
//            HStack {
//                Text("Passengers List (\(passengers.count)/\(maxPassengers))")
//                    .font(Font.custom("Poppins", size: 16).weight(.medium))
//                    .lineSpacing(25.60)
//                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
//                Spacer()
//            }
//
//            VStack(spacing: 10) {
//                ForEach(Array(passengers.enumerated()), id: \.element.id) { index, passenger in
//                    passengerRow(index: index + 1, passenger: passenger)
//                }
//
//                if passengers.count < maxPassengers {
//                    Button {
//                        passengerValidationError = nil
//                        showAddPassengerSheet = true
//                    } label: {
//                        HStack(spacing: 11) {
//                            VStack(spacing: 10) {
//                                Image(systemName: "plus")
//                                    .foregroundStyle(.hezzniGreen)
//                            }
//                            .padding(12)
//                            .frame(width: 35, height: 35)
//                            .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.10))
//                            .cornerRadius(93.94)
//
//                            Text("Add Passenger")
//                                .font(Font.custom("Poppins", size: 16).weight(.medium))
//                                .foregroundColor(.black)
//
//                            Spacer()
//                        }
//                        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
//                        .frame(height: 65)
//                        .cornerRadius(15)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 15)
//                                .inset(by: 0.50)
//                                .stroke(
//                                    Color(red: 0, green: 0, blue: 0).opacity(0.20), lineWidth: 0.50
//                                )
//                        )
//                        .shadow(
//                            color: Color(red: 1, green: 1, blue: 1, opacity: 1), radius: 47, y: 4
//                        )
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//
//    private func passengerRow(index: Int, passenger: GroupRidePassenger) -> some View {
//        HStack(spacing: 11) {
//            VStack(spacing: 10) {
//                Text("\(index)")
//                    .font(Font.custom("Poppins", size: 18).weight(.medium))
//                    .foregroundColor(.white)
//            }
//            .padding(12)
//            .frame(width: 40, height: 40)
//            .background(Color(red: 0.22, green: 0.65, blue: 0.33))
//            .cornerRadius(10)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(passenger.name)
//                    .font(Font.custom("Poppins", size: 14).weight(.medium))
//                    .lineSpacing(16)
//                    .foregroundColor(.black)
//                Text(passenger.phone)
//                    .font(Font.custom("Poppins", size: 10))
//                    .lineSpacing(12)
//                    .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.50))
//            }
//
//            Spacer()
//
//            if !passenger.isYou {
//                Button {
//                    removePassenger(passenger)
//                } label: {
//                    Image(systemName: "trash")
//                        .foregroundStyle(Color.red.opacity(0.9))
//                        .font(.system(size: 14, weight: .semibold))
//                        .padding(10)
//                }
//                .buttonStyle(.plain)
//            }
//        }
//        .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
//        .frame(height: 65)
//        .cornerRadius(15)
//        .overlay(
//            RoundedRectangle(cornerRadius: 15)
//                .inset(by: 0.50)
//                .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 0.50)
//        )
//        .shadow(
//            color: Color(red: 1, green: 1, blue: 1, opacity: 1), radius: 47, y: 4
//        )
//    }
//
//    private var canAddPassenger: Bool {
//        guard passengers.count < maxPassengers else { return false }
//        guard PassengerValidator.validateName(passengerDraft.name) else { return false }
//        guard PassengerValidator.validatePhone(country: passengerDraft.country, phoneNumber: passengerDraft.phoneNumber) else { return false }
//        guard PassengerValidator.validateFirstDigit(country: passengerDraft.country, phoneNumber: passengerDraft.phoneNumber) else { return false }
//        let phone = passengerDraft.fullPhone
//        return !passengers.contains(where: { $0.phone == phone })
//    }
//
//    private func addPassengerFromDraft() {
//        guard passengers.count < maxPassengers else { return }
//
//        if !PassengerValidator.validateName(passengerDraft.name) {
//            passengerValidationError = .name
//            return
//        }
//
//        if !PassengerValidator.validatePhone(country: passengerDraft.country, phoneNumber: passengerDraft.phoneNumber) ||
//            !PassengerValidator.validateFirstDigit(country: passengerDraft.country, phoneNumber: passengerDraft.phoneNumber) {
//            passengerValidationError = .phone
//            isAddPassengerPhoneFieldInvalid = true
//            return
//        }
//
//        let fullPhone = passengerDraft.fullPhone
//        if passengers.contains(where: { $0.phone == fullPhone }) {
//            passengerValidationError = .duplicate
//            return
//        }
//
//        passengers.append(
//            GroupRidePassenger(
//                name: passengerDraft.trimmedName,
//                phone: fullPhone,
//                isYou: false
//            )
//        )
//
//        showAddPassengerSheet = false
//        resetAddPassengerDraft()
//    }
//
//    private func removePassenger(_ passenger: GroupRidePassenger) {
//        passengers.removeAll { $0.id == passenger.id }
//    }
//
//    private func resetAddPassengerDraft() {
//        passengerDraft = PassengerDraft(country: selectedCountry)
//        passengerValidationError = nil
//        isAddPassengerPhoneFieldInvalid = false
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
//    
//    /// Get display name for service (shorter version for UI)
//    private func getDisplayName(for name: String) -> String {
//        switch name.lowercased() {
//        case "car rides":
//            return "Car"
//        case "airport ride":
//            return "Ride to Airport"
//        case "city to city":
//            return "City to City"
//        case "group ride":
//            return "Group Ride"
//        default:
//            return name
//        }
//    }
//}
//
//#Preview {
//    GenericRideDetailScreen(
//        pickup: "pickupLocation",
//        destination: "destinationLocation",
//        bottomSheetState: .constant(.reservation),
//        selectedRideInformation: .constant(VehicleSubOptionsView.RideOption(id: 0, text_id: "standard", icon: "", title: "Standard", subtitle: "", seats: 4, timeEstimate: "10 min", price: 100)),
//        selectedService: .constant(SelectedService(id: 1, name: "Group Ride")),
//        showSchedulePicker: .constant(false),
//        selectedDate: .constant(Date()),
//        showCountryPicker: .constant(false)
//    )
//}
//
//// MARK: - BottomSheetContent for dynamic height
//struct BottomSheetContent: View {
//    @Binding var showSchedulePicker: Bool
//    @Binding var selectedDate: Date
//    @State private var contentHeight: CGFloat = 0
//    var body: some View {
//        VStack(spacing: 0) {
//            SchedulePickerScreen(showSchedulePicker: $showSchedulePicker, selectedDate: $selectedDate)
//                .background(
//                    GeometryReader { proxy in
//                        Color.clear
//                            .onAppear {
//                                contentHeight = proxy.size.height
//                            }
//                            .onChange(of: proxy.size.height) { newHeight in
//                                contentHeight = newHeight
//                            }
//                    }
//                )
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: contentHeight > 0 ? contentHeight + 48 : nil) // 48 for close button spacing
//        .background(Color.white)
//        .cornerRadius(20)
//        .shadow(radius: 10)
//    }
//}
//
//// MARK: - Add Passenger Sheet
//
//private struct AddPassengerSheet: View {
//    @Binding var draft: PassengerDraft
//    @Binding var isPhoneFieldInvalid: Bool
//    @Binding var showCountryPicker: Bool
//    @FocusState var isPhoneFieldFocused: Bool
//
//    var validationError: PassengerValidationError?
//    var canAdd: Bool
//    var onAdd: () -> Void
//    var onCancel: () -> Void
//
//    var body: some View {
//        VStack(spacing: 18) {
//            HStack {
//                Spacer()
//                Button {
//                    onCancel()
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundStyle(Color.black.opacity(0.35))
//                        .font(.system(size: 16, weight: .semibold))
//                        .padding(6)
//                }
//                .buttonStyle(.plain)
//            }
//
//            VStack(spacing: 6) {
//                Text("Passenger Details")
//                    .font(.poppins(.semiBold, size: 22))
//                    .foregroundColor(.black)
//
//                Text("Add your passenger’s details")
//                    .font(.poppins(.regular, size: 14))
//                    .foregroundColor(Color.black.opacity(0.45))
//            }
//
//            VStack(spacing: 14) {
//                
//                FormField(title: "Pickup Point", placeholder: "Enter passenger address", text: .constant("Current Location"), icon: "pickup_ellipse")
//                // Name
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Name")
//                        .font(.poppins(.medium, size: 12))
//                        .foregroundColor(.black)
//
//                    HStack(spacing: 10) {
//                        Image(systemName: "person")
//                            .foregroundStyle(Color.black.opacity(0.45))
//                        TextField("Enter passenger name", text: $draft.name)
//                            .font(.poppins(.regular, size: 16))
//                            .textInputAutocapitalization(.words)
//                            .autocorrectionDisabled(true)
//                    }
//                    .padding(.horizontal, 12)
//                    .frame(height: 50)
//                    .background(Color.white)
//                    .cornerRadius(12)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .inset(by: 0.50)
//                            .stroke((validationError == .name) ? Color.red : Color.black.opacity(0.2), lineWidth: 0.50)
//                    )
//
//                    if validationError == .name {
//                        Text("Please enter a valid name")
//                            .font(.poppins(.regular, size: 12))
//                            .foregroundColor(.red)
//                    }
//                }
//
//                // Phone
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Phone Number")
//                        .font(.poppins(.medium, size: 12))
//                        .foregroundColor(.black)
//
//                    PhoneNumberInputView(
//                        selectedCountry: $draft.country,
//                        phoneNumber: $draft.phoneNumber,
//                        isPhoneFieldInvalid: $isPhoneFieldInvalid,
//                        showCountryPicker: $showCountryPicker,
//                        isPhoneFieldFocused: _isPhoneFieldFocused,
//                        validatePhoneNumber: {},
//                        validatePhoneFirstDigit: {}
//                    )
//
//                    if validationError == .phone {
//                        Text("Please enter a valid phone number")
//                            .font(.poppins(.regular, size: 12))
//                            .foregroundColor(.red)
//                            .padding(.leading, 5)
//                    }
//
//                    if validationError == .duplicate {
//                        Text("This phone number is already added")
//                            .font(.poppins(.regular, size: 12))
//                            .foregroundColor(.red)
//                            .padding(.leading, 5)
//                    }
//                }
//            }
//
//            Spacer(minLength: 0)
//
//            PrimaryButton(text: "Add Passenger", action: {
//                onAdd()
//            })
//            .disabled(!canAdd)
//            .opacity(canAdd ? 1 : 0.5)
//        }
//        .padding(.horizontal, 20)
//        .padding(.top, 10)
//        .padding(.bottom, 18)
//        .background(Color.white)
//    }
//}
