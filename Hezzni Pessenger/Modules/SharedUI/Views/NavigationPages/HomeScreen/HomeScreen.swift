//
//  HomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/16/25.
//

import SwiftUI
import GoogleMaps
import FlagsKit
import CoreLocation

enum BottomSheetState {
    case initial
    case journey
    case chooseOnMap
    case rideSummary      // New state: Shows pickup/destination with route and continue button
    case rideOptions      // New state: Shows ride price options after API call
    case payment
    case orderSummary
    case findingRide
    case reservationConfirmation
    case reservation
    case nowRide
    case deliveryService
}

struct HomeScreen: View {
    
    //-----------Inital Screen Variables -----------------------//
    @Binding var selectedService: SelectedService
    @Binding var isNowSelected: Bool
    @Binding var pickupLocation: String
    @Binding var destinationLocation: String
    
    @Binding private var bottomSheetState: BottomSheetState
    
    // MARK: - Services ViewModel
    @StateObject private var servicesViewModel = PassengerServicesViewModel()
   
    @State private var isEditingPickup = false
    @State private var isEditingDestination = false
    @State private var showSuggestions = false
    @State private var searchText = ""
    @State private var mapView = GMSMapView()
    @State private var cameraPosition: GMSCameraPosition
    @StateObject private var locationManager = LocationManager()
    
    // MARK: - Location Coordinates Storage
    @State private var pickupLatitude: Double = 0
    @State private var pickupLongitude: Double = 0
    @State private var destinationLatitude: Double = 0
    @State private var destinationLongitude: Double = 0
    @State private var rideOptions: [CalculateRidePriceResponse.RideOption] = []
    @State private var selectedRideOption: CalculateRidePriceResponse.RideOption?
    @State private var isCalculatingPrice = false
    @State private var priceCalculationError: String?
    @State private var estimatedDistance: Double = 0
    @State private var estimatedDuration: Int = 0
    @State private var routePolyline: GMSPolyline?
    
    //MARK: Animation Variables
    @Namespace private var animations
    
    //MARK: For Reservation Screen
    @State private var showSchedulePicker = false
    @State private var selectedDate: Date = Date()
    @State private var appliedCoupon: AppliedCoupon? = nil
    
    //MARK: Variables for second screen
    @State private var showServices = true
    @State private var isLoadingLocation = false
    
    // Custom sheet properties
    @State private var sheetHeight: CGFloat = 530
    @State private var isDragging = false
    private let minSheetHeight: CGFloat = 160
    private let midSheetHeight: CGFloat = 530
    private let maxSheetHeight: CGFloat = UIScreen.main.bounds.height * 0.85
    @EnvironmentObject private var navigationState: NavigationStateManager

    // Notifications presentation (avoid navigationDestination)
    @State private var isShowingNotifications = false

    // Country picker presentation (full-screen overlay)
    @State private var showCountryPicker: Bool = false
    @State private var selectedCountryForDelivery: Country = .morocco
    
    @State var selectedRideInformation: VehicleSubOptionsView.RideOption

    // Filtered services (excluding Rental Car and Reservation)
    private var filteredServices: [PassengerService] {
        servicesViewModel.services.filter { service in
            let name = service.name.lowercased()
            return name != "rental car" && name != "reservation"
        }
    }
    
    // Google Places autocomplete suggestions
    @State private var placeSuggestions: [PlaceSuggestion] = []
    @State private var isLoadingSuggestions = false
    
    // Track which location is being selected from map (pickup or destination)
    @State private var isSelectingPickupFromMap = true
    @State private var hasSetInitialPickupLocation = false
    
    init(
        selectedService: Binding<SelectedService>,
        isNowSelected: Binding<Bool>,
        pickupLocation: Binding<String>,
        destinationLocation: Binding<String>,
        bottomSheetState: Binding<BottomSheetState>
    ) {
        self._selectedService = selectedService
        self._isNowSelected = isNowSelected
        self._pickupLocation = pickupLocation
        self._destinationLocation = destinationLocation
        self._bottomSheetState = bottomSheetState
    
        let marrakech = CLLocationCoordinate2D(latitude: 40.629255690273595, longitude: -73.98749804295893)
        _cameraPosition = State(initialValue: GMSCameraPosition.camera(withTarget: marrakech, zoom: 14))
        _selectedRideInformation = State(initialValue: VehicleSubOptionsView.RideOption(
            id: 0,
            text_id: "standard",
            icon: "",
            title: "Standard",
            subtitle: "",
            seats: 4,
            timeEstimate: "10 min",
            price: 100
        ))
    }
    
    var body: some View {
        NavigationStack(path: $navigationState.path) {
            ZStack {
                // Home content
                ZStack(alignment: .bottom) {
                    // Map view with overlay
                    mapContentView
                        .onAppear {
                            configureMap()
                        }

                    // Custom draggable sheet
                    draggableSheet
                }
                .edgesIgnoringSafeArea(.bottom)
                .onAppear {
                    locationManager.startUpdatingLocation()
                }
                .onChange(of: locationManager.currentLocation) { location in
                    updateCameraPosition(location: location)
                    
                    // Auto-set pickup location from user's current location (only once)
                    if !hasSetInitialPickupLocation, let location = location {
                        hasSetInitialPickupLocation = true
                        setPickupFromCurrentLocation(location: location)
                    }
                }
                .onAppear {
                    if bottomSheetState == .initial {
                        navigationState.showBottomBar()
                    }
                    
                }

                // Notification overlay
                if isShowingNotifications {
                    NotificationScreen(showNotification: $isShowingNotifications)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(10)
                }
            }
        }
        .overlay {
            if showSchedulePicker {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showSchedulePicker = false
                        }
                    }
                VStack {
                    Spacer()
                    BottomSheetContent(
                        showSchedulePicker: $showSchedulePicker,
                        selectedDate: $selectedDate
                    )
                }
                .edgesIgnoringSafeArea(.bottom)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showSchedulePicker)
            }
        }
        .onAppear{
            if bottomSheetState != .initial {
//                navigationState.hideBottomBar()
                sheetHeight = maxSheetHeight
            }
        }
        .overlay {
            // Country picker overlay
            if showCountryPicker {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showCountryPicker = false
                    }

                VStack {
                    Spacer()

                    VStack(spacing: 0) {
                        HStack {
                            Button("Cancel") {
                                showCountryPicker = false
                            }
                            .foregroundColor(.blue)
                            .font(.body)

                            Spacer()

                            Text("Select Country")
                                .font(.headline)

                            Spacer()

                            Button("Done") {
                                showCountryPicker = false
                            }
                            .foregroundColor(.blue)
                            .font(.body)
                        }
                        .padding()
                        .background(Color(.systemGray6))

                        Picker("Select Country", selection: $selectedCountryForDelivery) {
                            ForEach(Country.countries) { country in
                                HStack {
                                    FlagView(countryCode: country.code, style: .circle)
                                        .frame(width: 22, height: 22)

                                    Text(country.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text(country.dialCode)
                                        .foregroundColor(.gray)
                                }
                                .tag(country)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(height: 200)
                        .background(Color.white)
                    }
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .transition(.move(edge: .bottom))
                .zIndex(100)
            }
        }
    }
    
    // MARK: - Subviews
    
    private var mapContentView: some View {
        ZStack(alignment: .top) {
            GoogleMapView(mapView: $mapView, cameraPosition: $cameraPosition)
                .edgesIgnoringSafeArea(.all)
            
            // Center marker when choosing from map
            if bottomSheetState == .chooseOnMap {
                VStack {
                    Spacer()
                    VStack(spacing: 4) {
                        // Label showing what's being selected
                        Text(isSelectingPickupFromMap ? "Select Pickup" : "Select Destination")
                            .font(Font.custom("Poppins", size: 12).weight(.medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .cornerRadius(8)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        // Custom map pin from assets
                        Image("map_pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    Spacer()
                }
                .padding(.bottom, sheetHeight + 30)
            }
            
            // Distance/Duration info card when showing route
            if bottomSheetState == .rideSummary || bottomSheetState == .rideOptions {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    
                    // Route info card
                    HStack(spacing: 0) {
                        // Distance
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", estimatedDistance))
                                .font(Font.custom("Poppins", size: 16).weight(.bold))
                                .foregroundColor(.white)
                            Text("KM")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                        
                        // Duration
                        HStack(spacing: 4) {
                            Text("\(estimatedDuration)")
                                .font(Font.custom("Poppins", size: 16).weight(.bold))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                            Text("min")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        
                        // Destination
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Destination")
                                .font(Font.custom("Poppins", size: 10))
                                .foregroundColor(.gray)
                            Text(destinationLocation)
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(.black)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: 150)
                        .background(Color.white)
                    }
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
            VStack(spacing: 0) {
                HStack {
//                    greetingText
                    Spacer()
                    NotificationButton(action: {
                        navigationState.hideBottomBar()
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isShowingNotifications = true
                        }
                    })
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
//                .background(.white)
                Spacer()
            }
        }
        
    }
   
    
    private var suggestionsListView: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(filteredSuggestions, id: \.self) { suggestion in
                    suggestionRow(suggestion: suggestion)
                    Divider()
                }
            }
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.horizontal, 16)
            .padding(.bottom, sheetHeight + 50)
        }
    }
    
    // Note: filteredSuggestions is kept for backward compatibility but
    // placeSuggestions from Google API should be used instead
    private var filteredSuggestions: [String] {
        // Return empty array - we use Google Places API suggestions now
        return []
    }
    
    private func suggestionRow(suggestion: String) -> some View {
        Button(action: {
            handleSuggestionSelection(suggestion)
        }) {
            HStack {
                Image("suggestion_pin")
                    .foregroundColor(.gray)
                
                Text(suggestion)
                    .foregroundColor(.primary)
                    .padding(.vertical, 12)
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
    
    //MARK: - Draggable Sheet
    private var draggableSheet: some View {
        VStack(spacing: 0) {
            // Drag handle
            if bottomSheetState != .rideSummary {
                dragHandle
            }
            
            // ----------- Titles ------------
            if bottomSheetState == .journey {
                CustomAppBar(
                    title: selectedService.displayName,
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .initial
                            sheetHeight = midSheetHeight
                            navigationState.showBottomBar()
                        }
                    },
//                    trailingView: {
//                        Button(action: {
//                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
//                                if !isNowSelected {
//                                    if selectedService == "Delivery" || selectedService == "Group Ride"{
//                                        selectedService = "Car"
//                                    }
//                                        bottomSheetState = .reservation
//
//                                } else{
//                                    if selectedService == "Delivery" {
//                                        bottomSheetState = .deliveryService
//                                    }else {
//                                        bottomSheetState = .nowRide
//                                    }
//
//                                }
//                                sheetHeight = maxSheetHeight
//                            }
//                        }) {
//                            Text("Next")
//                                .font(.poppins(.medium, size: 14))
//                                .foregroundColor(.hezzniGreen)
//                        }
//                    }
                )
                .padding(.horizontal, 16)
            }
            if bottomSheetState == .reservation {
                CustomAppBar(
                    title: "Reservation Details",
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .journey
                            sheetHeight = maxSheetHeight
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            if bottomSheetState == .nowRide {
                CustomAppBar(
                    title: "Trip Details",
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .journey
                            sheetHeight = maxSheetHeight
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            if bottomSheetState == .deliveryService {
                CustomAppBar(
                    title: "Delivery Details",
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .journey
                            sheetHeight = maxSheetHeight
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            if bottomSheetState == .rideSummary {
                CustomAppBar(
                    title: selectedService.displayName,
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .journey
                            sheetHeight = maxSheetHeight
                            // Clear route
                            routePolyline?.map = nil
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            if bottomSheetState == .rideOptions {
                CustomAppBar(
                    title: "Choose Ride Option",
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .rideSummary
                            sheetHeight = midSheetHeight
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            if bottomSheetState == .payment {
                CustomAppBar(
                    title: "Choose Payment Method",
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .reservation
                            sheetHeight = maxSheetHeight
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            if bottomSheetState == .orderSummary {
                CustomAppBar(
                    title: "Payment Confirmation",
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .payment
                            sheetHeight = maxSheetHeight
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            
            // Services scroll view
            if bottomSheetState == .initial {
                servicesScrollView
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
                .frame(height: 5)
            
            // Location selection content or Reservation screen
            if bottomSheetState == .reservation {
                GenericRideDetailScreen(
                    isReservation: !isNowSelected,
                    pickup: pickupLocation,
                    destination: destinationLocation,
                    bottomSheetState: $bottomSheetState,
                    rideInformation: rideOptions,
                    selectedRideInformation: $selectedRideInformation,
                    namespace: animations,
                    appliedCoupon: $appliedCoupon,
                    selectedService: $selectedService,
                    showSchedulePicker: $showSchedulePicker,
                    selectedDate: $selectedDate,
                    showCountryPicker: $showCountryPicker
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .nowRide {
                GenericRideDetailScreen(
                    isReservation: !isNowSelected,
                    pickup: pickupLocation,
                    destination: destinationLocation,
                    bottomSheetState: $bottomSheetState,
                    rideInformation: rideOptions,
                    
                    selectedRideInformation: $selectedRideInformation,
                    namespace: animations,
                    appliedCoupon: $appliedCoupon,
                    selectedService: $selectedService,
                    showSchedulePicker: $showSchedulePicker,
                    selectedDate: $selectedDate,
                    showCountryPicker: $showCountryPicker
                )
//                NowRideDetailScreen(
//                    pickup: pickupLocation,
//                    destination: destinationLocation,
//                    bottomSheetState: $bottomSheetState,
//                    rideInformation: rideOptions,
//                    namespace: animations,
//                    selectedService: selectedService.displayName
//                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .deliveryService {
                GenericRideDetailScreen(
                    isReservation: !isNowSelected,
                    pickup: pickupLocation,
                    destination: destinationLocation,
                    bottomSheetState: $bottomSheetState,
                    rideInformation: rideOptions,
                    selectedRideInformation: $selectedRideInformation,
                    namespace: animations,
                    appliedCoupon: $appliedCoupon,
                    selectedService: $selectedService,
                    showSchedulePicker: $showSchedulePicker,
                    selectedDate: $selectedDate,
                    showCountryPicker: $showCountryPicker
                )
//                DeliveryDetailScreen(
//                    pickup: pickupLocation,
//                    destination: destinationLocation,
//                    bottomSheetState: $bottomSheetState,
//                    showCountryPicker: $showCountryPicker,
//                    namespace: animations,
//                    selectedCountry: $selectedCountryForDelivery,
//                    selectedService: selectedService.displayName
//                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .rideSummary {
                // Ride Summary Screen - Shows pickup/destination with continue button
                rideSummaryView
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .payment{
                RidePaymentScreen(
                    rideInfo: selectedRideInformation,
                    selectedService: $selectedService,
                    bottomSheetState: $bottomSheetState,
                    namespace: animations
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .orderSummary {
                PaymentConfirmationScreen(
                    bottomSheetState: $bottomSheetState,
                    namespace: animations,
                    onContinue: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .findingRide
                            
                        }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .findingRide {
                FindingRideScreen(
                    bottomSheetState: $bottomSheetState,
                    namespace: animations,
                    sheetHeight: $sheetHeight,
                    isReservation: !isNowSelected,
                    vehicle: selectedRideOption.map {
                        VehicleSubOptionsView.RideOption(
                            id: $0.id,
                            text_id: $0.ridePreference.lowercased().replacingOccurrences(of: " ", with: "-"),
                            icon: getIconForPreference($0.ridePreference),
                            title: $0.ridePreference,
                            subtitle: "Comfortable vehicles",
                            seats: 4,
                            timeEstimate: "\(estimatedDuration) min",
                            price: $0.price
                        )
                    } ?? VehicleSubOptionsView.RideOption(
                        id: 1,
                        text_id: "standard",
                        icon: "car-service-icon",
                        title: "Hezzni Standard",
                        subtitle: "Comfortable vehicles",
                        seats: 4,
                        timeEstimate: "3-8 min",
                        price: 25
                    ),
                    pickupLocation: pickupLocation,
                    destinationLocation: destinationLocation,
                    pickupDate: selectedDate,
                    onCancel: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .orderSummary
                        }
                    },
                    pickupLatitude: pickupLatitude,
                    pickupLongitude: pickupLongitude,
                    dropoffLatitude: destinationLatitude,
                    dropoffLongitude: destinationLongitude,
                    serviceTypeId: selectedService.id,
                    selectedRideOptionId: selectedRideOption?.id ?? 1,
                    estimatedPrice: selectedRideOption?.price ?? 0,
                    couponId: appliedCoupon?.couponId
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .reservationConfirmation {
                ReservationConfirmedScreen(
                    bottomSheetState: $bottomSheetState,
                    namespace: animations,
                    sheetHeight: $sheetHeight,
                    onContinue: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .initial
                            
                        }
                    },
                    onCancel: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .findingRide
                            
                        }
                    }
                )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else {
                locationSelectionContent
            }
        }
        .frame(height: sheetHeight)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
        .gesture(dragGesture)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bottomSheetState)
    }
    
    private var dragHandle: some View {
        Capsule()
            .fill(Color.gray.opacity(0.5))
            .frame(width: 40, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .gesture(dragGesture)
    }
    
    private var servicesScrollView: some View {
        Group {
            if servicesViewModel.isLoading {
                // Show shimmer effect while loading
                ServicesShimmerView(itemCount: 5)
            } else if let errorMessage = servicesViewModel.errorMessage {
                // Show error state
                VStack(spacing: 8) {
                    Text("Failed to load services")
                        .font(.poppins(.medium, size: 14))
                        .foregroundColor(.gray)
                    Text(errorMessage)
                        .font(.poppins(.regular, size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            await servicesViewModel.loadServices(force: true)
                        }
                    }
                    .font(.poppins(.medium, size: 14))
                    .foregroundColor(.hezzniGreen)
                }
                .padding()
            } else {
                // Show services from API
                HorizontalServicesScrollView(
                    items: filteredServices,
                    padding: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16),
                    backgroundColor: .white
                ) { service in
                    ServiceCardBuilder.createCard(
                        icon: service.iconAssetName,
                        title: getDisplayName(for: service.name),
                        isSelected: selectedService.id == service.id,
                        action: {
                            selectedService = SelectedService(from: service)
                        }
                    )
                }
            }
        }
        .onAppear {
            Task {
                await servicesViewModel.loadServices()
            }
        }
    }
    
    /// Get display name for service (shorter version for UI)
    private func getDisplayName(for name: String) -> String {
        switch name.lowercased() {
        case "car rides":
            return "Car"
        case "airport ride":
            return "Ride to Airport"
        case "city to city":
            return "City to City"
        case "group ride":
            return "Group Ride"
        default:
            return name
        }
    }
    
    /// Get icon for ride preference
    private func getIconForPreference(_ preference: String) -> String {
        switch preference.lowercased() {
        case "hezzni standard":
            return "car-service-icon"
        case "hezzni comfort":
            return "car-service-comfort-icon"
        case "hezzni xl":
            return "car-service-xl-icon"
        case "taxi":
            return "taxi-service-icon"
        case "motorcycle", "bike":
            return "motorcycle-service-icon"
        default:
            return "car-service-icon"
        }
    }
    
    // MARK: - Ride Summary View (Shows after selecting both pickup and destination)
    private var rideSummaryView: some View {
        VStack(spacing: 16) {

            // Pickup and Destination Cards
            VStack(spacing: 0){
                LocationCardView(
                    imageName: "pickup_ellipse",
                    heading: "Pickup",
                    content: pickupLocation,
                    roundedEdges: .top
                )
                
                LocationCardView(
                    imageName: "dropoff_ellipse",
                    heading: "Destination",
                    content: destinationLocation,
                    roundedEdges: .bottom
                )
            }
            .overlay(
                Line()
                .stroke(
                    Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.25),
                    style: StrokeStyle(lineWidth: 2, dash: [5,5])
                )
                .frame(height: 50)
                .offset(x: 25),
                alignment: .leading
            )
            
            // Continue Button
            PrimaryButton(
                text: "Continue",
                isEnabled: !isCalculatingPrice,
                isLoading: isCalculatingPrice,
                buttonColor: .hezzniGreen,
                icon: nil,
                action: calculateRidePrice
            )
            
            // Error message if any
            if let error = priceCalculationError {
                Text(error)
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    // MARK: - Ride Options View (Shows after API returns ride options)
    private var rideOptionsView: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Distance and Time Info
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        Text(String(format: "%.1f km", estimatedDistance))
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        Text("\(estimatedDuration) min")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Ride Options List
                VStack(spacing: 12) {
                    ForEach(rideOptions, id: \.id) { option in
                        RideOptionRow(
                            option: option,
                            isSelected: selectedRideOption?.id == option.id,
                            onSelect: {
                                selectedRideOption = option
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                
                // Confirm Ride Button
                PrimaryButton(
                    text: selectedRideOption != nil ? "Confirm \(selectedRideOption!.ridePreference) - \(String(format: "%.2f", selectedRideOption!.price)) MAD" : "Select a ride option",
                    isEnabled: selectedRideOption != nil,
                    isLoading: false,
                    buttonColor: .hezzniGreen,
                    icon: nil,
                    action: {
                        if selectedRideOption != nil {
                            // Proceed to finding ride
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                bottomSheetState = .findingRide
                            }
                        }
                    }
                )
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
        }
    }
    
    private var locationSelectionContent: some View {
        ScrollView {
            VStack(spacing: 10) {
                if bottomSheetState == .initial {
                    NowReservationToggleButton(isNowSelected: $isNowSelected)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                
//                // Pickup location
//                pickupLocationView
                if bottomSheetState == .initial || bottomSheetState == .journey{
                    VStack(spacing: 0){
                        // PICKUP LOCATION - Always visible
                        if isEditingPickup {
                            // Editable pickup location field
                            HStack(spacing: 12) {
                                Image("pickup_ellipse")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pickup")
                                        .font(Font.custom("Poppins", size: 12))
                                        .foregroundColor(Color(red: 0.59, green: 0.59, blue: 0.59))
                                    
                                    TextField("Enter pickup location", text: $searchText, onEditingChanged: { _ in
                                        showSuggestions = true
                                    })
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                }
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .background(.white)
                            .cornerRadius(8, corners: [.topLeft, .topRight])
                            .overlay(
                                RoundedCorner(radius: 8, corners: [.topLeft, .topRight])
                                    .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 1.5)
                            )
                        } else {
                            LocationCardView(
                                imageName: "pickup_ellipse",
                                heading: "Pickup",
                                content: pickupLocation,
                                onTap: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        showSuggestions = true
                                        isEditingPickup = true
                                        isEditingDestination = false
                                        sheetHeight = maxSheetHeight
                                        searchText = pickupLocation == "From?" ? "" : pickupLocation
                                        navigationState.hideBottomBar()
                                        bottomSheetState = .journey
                                    }
                                },
                                roundedEdges: .top
                            )
                        }
                        
                        // DESTINATION LOCATION - Always visible
                        if isEditingDestination {
                            // Editable destination location field
                            HStack(spacing: 12) {
                                Image("dropoff_ellipse")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Destination")
                                        .font(Font.custom("Poppins", size: 12))
                                        .foregroundColor(Color(red: 0.59, green: 0.59, blue: 0.59))
                                    
                                    TextField("Enter destination", text: $searchText, onEditingChanged: { _ in
                                        showSuggestions = true
                                    })
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                }
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .background(.white)
                            .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                            .overlay(
                                RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight])
                                    .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 1.5)
                            )
                        } else {
                            LocationCardView(
                                imageName: "dropoff_ellipse",
                                heading: "Destination",
                                content: destinationLocation,
                                onTap: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        showSuggestions = true
                                        isEditingPickup = false
                                        isEditingDestination = true
                                        sheetHeight = maxSheetHeight
                                        searchText = destinationLocation == "Where To?" ? "" : destinationLocation
                                        navigationState.hideBottomBar()
                                        bottomSheetState = .journey
                                    }
                                },
                                roundedEdges: .bottom
                            )
                        }
                    }
                    .overlay(
                        Line()
                        .stroke(
                            Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.25),
                            style: StrokeStyle(
                                lineWidth: 2,
                                dash: [5,5]
                            )
                        )
                        
                        .frame(height: 50)
                        .offset(x: 25)
                        ,alignment: .leading
                    )
                }
                
//                // Destination location
                if bottomSheetState == .initial {
                    PrimaryButton(
                        text: "Find a Ride",
                        isEnabled: true,
                        isLoading: false,
                        buttonColor: .blackwhite,
                        icon: "arrow.right",
                        action: findRide
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                //MARK: - Suggestions and Choose on Map
                if bottomSheetState != .initial {
                    VStack(alignment: .leading, spacing: 12) {
                        // Choose on Map button
                        if bottomSheetState != .chooseOnMap {
                            Button(action: {
                                handleChooseFromMap()
                            }) {
                                HStack(spacing: 15) {
                                    Image("choose_on_map_icon")
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Choose on Map")
                                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                                    }
                                    Spacer()
                                }
                                .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12))
                            }
                            
                            // Loading indicator
                            if isLoadingSuggestions {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.22, green: 0.65, blue: 0.33)))
                                    Spacer()
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Google Places Suggestions
                            if !placeSuggestions.isEmpty {
                                ForEach(placeSuggestions) { suggestion in
                                    Button(action: {
                                        handlePlaceSuggestionSelection(suggestion)
                                    }) {
                                        HStack(spacing: 12) {
                                            Image("suggestion_pin")
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(suggestion.mainText)
                                                    .font(.poppins(.medium, size: 14))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                if !suggestion.secondaryText.isEmpty {
                                                    Text(suggestion.secondaryText)
                                                        .font(.poppins(.regular, size: 12))
                                                        .foregroundColor(.gray)
                                                        .lineLimit(1)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                    }
                                    Divider()
                                }
                            } else if !isLoadingSuggestions && !searchText.isEmpty {
                                // Fallback to filtered static suggestions if no API results
                                ForEach(filteredSuggestions, id: \.self) { suggestion in
                                    Button(action: {
                                        handleSuggestionSelection(suggestion)
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(.gray)
                                            Text(suggestion)
                                                .font(.poppins(.regular, size: 14))
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                    }
                                    Divider()
                                }
                            }
                        } else {
                            // Confirm location button when choosing from map
                            PrimaryButton(
                                text: "Choose",
                                isEnabled: !isLoadingLocation,
                                isLoading: isLoadingLocation,
                                buttonColor: .hezzniGreen,
                                icon: "checkmark",
                                action: confirmLocationFromMap
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            // Custom bottom sheet overlay with dynamic height
            
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: bottomSheetState == .initial)
        .onChange(of: searchText) { newValue in
            // Debounced search for places
            if bottomSheetState == .journey && (isEditingPickup || isEditingDestination) {
                fetchPlacesSuggestions()
            }
        }
        
    }
    
    private var pickupLocationView: some View {
        HStack(spacing: 12) {
            locationIndicator(isStart: true)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pickup Location")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                TextField("Pickup Location", text: $pickupLocation, onEditingChanged: { editing in
                    handleEditingChange(editing: editing, isPickup: true)
                })
                .font(.system(size: 16))
                .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var destinationLocationView: some View {
        HStack(spacing: 12) {
            locationIndicator(isStart: false)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Destination")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                TextField("Destination", text: $destinationLocation, onEditingChanged: { editing in
                    handleEditingChange(editing: editing, isPickup: false)
                })
                .font(.system(size: 16))
                .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        
    }
    
    private func locationIndicator(isStart: Bool) -> some View {
        VStack {
            if isStart {
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 1, height: 20)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 1, height: 20)
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
            }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                let newHeight = max(minSheetHeight, sheetHeight - value.translation.height)
                sheetHeight = newHeight
            }
            .onEnded { value in
                isDragging = false
                snapSheetToPosition()
            }
    }
    
    // MARK: - Helper Methods
    
    private func fetchPlacesSuggestions() {
        print("🔍 fetchPlacesSuggestions called with searchText: '\(searchText)'")
        
        guard !searchText.isEmpty else {
            placeSuggestions = []
            print("🔍 Search text is empty, clearing suggestions")
            return
        }
        
        isLoadingSuggestions = true
        locationManager.fetchPlacesSuggestions(query: searchText) { suggestions in
            DispatchQueue.main.async {
                print("🔍 Received \(suggestions.count) suggestions")
                self.placeSuggestions = suggestions
                self.isLoadingSuggestions = false
            }
        }
    }
    
    private func handlePlaceSuggestionSelection(_ suggestion: PlaceSuggestion) {
        isLoadingSuggestions = true
        
        locationManager.fetchPlaceDetails(placeId: suggestion.placeId) { coordinate, address in
            DispatchQueue.main.async {
                isLoadingSuggestions = false
                
                let locationName = address ?? suggestion.mainText
                
                if let coordinate = coordinate {
                    if isEditingPickup {
                        pickupLocation = locationName
                        pickupLatitude = coordinate.latitude
                        pickupLongitude = coordinate.longitude
                        
                        // Now switch to editing destination
                        placeSuggestions = []
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isEditingPickup = false
                            isEditingDestination = true
                            searchText = ""
                        }
                    } else if isEditingDestination {
                        destinationLocation = locationName
                        destinationLatitude = coordinate.latitude
                        destinationLongitude = coordinate.longitude
                        
                        // Both locations set, proceed to calculate price
                        placeSuggestions = []
                        showSuggestions = false
                        isEditingPickup = false
                        isEditingDestination = false
                        proceedToPayment()
                    }
                }
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    private func handleSuggestionSelection(_ suggestion: String) {
        // For now, use the location manager's geocoding
        locationManager.geocodeAddress(suggestion) { coordinate in
            DispatchQueue.main.async {
                if let coordinate = coordinate {
                    if isEditingPickup {
                        pickupLocation = suggestion
                        pickupLatitude = coordinate.latitude
                        pickupLongitude = coordinate.longitude
                        
                        // Now switch to editing destination
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isEditingPickup = false
                            isEditingDestination = true
                            searchText = ""
                        }
                    } else if isEditingDestination {
                        destinationLocation = suggestion
                        destinationLatitude = coordinate.latitude
                        destinationLongitude = coordinate.longitude
                        
                        // Both locations set, proceed to calculate price
                        showSuggestions = false
                        isEditingPickup = false
                        isEditingDestination = false
                        proceedToPayment()
                    }
                } else {
                    // Fallback if geocoding fails
                    if isEditingPickup {
                        pickupLocation = suggestion
                        isEditingPickup = false
                        isEditingDestination = true
                        searchText = ""
                    } else if isEditingDestination {
                        destinationLocation = suggestion
                        showSuggestions = false
                        isEditingPickup = false
                        isEditingDestination = false
                        bottomSheetState = .initial
                        navigationState.showBottomBar()
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            sheetHeight = midSheetHeight
                        }
                    }
                }
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    private func handleChooseFromMap() {
        // Track which location is being selected based on current editing state
        isSelectingPickupFromMap = isEditingPickup || (!isEditingDestination && pickupLatitude == 0)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bottomSheetState = .chooseOnMap
            sheetHeight = minSheetHeight + 50  // Slightly taller to show the Choose button better
            showSuggestions = false
            placeSuggestions = []
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func confirmLocationFromMap() {
        isLoadingLocation = true
        
        // Get the center coordinate of the map
        let centerCoordinate = mapView.camera.target
        
        // Use Google Geocoding API for reverse geocoding (more reliable)
        reverseGeocodeWithGoogle(coordinate: centerCoordinate) { placeName in
            DispatchQueue.main.async {
                let locationName = placeName ?? "Selected Location"
                
                if self.isSelectingPickupFromMap {
                    // Setting pickup location
                    self.pickupLocation = locationName
                    self.pickupLatitude = centerCoordinate.latitude
                    self.pickupLongitude = centerCoordinate.longitude
                    
                    self.isLoadingLocation = false
                    
                    // Now switch to destination selection
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        self.bottomSheetState = .journey
                        self.isEditingPickup = false
                        self.isEditingDestination = true
                        self.isSelectingPickupFromMap = false
                        self.sheetHeight = self.maxSheetHeight
                        self.searchText = ""
                    }
                } else {
                    // Setting destination location
                    self.destinationLocation = locationName
                    self.destinationLatitude = centerCoordinate.latitude
                    self.destinationLongitude = centerCoordinate.longitude
                    
                    self.isLoadingLocation = false
                    self.isEditingPickup = false
                    self.isEditingDestination = false
                    
                    // Both locations set, proceed to show route
                    self.proceedToPayment()
                }
            }
        }
    }
    
    // Google Geocoding API for reverse geocoding
    private func reverseGeocodeWithGoogle(coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinate.latitude),\(coordinate.longitude)&key=AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let formattedAddress = firstResult["formatted_address"] as? String {
                    // Get a shorter address if available
                    if let addressComponents = firstResult["address_components"] as? [[String: Any]] {
                        var shortAddress = ""
                        for component in addressComponents {
                            if let types = component["types"] as? [String] {
                                if types.contains("route") || types.contains("street_address") {
                                    if let name = component["long_name"] as? String {
                                        shortAddress = name
                                        break
                                    }
                                }
                            }
                        }
                        if !shortAddress.isEmpty {
                            // Add locality if available
                            for component in addressComponents {
                                if let types = component["types"] as? [String],
                                   types.contains("locality"),
                                   let locality = component["long_name"] as? String {
                                    shortAddress += ", \(locality)"
                                    break
                                }
                            }
                            completion(shortAddress)
                            return
                        }
                    }
                    completion(formattedAddress)
                } else {
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
    
    private func handleEditingChange(editing: Bool, isPickup: Bool) {
        isEditingPickup = editing && isPickup
        isEditingDestination = editing && !isPickup
        showSuggestions = editing
        
        if isPickup {
            searchText = pickupLocation
        } else {
            searchText = destinationLocation
        }
        
        // Expand sheet when editing
        if editing {
            withAnimation(.spring()) {
                sheetHeight = maxSheetHeight
            }
        }
    }
    
    private func snapSheetToPosition() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if bottomSheetState != .initial {
                if sheetHeight > (maxSheetHeight + midSheetHeight) / 2 {
                    sheetHeight = maxSheetHeight
                }
                else if sheetHeight > (midSheetHeight + minSheetHeight) / 2 {
                    sheetHeight = midSheetHeight
                } else {
                    sheetHeight = minSheetHeight
                }
            } else {
                if sheetHeight > (midSheetHeight + minSheetHeight) / 2 {
                    sheetHeight = midSheetHeight
                }
            }
            
        }
    }
    
    private func updateCameraPosition(location: CLLocation?) {
        if let location = location {
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 14)
            cameraPosition = camera
            mapView.animate(to: camera)
        }
    }
    
    // Set pickup location from user's current location
    private func setPickupFromCurrentLocation(location: CLLocation) {
        let coordinate = location.coordinate
        
        // Store coordinates immediately
        pickupLatitude = coordinate.latitude
        pickupLongitude = coordinate.longitude
        
        // Reverse geocode to get address
        reverseGeocodeWithGoogle(coordinate: coordinate) { placeName in
            DispatchQueue.main.async {
                if let placeName = placeName {
                    self.pickupLocation = placeName
                } else {
                    self.pickupLocation = "Current Location"
                }
            }
        }
    }
    
    private func findRide() {
        // Hide bottom bar when navigating away
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showSuggestions = true
            navigationState.hideBottomBar()
            bottomSheetState = .journey
            sheetHeight = maxSheetHeight
            
            // If pickup location is already set (from current location), skip to destination
            if pickupLatitude != 0 && pickupLongitude != 0 && pickupLocation != "From?" {
                isEditingPickup = false
                isEditingDestination = true
                searchText = ""
            } else {
                isEditingPickup = true
                isEditingDestination = false
                searchText = pickupLocation == "From?" ? "" : pickupLocation
            }
        }
    }
    
    private func proceedToPayment() {
        // Show ride summary first
        guard !pickupLocation.isEmpty, !destinationLocation.isEmpty else {
            priceCalculationError = "Please select both pickup and destination locations"
            return
        }
        
        // Calculate approximate distance using Haversine formula
        let pickupCoord = CLLocation(latitude: pickupLatitude, longitude: pickupLongitude)
        let dropoffCoord = CLLocation(latitude: destinationLatitude, longitude: destinationLongitude)
        let distanceInMeters = pickupCoord.distance(from: dropoffCoord)
        let distanceInKm = distanceInMeters / 1000.0
        
        // Set initial estimates (will be updated by API)
        estimatedDistance = distanceInKm
        estimatedDuration = Int(distanceInKm * 3) // Rough estimate: 3 min per km
        
        // Draw route on map
        drawRoute(
            from: CLLocationCoordinate2D(latitude: pickupLatitude, longitude: pickupLongitude),
            to: CLLocationCoordinate2D(latitude: destinationLatitude, longitude: destinationLongitude)
        )
        
        // Show ride summary
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bottomSheetState = .rideSummary
            sheetHeight = minSheetHeight + 120
        }
    }
    
    private func calculateRidePrice() {
        isCalculatingPrice = true
        priceCalculationError = nil
        
        Task {
            do {
                let response = try await APIService.shared.calculateRidePrice(
                    pickupLatitude: pickupLatitude,
                    pickupLongitude: pickupLongitude,
                    pickupAddress: pickupLocation,
                    dropoffLatitude: destinationLatitude,
                    dropoffLongitude: destinationLongitude,
                    dropoffAddress: destinationLocation,
                    passengerServiceId: selectedService.id  // Use selected service ID
                )
                
                DispatchQueue.main.async {
                    self.rideOptions = response.data.options
                    self.estimatedDistance = response.data.distance
                    self.estimatedDuration = response.data.estimatedDuration
                    self.isCalculatingPrice = false
                    
                    // Show ride options
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        if isNowSelected {
                            bottomSheetState = .nowRide
                        }
                        else {
                            bottomSheetState = .reservation
                        }
                        sheetHeight = maxSheetHeight
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.priceCalculationError = "Failed to calculate ride price: \(error.localizedDescription)"
                    self.isCalculatingPrice = false
                }
            }
        }
    }
    
    private func drawRoute(from pickupCoord: CLLocationCoordinate2D, to dropoffCoord: CLLocationCoordinate2D) {
        // Remove existing polyline
        if let polyline = routePolyline {
            polyline.map = nil
        }
        
        // Clear existing markers
        mapView.clear()
        
        // Add pickup marker
        let pickupMarker = GMSMarker()
        pickupMarker.position = pickupCoord
        pickupMarker.title = "Pickup"
        pickupMarker.snippet = pickupLocation
        pickupMarker.icon = GMSMarker.markerImage(with: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0))
        pickupMarker.map = mapView
        
        // Add destination marker
        let destinationMarker = GMSMarker()
        destinationMarker.position = dropoffCoord
        destinationMarker.title = "Destination"
        destinationMarker.snippet = destinationLocation
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
        destinationMarker.map = mapView
        
        // Fetch actual directions from Google Directions API
        locationManager.fetchDirections(from: pickupCoord, to: dropoffCoord) { [self] path, distanceText, durationText in
            DispatchQueue.main.async {
                if let path = path {
                    // Draw the actual route
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                    polyline.map = self.mapView
                    
                    self.routePolyline = polyline
                    
                    // Animate camera to show the route
                    let bounds = GMSCoordinateBounds(path: path)
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
                    self.mapView.animate(with: update)
                } else {
                    // Fallback to straight line if directions API fails
                    let fallbackPath = GMSMutablePath()
                    fallbackPath.add(pickupCoord)
                    fallbackPath.add(dropoffCoord)
                    
                    let polyline = GMSPolyline(path: fallbackPath)
                    polyline.strokeWidth = 4
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                    polyline.map = self.mapView
                    
                    self.routePolyline = polyline
                    
                    // Animate camera to show both points
                    let bounds = GMSCoordinateBounds(path: fallbackPath)
                    let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
                    self.mapView.animate(with: update)
                }
            }
        }
    }
    private func configureMap() {
            // Additional map configuration
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: sheetHeight, right: 0)
        }
}




struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
// Location Manager


//// Notification Button
//struct NotificationButton1: View {
//    var body: some View {
//        Button(action: {}) {
//            Image(systemName: "bell.fill")
//                .foregroundColor(.primary)
//                .padding(8)
//                .background(Color.gray.opacity(0.2))
//                .clipShape(Circle())
//        }
//    }
//}

// MARK: - Ride Option Row Component
struct RideOptionRow: View {
    let option: CalculateRidePriceResponse.RideOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Ride icon
                Image(systemName: getIconForPreference(option.ridePreferenceKey))
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : Color(red: 0.22, green: 0.65, blue: 0.33))
                    .frame(width: 50, height: 50)
                    .background(isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.1))
                    .cornerRadius(12)
                
                // Option details
                VStack(alignment: .leading, spacing: 4) {
                    Text(option.ridePreference)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    
                    Text(option.description)
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.59, green: 0.59, blue: 0.59))
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.2f", option.price))
                        .font(Font.custom("Poppins", size: 18).weight(.bold))
                        .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    Text("MAD")
                        .font(Font.custom("Poppins", size: 10))
                        .foregroundColor(Color(red: 0.59, green: 0.59, blue: 0.59))
                }
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.92, green: 0.92, blue: 0.92), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: Color.black.opacity(isSelected ? 0.1 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getIconForPreference(_ key: String) -> String {
        switch key {
        case "COMFORT": return "car.fill"
        case "STANDARD": return "car"
        case "ECONOMY": return "car.2.fill"
        case "PREMIUM": return "bolt.car.fill"
        default: return "car.fill"
        }
    }
}

// Service model
struct Service: Identifiable {
    let id: String
    let icon: String
    let title: String
}
// Horizontal service card
struct ServiceCardHorizontal: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                
                Text(title)
                    .font(.poppins(.medium, size: 12))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 112, height: 130)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white)
                    .shadow(color: Color(hex: "#04060F").opacity(0.06), radius: 10, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? .hezzniGreen : .clear, lineWidth: 2)
            )
        }
    }
}

//// Swift
//#Preview {
//    struct HomeScreenPreviewWrapper: View {
//        @State private var selectedService = SelectedService.defaultService
//        @State private var isNowSelected = true
//        @State private var pickupLocation = "From?"
//        @State private var destinationLocation = "Where To?"
//        @State private var bottomSheetState = BottomSheetState.initial
//
//        var body: some View {
//            HomeScreen(
//                selectedService: $selectedService,
//                isNowSelected: $isNowSelected,
//                pickupLocation: $pickupLocation,
//                destinationLocation: $destinationLocation,
//                bottomSheetState: $bottomSheetState
//            )
//            .environmentObject(NavigationStateManager())
//        }
//    }
//    return HomeScreenPreviewWrapper()
//}
