//
//  HomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/16/25.
//

import SwiftUI
import UIKit
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
    case driverEnRoute    // New state: Driver accepted, showing driver on map heading to pickup
    case rideProcess
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
    
    // MARK: - Driver Tracking (for driverEnRoute state)
    @StateObject private var socketManager = RideSocketManager.shared
    @State private var driverMarker: GMSMarker?
    @State private var driverRoutePolyline: GMSPolyline?
    
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
    
    @State private var showRideNotFound: Bool = false
    @State private var showTripComplete: Bool = false
    @State private var showPassengerRating: Bool = false

    // Country picker presentation (full-screen overlay)
    @State private var showCountryPicker: Bool = false
    @State private var selectedCountryForDelivery: Country = .morocco
    
    @State var selectedRideInformation: CalculateRidePriceResponse.RideOption //

    // Filtered services (excluding Rental Car and Reservation)
    private var filteredServices: [PassengerService] {
        servicesViewModel.services.filter { service in
            let name = service.name.lowercased()
            return name != "rental car" && name != "reservation"
        }
    }
    
    // Google Places autocomplete suggestions
    @State private var placeSuggestions: [PlaceSuggestion] = []
    @State private var locationHistory: [PlaceSuggestion] = []
    @State private var isLoadingSuggestions = false
    
    // Track which location is being selected from map (pickup or destination)
    @State private var isSelectingPickupFromMap = true
    @State private var selectedMapAddress: String = ""
    @State private var hasSetInitialPickupLocation = false
    @State private var hasSetInitialCameraPosition = false
    
    @State private var selectedPaymentMethod = 0
    private let paymentMethods: [Card] = [
        .init(iconName: "cash_on_deliver_icon", title: "Cash Payment", subtitle: "pay the driver directly", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "hezzni_wallet_icon", title: "Hezzni Wallet", subtitle: "Pay with Hezzni balance", badge: "55.66 MAD", cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "visa", title: "Visa Card", subtitle: "", badge: nil, cardNumber: "**** **** **** 2345", isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "mastercard", title: "Mastercard", subtitle: "", badge: nil, cardNumber: "**** **** **** 2345", isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: nil, title: "Add Credit / Debit Card", subtitle: "Add Visa or Mastercard for trips", badge: nil, cardNumber: nil, isAddCard: true, cardHolder: nil, expiry: nil)
    ]
    
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
    
        // Default to Marrakech, Morocco
        let defaultLocation = CLLocationCoordinate2D(latitude: 31.6295, longitude: -7.9811)
        _cameraPosition = State(initialValue: GMSCameraPosition.camera(withTarget: defaultLocation, zoom: 14))
        // Line 136, inside HomeScreen.init
        _selectedRideInformation = State(initialValue: CalculateRidePriceResponse.RideOption(
            id: 0,
            text_id: "standard",
            icon: "",
            title: "Standard",
            subtitle: "",
            seats: 4,
            timeEstimate: "10 min",
            ridePreference: "Standard",           // <-- Add this
            ridePreferenceKey: "STANDARD",        // <-- Add this
            description: "Standard ride option", // <-- Add this
            price: 100,
            
        ))
    }
    
    
    @ViewBuilder
    private var pickerToShow: some View {
        if showSchedulePicker {
            ZStack {
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
        } else {
            EmptyView()
        }
    }
    
    private var headerView: some View {
        ZStack(alignment: .bottom) {
            // Map view with overlay
            mapContentView
                .onAppear {
                    configureMap()
                }

            // GPS button above the sheet (show in initial, journey, chooseOnMap, rideSummary states)
            if bottomSheetState == .initial || bottomSheetState == .journey || bottomSheetState == .chooseOnMap || bottomSheetState == .rideSummary || bottomSheetState == .rideOptions {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            centerOnCurrentLocation()
                        }) {
                            circularButton(icon: "gps_location_icon")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, sheetHeight + 16)
                }
            }
            
            VStack{
                Spacer()
                // Custom draggable sheet
                draggableSheet
            }
        }
    }
    
    var body: some View {
        bodyContent
    }
    
    // MARK: - Body broken into sub-expressions
    private var navigationContent: some View {
        NavigationStack(path: $navigationState.path) {
            ZStack {
                // Home content
                headerView
                    .edgesIgnoringSafeArea(.bottom)

                // Notification overlay
                if isShowingNotifications {
                    NotificationScreen(showNotification: $isShowingNotifications, bottomSheetState: bottomSheetState)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(10)
                }
            }
        }
    }
    
    private var bodyContent: some View {
        navigationContent
            .overlay { pickerToShow }
            .overlay { showCountryPickerFunction() }
            .overlay { showRidePickerFunction() }
            .onAppear {
                locationManager.startUpdatingLocation()
                if bottomSheetState == .initial {
                    navigationState.showBottomBar()
                }
                handleBodyOnAppear()
            }
            .onChange(of: locationManager.currentLocation) { location in
                handleLocationChange(location)
            }
            .onChange(of: mapView.camera.target) { handleCameraTargetChange($0) }
            .onChange(of: bottomSheetState) { handleBottomSheetStateChange($0) }
            .onChange(of: socketManager.driverLocation) { handleDriverLocationChange($0) }
            .onChange(of: socketManager.driverInfo) { _ in handleDriverInfoChange() }
            .onChange(of: socketManager.isRideStarted) { started in
                if started && bottomSheetState == .driverEnRoute {
                    handleRideStarted()
                }
            }
            .onChange(of: socketManager.currentRideStatus) { status in
                if status == .rideCompleted {
                    handleRideCompleted()
                }
                // Handle ride cancellation - return to initial state
                if status == .rideCancelled {
                    handleRideCancelled()
                }
            }
            .fullScreenCover(isPresented: $showTripComplete) {
                TripCompleteScreen(
                    distance: String(format: "%.1f km", estimatedDistance),
                    totalTime: "\(estimatedDuration) min",
                    price: String(format: "%.2f MAD", selectedRideOption?.price ?? 0),
                    driverImage: socketManager.driverInfo?.driver.imageUrl ?? "profile_placeholder",
                    driverName: socketManager.driverInfo?.driver.name ?? "Driver",
                    driverTrips: socketManager.driverInfo?.driver.totalTrips ?? 0,
                    driverRating: Double(socketManager.driverInfo?.driver.averageRating ?? "5.0") ?? 5.0,
                    pickupLocation: pickupLocation,
                    dropoffLocation: destinationLocation,
                    onRate: {
                        showTripComplete = false
                        showPassengerRating = true
                    },
                    onBookAnother: {
                        showTripComplete = false
                        resetAfterRideCompletion()
                    }
                )
            }
            .sheet(isPresented: $showPassengerRating) {
                PassengerRatingSheet(
                    driverName: socketManager.driverInfo?.driver.name ?? "Driver",
                    onSubmit: { rating, comment, tags in
                        // Submit review to API using rideRequestId
                        if let rideRequestId = socketManager.currentRideRequestId {
                            Task {
                                try? await APIService.shared.submitDriverReview(
                                    rideRequestId: rideRequestId,
                                    rating: rating,
                                    comment: comment,
                                    tags: tags
                                )
                            }
                        } else if let rideIdStr = socketManager.currentRideId, let rideId = Int(rideIdStr) {
                            // Fallback to currentRideId if rideRequestId not available
                            Task {
                                try? await APIService.shared.submitDriverReview(
                                    rideRequestId: rideId,
                                    rating: rating,
                                    comment: comment,
                                    tags: tags
                                )
                            }
                        }
                        showPassengerRating = false
                        resetAfterRideCompletion()
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationCornerRadius(35)
                .presentationDragIndicator(.hidden)
            }
    }
    
    
    private func handleLocationChange(_ location: CLLocation?) {
        if !hasSetInitialCameraPosition && bottomSheetState != .chooseOnMap {
            hasSetInitialCameraPosition = true
            updateCameraPosition(location: location)
        }
        if !hasSetInitialPickupLocation, let location = location {
            hasSetInitialPickupLocation = true
            setPickupFromCurrentLocation(location: location)
        }
    }
    
    private func handleBodyOnAppear() {
        if bottomSheetState != .initial {
            sheetHeight = maxSheetHeight
        }
    }
    
    private func handleCameraTargetChange(_ newCenter: CLLocationCoordinate2D) {
        if bottomSheetState == .chooseOnMap {
            reverseGeocodeWithGoogle(coordinate: newCenter) { street, address in
                DispatchQueue.main.async {
                    selectedMapAddress = street ?? ""
                }
            }
        }
    }
    
    private func handleBottomSheetStateChange(_ newState: BottomSheetState) {
        if newState == .driverEnRoute {
            drawDriverOnMap()
        } else {
            clearDriverTracking()
        }
    }
    
    private func handleDriverLocationChange(_ newLocation: DriverLocationUpdate?) {
        if bottomSheetState == .driverEnRoute, let location = newLocation {
            updateDriverMarkerPosition(
                latitude: location.latitude,
                longitude: location.longitude
            )
        }
    }
    private func handleDriverInfoChange() {
            if bottomSheetState == .driverEnRoute {
                drawDriverOnMap()
            }
        }
    @ViewBuilder
    func showCountryPickerFunction() -> some View {
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
    @ViewBuilder
    func showRidePickerFunction() -> some View {
        if showRideNotFound {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    showRideNotFound = false
                }

            VStack {
                Spacer()

                VStack(spacing: 0) {
                    HStack {
                        Button("Cancel") {
                            showRideNotFound = false
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
    
    // MARK: - Subviews
    
    private var mapContentView: some View {
        ZStack(alignment: .top) {
            GoogleMapView(mapView: $mapView, cameraPosition: $cameraPosition)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            // Move Google UI elements behind the bottom sheet
                            mapView.padding = UIEdgeInsets(
                                top: 0,
                                left: 20,
                                bottom: 30,
                                right: 0
                            )
                        }
            // Center marker when choosing from map
            if bottomSheetState == .chooseOnMap {
                VStack {
                    Spacer()
                    VStack(spacing: 4) {
                        VStack(alignment: .leading, spacing: 2) {
                                Text(isSelectingPickupFromMap ? "Pickup" : "Destination")
                                    .font(Font.custom("Poppins", size: 10))
                                    .lineSpacing(12)
                                    .foregroundColor(Color(red: 1, green: 1, blue: 1).opacity(0.75))
                            
                            if !selectedMapAddress.isEmpty {
                                Text(selectedMapAddress)
                                    .font(Font.custom("Poppins", size: 13))
                                    .lineSpacing(14)
                                    .foregroundColor(.white)
                            }
                               
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .cornerRadius(8)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        
                        // Custom map pin from assets
                        Image("map_pin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 35)
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    Spacer()
                }
                .padding(.bottom, 125)
            }
            
            // Distance/Duration info card when showing route
            if bottomSheetState == .rideSummary || bottomSheetState == .rideOptions {
                VStack {
                    Spacer()
                        .frame(height: 100)
                    
//                    // Route info card
//                    HStack(spacing: 0) {
//                        // Distance
//                        HStack(spacing: 4) {
//                            Text(String(format: "%.1f", estimatedDistance))
//                                .font(Font.custom("Poppins", size: 16).weight(.bold))
//                                .foregroundColor(.white)
//                            Text("KM")
//                                .font(Font.custom("Poppins", size: 12).weight(.medium))
//                                .foregroundColor(.white)
//                        }
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 8)
//                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
//                        
//                        // Duration
//                        HStack(spacing: 4) {
//                            Text("\(estimatedDuration)")
//                                .font(Font.custom("Poppins", size: 16).weight(.bold))
//                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
//                            Text("min")
//                                .font(Font.custom("Poppins", size: 12).weight(.medium))
//                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
//                        }
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 8)
//                        .background(Color.white)
//                        
//                        // Destination
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text("Destination")
//                                .font(Font.custom("Poppins", size: 10))
//                                .foregroundColor(.gray)
//                            Text(destinationLocation)
//                                .font(Font.custom("Poppins", size: 12).weight(.medium))
//                                .foregroundColor(.black)
//                                .lineLimit(1)
//                        }
//                        .padding(.horizontal, 10)
//                        .padding(.vertical, 8)
//                        .frame(maxWidth: 150)
//                        .background(Color.white)
//                    }
//                    .cornerRadius(8)
//                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
//                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
//            // Driver ETA card when driver is en route
//            if bottomSheetState == .driverEnRoute {
//                driverETACardView
//            }
            
            VStack(spacing: 0) {
                HStack {
//                    greetingText
                    if bottomSheetState == .chooseOnMap {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                bottomSheetState = .journey
                                sheetHeight = maxSheetHeight
                            }
                            
                        }) {
                            Image(systemName: "arrow.left")
                                .foregroundStyle(.foreground)
                                .padding()
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .stroke(.white200, lineWidth: 1)
                                )
                        }
                    }
                    Spacer()
                    if sheetHeight <= maxSheetHeight - 10 {
                        NotificationButton(action: {
                            navigationState.hideBottomBar()
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                isShowingNotifications = true
                            }
                        })
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
//                .background(.white)
                Spacer()
            }
        }
        
        
    }
    
//    // MARK: - Driver ETA Card View (extracted to reduce body complexity)
//    @ViewBuilder
//    private var driverETACardView: some View {
//        if let driverInfo = socketManager.driverInfo {
//            VStack {
//                Spacer()
//                    .frame(height: 100)
//                
//                // Driver ETA info card
//                HStack(spacing: 0) {
//                    // ETA
//                    HStack(spacing: 4) {
//                        Text("\(driverInfo.estimatedArrivalMinutes)")
//                            .font(Font.custom("Poppins", size: 16).weight(.bold))
//                            .foregroundColor(.white)
//                        Text("min")
//                            .font(Font.custom("Poppins", size: 12).weight(.medium))
//                            .foregroundColor(.white)
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
//                    
//                    // Distance
//                    HStack(spacing: 4) {
//                        Text(driverInfo.distanceToPickup)
//                            .font(Font.custom("Poppins", size: 14).weight(.medium))
//                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 8)
//                    .background(Color.white)
//                    
//                    // Status
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("Driver arriving")
//                            .font(Font.custom("Poppins", size: 10))
//                            .foregroundColor(.gray)
//                        Text(driverInfo.driver.vehicle.plateNumber)
//                            .font(Font.custom("Poppins", size: 12).weight(.medium))
//                            .foregroundColor(.black)
//                            .lineLimit(1)
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 8)
//                    .frame(maxWidth: 150)
//                    .background(Color.white)
//                }
//                .cornerRadius(8)
//                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
//                
//                Spacer()
//            }
//            .padding(.horizontal, 16)
//        }
//    }
//   
    
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
    private var reservationView: some View {
        GenericRideDetailScreen(
            isReservation: !isNowSelected,
            pickup: pickupLocation,
            destination: destinationLocation,
            bottomSheetState: $bottomSheetState,
            rideOptions: rideOptions,
            selectedRideOption: $selectedRideInformation,
            namespace: animations,
            appliedCoupon: $appliedCoupon,
            selectedService: $selectedService,
            showSchedulePicker: $showSchedulePicker,
            selectedDate: $selectedDate,
            showCountryPicker: $showCountryPicker
        )
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
    //MARK: - Draggable Sheet
    private var draggableSheet: some View {
        VStack(spacing: 0) {
            // Drag handle
            if !sheetWithNoDrag() {
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
            if bottomSheetState == .reservation || bottomSheetState == .nowRide || bottomSheetState == .deliveryService {
                reservationView
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
                    namespace: animations,
                    selectedMethodIndex: $selectedPaymentMethod,
                    methods: paymentMethods,
                    
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .orderSummary {
                PaymentConfirmationScreen(
                    rideInfo: selectedRideInformation,
                    pickupLocation: pickupLocation,
                    destinationLocation: destinationLocation,
                    isReservation: !isNowSelected,
                    bottomSheetState: $bottomSheetState,
                    paymentMethod: paymentMethods[selectedPaymentMethod],
                    namespace: animations,
                    onContinue: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .findingRide
                            sheetHeight = UIScreen.main.bounds.height * 0.65
                        }
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .findingRide {
                FindingRideScreen(
                    rideInfo: selectedRideInformation,
                    bottomSheetState: $bottomSheetState,
                    namespace: animations,
                    sheetHeight: $sheetHeight,
                    isReservation: !isNowSelected,
                    vehicle: selectedRideInformation,
                    pickupLocation: pickupLocation,
                    destinationLocation: destinationLocation,
                    pickupDate: selectedDate,
                    onCancel: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .orderSummary
                            sheetHeight = midSheetHeight + 200
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
            else if bottomSheetState == .driverEnRoute {
                // Driver accepted the ride, showing driver info in bottom sheet
                // Map shows driver marker and route to pickup using existing GoogleMapView
                
                DriverEnRouteBottomSheet(
                    bottomSheetState: $bottomSheetState,
                    sheetHeight: $sheetHeight,
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
            else if bottomSheetState == .rideProcess {
                RideProcessScreen()
            }
            else {
                locationSelectionContent
            }
        }
        .frame(height: sheetHeight)
        .background(bottomSheetState == .driverEnRoute ? Color.hezzniGreen : bottomSheetState == .chooseOnMap ? .clear : Color.white)
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
        return name
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
//                            .overlay(
//                                RoundedCorner(radius: 8, corners: [.topLeft, .topRight])
//                                    .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 1.5)
//                            )
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
//                            .overlay(
//                                RoundedCorner(radius: 8, corners: [.bottomLeft, .bottomRight])
//                                    .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 1.5)
//                            )
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
                                    fetchPlacesSuggestions()
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
                            } else if searchText.isEmpty && !locationHistory.isEmpty {
                                // Show history when not typing
                                Text("Recent Places")
                                    .font(.poppins(.medium, size: 13))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 12)
                                    .padding(.top, 4)
                                
                                ForEach(locationHistory) { historyItem in
                                    Button(action: {
                                        handlePlaceSuggestionSelection(historyItem)
                                    }) {
                                        HStack(spacing: 12) {
                                            Image("history-icon")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(historyItem.mainText)
                                                    .font(.poppins(.medium, size: 14))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                if !historyItem.secondaryText.isEmpty {
                                                    Text(historyItem.secondaryText)
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
                .onChange(of: pickupLocation) { newValue in
                    // Sync searchText when pickup location changes while editing
                    if isEditingPickup {
                        searchText = newValue
                        print("🔍 Pickup location changed: '\(newValue)' - triggering search")
                    }
                }
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
                .onChange(of: destinationLocation) { newValue in
                    // Sync searchText when destination location changes while editing
                    if isEditingDestination {
                        searchText = newValue
                        print("🔍 Destination location changed: '\(newValue)' - triggering search")
                    }
                }
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
                if sheetWithNoDrag() {
                    sheetHeight = sheetHeight
                }
                else {
                    isDragging = true
                    let newHeight = max(minSheetHeight, sheetHeight - value.translation.height)
                    sheetHeight = newHeight
                }
            }
            .onEnded { value in
                if sheetWithNoDrag() {
                    sheetHeight = sheetHeight
                }else{
                    isDragging = false
                    snapSheetToPosition()
                }
            }
    }
    func sheetWithNoDrag() -> Bool {
        return bottomSheetState == .chooseOnMap || bottomSheetState == .findingRide || bottomSheetState == .rideSummary || bottomSheetState == .driverEnRoute
    }
    // MARK: - Helper Methods
    
    private func fetchPlacesSuggestions() {
        print("🔍 fetchPlacesSuggestions called with searchText: '\(searchText)'")
        
        guard !searchText.isEmpty else {
            placeSuggestions = []
            locationHistory = SearchHistoryManager.shared.getHistory()
            print("🔍 Search text is empty, loading \(locationHistory.count) history items")
            return
        }
        
        // Clear history when typing
        locationHistory = []
        
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
        // Save to history immediately
        SearchHistoryManager.shared.saveSuggestion(suggestion)
        
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
            sheetHeight = minSheetHeight - 45
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
        reverseGeocodeWithGoogle(coordinate: centerCoordinate) { street, placeName in
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
    
    // Swift
    private func reverseGeocodeWithGoogle(
        coordinate: CLLocationCoordinate2D,
        completion: @escaping (_ streetAddress: String?, _ formattedAddress: String?) -> Void
    ) {
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinate.latitude),\(coordinate.longitude)&key=AIzaSyAGlfVLO31MsYNRfiJooK3-e38vAVkkij0"
        
        guard let url = URL(string: urlString) else {
            completion(nil, nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(nil, nil)
                return
            }
            
            guard let data = data else {
                completion(nil, nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]],
                   let firstResult = results.first,
                   let formattedAddress = firstResult["formatted_address"] as? String {
                    var streetAddress: String? = nil
                    if let addressComponents = firstResult["address_components"] as? [[String: Any]] {
                        for component in addressComponents {
                            if let types = component["types"] as? [String],
                               (types.contains("route") || types.contains("street_address")),
                               let name = component["long_name"] as? String {
                                streetAddress = name
                                break
                            }
                        }
                        if let street = streetAddress {
                            // Optionally add locality
                            for component in addressComponents {
                                if let types = component["types"] as? [String],
                                   types.contains("locality"),
                                   let locality = component["long_name"] as? String {
                                    streetAddress = "\(street), \(locality)"
                                    break
                                }
                            }
                        }
                    }
                    completion(streetAddress, formattedAddress)
                } else {
                    completion(nil, nil)
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(nil, nil)
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
            // Load history immediately
            locationHistory = SearchHistoryManager.shared.getHistory()
            fetchPlacesSuggestions()
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
            }
            else {
                if sheetHeight > (midSheetHeight + minSheetHeight) / 2 {
                    sheetHeight = midSheetHeight
                }
                else {
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
    
    /// Center the map on the user's current location and update pickup
    private func centerOnCurrentLocation() {
        if let location = locationManager.currentLocation {
            print("📍 Centering map on current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 16)
            cameraPosition = camera
            mapView.animate(to: camera)
            
            // Also update pickup location
            setPickupFromCurrentLocation(location: location)
        } else {
            // Request location update if not available
            print("📍 Current location not available, requesting update...")
            locationManager.startUpdatingLocation()
        }
    }
    
    // Set pickup location from user's current location
    private func setPickupFromCurrentLocation(location: CLLocation) {
        let coordinate = location.coordinate
        
        // Store coordinates immediately
        pickupLatitude = coordinate.latitude
        pickupLongitude = coordinate.longitude
        
        // Reverse geocode to get address
        reverseGeocodeWithGoogle(coordinate: coordinate) { street, placeName in
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
            
            // Load history for immediate display
            locationHistory = SearchHistoryManager.shared.getHistory()
            
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
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                showSchedulePicker = true
                                bottomSheetState = .reservation
                            }
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
    private func createPickupMarkerView(title: String, subtitle: String, color: UIColor, pinImage: UIImage?) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 60))
        
        // Info card
        let cardView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 4
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.frame = CGRect(x: 8, y: 6, width: 104, height: 28)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 12)
        titleLabel.textColor = color
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 10)
        subtitleLabel.textColor = .darkGray
        subtitleLabel.numberOfLines = 1
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        cardView.addSubview(stackView)
        
        // Pin icon below
        let pinImageView = UIImageView(frame: CGRect(x: 52, y: 40, width: 16, height: 20))
        if let pinImage = pinImage {
            pinImageView.image = pinImage
        }
        pinImageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(cardView)
        containerView.addSubview(pinImageView)
        
        return containerView
    }

    private func createDestinationMarkerView(title: String, subtitle: String, distance: String, duration: String, color: UIColor, pinImage: UIImage?) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 192, height: 60))
        
        // Main card view with horizontal layout
        let cardView = UIView(frame: CGRect(x: 0, y: 0, width: 192, height: 40))
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
        
        // Distance box (green background)
        let distanceBox = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        distanceBox.backgroundColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
        distanceBox.layer.cornerRadius = 8
        distanceBox.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] // Only left corners
        
        let distanceLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        distanceLabel.text = distance
        distanceLabel.font = UIFont.boldSystemFont(ofSize: 15)
        distanceLabel.textColor = .white
        distanceLabel.textAlignment = .center
        distanceLabel.numberOfLines = 2
        distanceBox.addSubview(distanceLabel)
        
        // Duration box (light green background)
        let durationBox = UIView(frame: CGRect(x: 40, y: 0, width: 40, height: 40))
        durationBox.backgroundColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 0.2)
        
        let durationLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        durationLabel.text = duration
        durationLabel.font = UIFont.boldSystemFont(ofSize: 15)
        durationLabel.textColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
        durationLabel.textAlignment = .center
        durationLabel.numberOfLines = 2
        durationBox.addSubview(durationLabel)
        
        // Destination info (right side)
        let destinationStack = UIStackView()
        destinationStack.axis = .vertical
        destinationStack.spacing = 2
        destinationStack.frame = CGRect(x: 88, y: 8, width: 96, height: 32)
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 10)
        titleLabel.textColor = .gray
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
        subtitleLabel.textColor = .black
        subtitleLabel.numberOfLines = 2
        subtitleLabel.lineBreakMode = .byTruncatingTail
        
        destinationStack.addArrangedSubview(titleLabel)
        destinationStack.addArrangedSubview(subtitleLabel)
        
        cardView.addSubview(distanceBox)
        cardView.addSubview(durationBox)
        cardView.addSubview(destinationStack)
        
        // Pin icon below card, centered
        let pinImageView = UIImageView(frame: CGRect(x: 88, y: 40, width: 16, height: 20))
        if let pinImage = pinImage {
            pinImageView.image = pinImage
        }
        pinImageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(cardView)
        containerView.addSubview(pinImageView)
        
        return containerView
    }
    private func drawRoute(from pickupCoord: CLLocationCoordinate2D, to dropoffCoord: CLLocationCoordinate2D) {
        // Remove existing polyline
        if let polyline = routePolyline {
            polyline.map = nil
        }
        
        // Clear existing markers
        mapView.clear()
        
        // Add pickup marker with integrated widget
        let pickupMarker = GMSMarker()
        pickupMarker.position = pickupCoord
        pickupMarker.title = "Pickup"
        pickupMarker.snippet = pickupLocation
        
        if let pinImage = UIImage(named: "pickup_pin") {
            let scaledPin = pinImage.scaledTo(size: CGSize(width: 26, height: 26))
            let markerView = createPickupMarkerView(
                title: "Pickup",
                subtitle: pickupLocation,
                color: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0),
                pinImage: scaledPin
            )
            pickupMarker.iconView = markerView
            pickupMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
        } else {
            pickupMarker.icon = GMSMarker.markerImage(with: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0))
        }
        pickupMarker.map = mapView
        
        // Fetch actual directions from Google Directions API
        locationManager.fetchDirections(from: pickupCoord, to: dropoffCoord) { [self] path, distanceText, durationText in
            DispatchQueue.main.async {
                // Add destination marker with distance and time
                let destinationMarker = GMSMarker()
                destinationMarker.position = dropoffCoord
                destinationMarker.title = "Destination"
                destinationMarker.snippet = self.destinationLocation
                
                if let pinImage = UIImage(named: "source_dest_pin") {
                    let scaledPin = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
                    let markerView = self.createDestinationMarkerView(
                        title: "Destination",
                        subtitle: self.destinationLocation,
                        distance: distanceText ?? "N/A",
                        duration: durationText ?? "N/A",
                        color: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0),
                        pinImage: scaledPin
                    )
                    destinationMarker.iconView = markerView
                    destinationMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                } else {
                    destinationMarker.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
                }
                destinationMarker.map = self.mapView
                
                if let path = path {
                    // Draw the actual route
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                    polyline.map = self.mapView
                    
                    self.routePolyline = polyline
                    
                    // Create asymmetric padding - more padding at bottom
                    let bounds = GMSCoordinateBounds(path: path)
                    let padding = UIEdgeInsets(
                        top: 100,
                        left: 50,
                        bottom: 300 + 50, // Extra padding for bottom sheet
                        right: 50
                    )
                    
                    let update = GMSCameraUpdate.fit(bounds, with: padding)
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
                    
                    // Asymmetric padding for fallback
                    let bounds = GMSCoordinateBounds(path: fallbackPath)
                    let padding = UIEdgeInsets(
                        top: 100,
                        left: 50,
                        bottom: 300 + 50,
                        right: 50
                    )
                    
                    let update = GMSCameraUpdate.fit(bounds, with: padding)
                    self.mapView.animate(with: update)
                }
            }
        }
    }
    // MARK: - Driver Tracking Functions
    
    private func drawDriverOnMap() {
        guard let driverInfo = socketManager.driverInfo else {
            print("⚠️ No driver info available to draw on map")
            return
        }
        
        let driverCoord = CLLocationCoordinate2D(
            latitude: driverInfo.driver.currentLatitude,
            longitude: driverInfo.driver.currentLongitude
        )
        
        let pickupCoord = CLLocationCoordinate2D(
            latitude: Double(driverInfo.pickupLatitude) ?? pickupLatitude,
            longitude: Double(driverInfo.pickupLongitude) ?? pickupLongitude
        )
        
        // Clear existing markers and routes from the map
        mapView.clear()
        
        // Also clear the old pickup-to-destination route reference
        routePolyline?.map = nil
        routePolyline = nil
        
        // Add driver marker (car icon) with widget
        let driverMarker = GMSMarker(position: driverCoord)
        driverMarker.title = driverInfo.driver.name
        driverMarker.snippet = "\(driverInfo.driver.vehicle.make) \(driverInfo.driver.vehicle.model)"
        
        if let carImage = UIImage(named: "car_pin") {
            let scaledCar = carImage.scaledTo(size: CGSize(width: 16, height: 30))
            let markerView = createDriverMarkerView(
                name: driverInfo.driver.name,
                vehicle: "\(driverInfo.driver.vehicle.make) \(driverInfo.driver.vehicle.model)",
                carImage: scaledCar
            )
            driverMarker.iconView = markerView
            driverMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
        } else {
            driverMarker.icon = GMSMarker.markerImage(with: .systemBlue)
        }
        driverMarker.map = mapView
        self.driverMarker = driverMarker
        
        // Add pickup marker with widget
        let pickupMarker = GMSMarker(position: pickupCoord)
        pickupMarker.title = "Pickup"
        pickupMarker.snippet = pickupLocation
        
        if let pinImage = UIImage(named: "pickup_pin") {
            let scaledPin = pinImage.scaledTo(size: CGSize(width: 26, height: 26))
            let markerView = createPickupMarkerView(
                title: "Pickup",
                subtitle: pickupLocation,
                color: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0),
                pinImage: scaledPin
            )
            pickupMarker.iconView = markerView
            pickupMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
        } else {
            pickupMarker.icon = GMSMarker.markerImage(with: UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0))
        }
        pickupMarker.map = mapView
        
        // Draw route from driver to pickup
        drawDriverToPickupRoute(from: driverCoord, to: pickupCoord)
        
        // Animate camera to show both driver and pickup
        let bounds = GMSCoordinateBounds(coordinate: driverCoord, coordinate: pickupCoord)
        let padding = UIEdgeInsets(top: 100, left: 50, bottom: 300 + 50, right: 50)
        let update = GMSCameraUpdate.fit(bounds, with: padding)
        mapView.animate(with: update)
    }

    /// Create driver marker view with car icon
    private func createDriverMarkerView(name: String, vehicle: String, carImage: UIImage?) -> UIView {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 60))
        
        // Info card
        let cardView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 8
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowOpacity = 0.2
        cardView.layer.shadowRadius = 4
        cardView.clipsToBounds = false
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.frame = CGRect(x: 8, y: 6, width: 104, height: 28)
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 12)
        nameLabel.textColor = .systemBlue
        
        let vehicleLabel = UILabel()
        vehicleLabel.text = vehicle
        vehicleLabel.font = UIFont.systemFont(ofSize: 10)
        vehicleLabel.textColor = .darkGray
        vehicleLabel.numberOfLines = 1
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(vehicleLabel)
        cardView.addSubview(stackView)
        
        // Car icon below
        let carImageView = UIImageView(frame: CGRect(x: 52, y: 40, width: 16, height: 20))
        if let carImage = carImage {
            carImageView.image = carImage
        }
        carImageView.contentMode = .scaleAspectFit
        
        containerView.addSubview(cardView)
        containerView.addSubview(carImageView)
        
        return containerView
    }

    /// Draw route from driver to pickup location
    private func drawDriverToPickupRoute(from driverCoord: CLLocationCoordinate2D, to pickupCoord: CLLocationCoordinate2D) {
        // Remove existing driver route polyline
        driverRoutePolyline?.map = nil
        driverRoutePolyline = nil
        
        // Also ensure old pickup-to-destination route is cleared
        routePolyline?.map = nil
        routePolyline = nil
        
        locationManager.fetchDirections(from: driverCoord, to: pickupCoord) { [self] path, distanceText, durationText in
            DispatchQueue.main.async {
                // Clear any route that was drawn between our request and callback
                self.driverRoutePolyline?.map = nil
                
                if let path = path {
                    // Draw the actual route with a different color (blue for driver route)
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor.systemBlue
                    polyline.map = self.mapView
                    self.driverRoutePolyline = polyline
                } else {
                    // Fallback to straight line
                    let fallbackPath = GMSMutablePath()
                    fallbackPath.add(driverCoord)
                    fallbackPath.add(pickupCoord)
                    
                    let polyline = GMSPolyline(path: fallbackPath)
                    polyline.strokeWidth = 4
                    polyline.strokeColor = UIColor.systemBlue
                    polyline.map = self.mapView
                    self.driverRoutePolyline = polyline
                }
            }
        }
    }

    /// Update driver marker position when location changes
    private func updateDriverMarkerPosition(latitude: Double, longitude: Double) {
        let newPosition = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if let marker = driverMarker {
            // Animate marker movement
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.5)
            marker.position = newPosition
            CATransaction.commit()
            
            if socketManager.isRideStarted {
                // Ride in progress: draw route from driver to destination
                let destCoord = CLLocationCoordinate2D(
                    latitude: destinationLatitude,
                    longitude: destinationLongitude
                )
                drawDriverToDestinationRoute(from: newPosition, to: destCoord)
                
                let bounds = GMSCoordinateBounds(coordinate: newPosition, coordinate: destCoord)
                let padding = UIEdgeInsets(top: 100, left: 50, bottom: 300 + 50, right: 50)
                let update = GMSCameraUpdate.fit(bounds, with: padding)
                mapView.animate(with: update)
            } else {
                // Driver en route to pickup: draw route to pickup
                let pickupCoord = CLLocationCoordinate2D(
                    latitude: pickupLatitude,
                    longitude: pickupLongitude
                )
                drawDriverToPickupRoute(from: newPosition, to: pickupCoord)
                
                let bounds = GMSCoordinateBounds(coordinate: newPosition, coordinate: pickupCoord)
                let padding = UIEdgeInsets(top: 100, left: 50, bottom: 300 + 50, right: 50)
                let update = GMSCameraUpdate.fit(bounds, with: padding)
                mapView.animate(with: update)
            }
        } else {
            // If marker doesn't exist, redraw everything
            drawDriverOnMap()
        }
    }

    private func drawDriverToDestinationRoute(from driverCoord: CLLocationCoordinate2D, to destCoord: CLLocationCoordinate2D) {
        // Remove existing driver route polyline
        driverRoutePolyline?.map = nil
        driverRoutePolyline = nil
        
        // Clear existing markers to redraw with destination widget
        mapView.clear()
        
        // Re-add driver marker
        if let driverInfo = socketManager.driverInfo, let carImage = UIImage(named: "car_pin") {
            let driverMarker = GMSMarker(position: driverCoord)
            let scaledCar = carImage.scaledTo(size: CGSize(width: 16, height: 30))
            let markerView = createDriverMarkerView(
                name: driverInfo.driver.name,
                vehicle: "\(driverInfo.driver.vehicle.make) \(driverInfo.driver.vehicle.model)",
                carImage: scaledCar
            )
            driverMarker.iconView = markerView
            driverMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
            driverMarker.map = mapView
            self.driverMarker = driverMarker
        }
        
        locationManager.fetchDirections(from: driverCoord, to: destCoord) { [self] path, distanceText, durationText in
            DispatchQueue.main.async {
                self.driverRoutePolyline?.map = nil
                
                // Add destination marker with distance and time widget
                let destinationMarker = GMSMarker(position: destCoord)
                destinationMarker.title = "Destination"
                destinationMarker.snippet = self.destinationLocation
                
                if let pinImage = UIImage(named: "source_dest_pin") {
                    let scaledPin = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
                    let markerView = self.createDestinationMarkerView(
                        title: "Destination",
                        subtitle: self.destinationLocation,
                        distance: distanceText ?? "N/A",
                        duration: durationText ?? "N/A",
                        color: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0),
                        pinImage: scaledPin
                    )
                    destinationMarker.iconView = markerView
                    destinationMarker.groundAnchor = CGPoint(x: 0.5, y: 1.0)
                } else {
                    destinationMarker.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
                }
                destinationMarker.map = self.mapView
                
                if let path = path {
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 5
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                    polyline.map = self.mapView
                    self.driverRoutePolyline = polyline
                } else {
                    let fallbackPath = GMSMutablePath()
                    fallbackPath.add(driverCoord)
                    fallbackPath.add(destCoord)
                    
                    let polyline = GMSPolyline(path: fallbackPath)
                    polyline.strokeWidth = 4
                    polyline.strokeColor = UIColor(red: 0.22, green: 0.65, blue: 0.33, alpha: 1.0)
                    polyline.map = self.mapView
                    self.driverRoutePolyline = polyline
                }
            }
        }
    }
    /// Clean up driver tracking when leaving driverEnRoute state
    private func clearDriverTracking() {
        driverMarker?.map = nil
        driverMarker = nil
        driverRoutePolyline?.map = nil
        driverRoutePolyline = nil
    }
    
    // MARK: - Ride Started / Completed Handling
    
    /// Called when driver starts the ride — switch route from pickup to destination
    private func handleRideStarted() {
        guard let driverInfo = socketManager.driverInfo else { return }
        
        // Get current driver location (use real-time if available, else initial)
        let driverCoord: CLLocationCoordinate2D
        if let driverLoc = socketManager.driverLocation {
            driverCoord = CLLocationCoordinate2D(latitude: driverLoc.latitude, longitude: driverLoc.longitude)
        } else {
            driverCoord = CLLocationCoordinate2D(
                latitude: driverInfo.driver.currentLatitude,
                longitude: driverInfo.driver.currentLongitude
            )
        }
        
        let destCoord = CLLocationCoordinate2D(
            latitude: Double(driverInfo.dropoffLatitude) ?? destinationLatitude,
            longitude: Double(driverInfo.dropoffLongitude) ?? destinationLongitude
        )
        
        // Clear the map (removes old pickup route and pickup marker)
        mapView.clear()
        routePolyline?.map = nil
        routePolyline = nil
        driverRoutePolyline?.map = nil
        driverRoutePolyline = nil
        
        // Re-add driver marker
        let marker = GMSMarker(position: driverCoord)
        marker.title = driverInfo.driver.name
        marker.snippet = "\(driverInfo.driver.vehicle.make) \(driverInfo.driver.vehicle.model)"
        if let carImage = UIImage(named: "car_pin") {
            let scaledImage = carImage.scaledTo(size: CGSize(width: 16, height: 30))
            marker.icon = scaledImage
        } else {
            marker.icon = GMSMarker.markerImage(with: .systemBlue)
        }
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        driverMarker = marker
        
        // Add destination marker
        let destMarker = GMSMarker(position: destCoord)
        destMarker.title = "Destination"
        destMarker.snippet = destinationLocation
        if let pinImage = UIImage(named: "source_dest_pin") {
            let scaledImage = pinImage.scaledTo(size: CGSize(width: 16.88, height: 30))
            destMarker.icon = scaledImage
        } else {
            destMarker.icon = GMSMarker.markerImage(with: UIColor(red: 0.85, green: 0.26, blue: 0.26, alpha: 1.0))
        }
        destMarker.map = mapView
        
        // Draw route from driver to destination
        drawDriverToDestinationRoute(from: driverCoord, to: destCoord)
        
        // Fit camera to show both driver and destination
        let bounds = GMSCoordinateBounds(coordinate: driverCoord, coordinate: destCoord)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 120)
        mapView.animate(with: update)
        
        print("🚗 Ride started: route redrawn from driver to destination")
    }
    
    /// Called when ride is completed — show TripCompleteScreen
    private func handleRideCompleted() {
        // Clear the map
        mapView.clear()
        clearDriverTracking()
        routePolyline?.map = nil
        routePolyline = nil
        
        withAnimation {
            showTripComplete = true
        }
        print("✅ Ride completed: showing TripCompleteScreen")
    }
    
    /// Called when ride is cancelled — return to initial state
    private func handleRideCancelled() {
        // Clear the map
        mapView.clear()
        clearDriverTracking()
        routePolyline?.map = nil
        routePolyline = nil
        
        // Reset to initial state
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bottomSheetState = .initial
            sheetHeight = midSheetHeight
            navigationState.showBottomBar()
        }
        
        // Reset location fields
        pickupLocation = "From?"
        destinationLocation = "Where To?"
        pickupLatitude = 0
        pickupLongitude = 0
        destinationLatitude = 0
        destinationLongitude = 0
        
        print("❌ Ride cancelled: returned to initial screen")
    }
    
    /// Reset everything after ride completion (dismiss trip complete, return to initial state)
    private func resetAfterRideCompletion() {
        // Reset socket manager state
        socketManager.isRideStarted = false
        socketManager.hasDriverArrived = false
        socketManager.currentRideStatus = nil
        socketManager.driverInfo = nil
        socketManager.driverLocation = nil
        socketManager.currentRideId = nil
        
        // Reset bottom sheet to initial state
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bottomSheetState = .initial
            sheetHeight = midSheetHeight
            navigationState.showBottomBar()
        }
    }

    private func addLocationWidget(title: String, subtitle: String, color: UIColor, at coordinate: CLLocationCoordinate2D) {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 10
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.15
        container.layer.shadowRadius = 6
        container.layer.shadowOffset = CGSize(width: 0, height: 3)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = color

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        subtitleLabel.textColor = UIColor.darkGray
        subtitleLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading

        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6)
        ])

        let marker = GMSMarker(position: coordinate)
        marker.iconView = container
        marker.groundAnchor = CGPoint(x: 0.5, y: 1.4)
        marker.zIndex = 999
        marker.map = mapView

        marker.tracksViewChanges = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            marker.tracksViewChanges = false
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



// Swift
struct HomeScreenPreviewWrapper: View {
    @State private var selectedService = SelectedService.defaultService
    @State private var isNowSelected = true
    @State private var pickupLocation = "From?"
    @State private var destinationLocation = "Where To?"
    @State private var bottomSheetState = BottomSheetState.initial

    var body: some View {
        HomeScreen(
            selectedService: $selectedService,
            isNowSelected: $isNowSelected,
            pickupLocation: $pickupLocation,
            destinationLocation: $destinationLocation,
            bottomSheetState: $bottomSheetState
        )
        .environmentObject(NavigationStateManager())
    }
}

struct HomeScreenPreviewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreenPreviewWrapper()
    }
}
