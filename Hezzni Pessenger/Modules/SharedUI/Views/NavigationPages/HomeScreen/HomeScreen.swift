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
    @State private var selectedService: String = "Car"
    @State private var isNowSelected: Bool = true
    @State private var pickupLocation: String = "From?"
    @State private var destinationLocation: String = "Where To?"
    
    @State private var bottomSheetState: BottomSheetState = .initial
    
   
    @State private var isEditingPickup = false
    @State private var isEditingDestination = false
    @State private var showSuggestions = false
    @State private var searchText = ""
    @State private var mapView = GMSMapView()
    @State private var cameraPosition: GMSCameraPosition
    @StateObject private var locationManager = LocationManager()
    
    //MARK: Animation Variables
    @Namespace private var animations
    
    //MARK: For Reservation Screen
    @State private var showSchedulePicker = false
    @State private var selectedDate: Date = Date()
    
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

    // List of services
    private let services = [
        Service(id: "car", icon: "car-service-icon", title: "Car"),
        Service(id: "airport", icon: "airport-service-icon", title: "Ride to Airport"),
        Service(id: "motorcycle", icon: "motorcycle-service-icon", title: "Motorcycle"),
        Service(id: "city", icon: "city-service-icon", title: "City to City"),
        Service(id: "taxi", icon: "taxi-service-icon", title: "Taxi"),
        Service(id: "delivery", icon: "delivery-service-icon", title: "Delivery"),
        Service(id: "group", icon: "shared-service-icon", title: "Group Ride")
    ]
    
    // Sample suggestion data
    let suggestions = [
        "Owen Elementary",
        "E Oak Hill Dr",
        "Woodcrest",
        "Park Land D",
        "Park Row Pl",
        "New Reservation",
        "Menara Airport",
        "Jamaâ El Fna Square"
    ]
    
    init() {
        // Default camera position for New York 40.629255690273595, -73.98749804295893
        let marrakech = CLLocationCoordinate2D(latitude: 40.629255690273595, longitude: -73.98749804295893)
        _cameraPosition = State(initialValue: GMSCameraPosition.camera(withTarget: marrakech, zoom: 14))
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
                }
                .onAppear {
                    navigationState.showBottomBar()
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
                    Image(systemName: "mappin")
                        .foregroundColor(.hezzniGreen)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                    Spacer()
                }
                .padding(.bottom, sheetHeight + 20)
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
    
    private var filteredSuggestions: [String] {
        suggestions.filter {
            searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func suggestionRow(suggestion: String) -> some View {
        Button(action: {
            handleSuggestionSelection(suggestion)
        }) {
            HStack {
                Image(systemName: "mappin.circle.fill")
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
            dragHandle
            
            // ----------- Titles ------------
            if bottomSheetState == .journey {
                CustomAppBar(
                    title: selectedService,
                    weight: .medium,
                    backButtonAction: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .initial
                            sheetHeight = midSheetHeight
                            navigationState.showBottomBar()
                        }
                    },
                    trailingView: {
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                if !isNowSelected {
                                    if selectedService == "Delivery" || selectedService == "Group Ride"{
                                        selectedService = "Car"
                                    }
                                        bottomSheetState = .reservation
                                    
                                } else{
                                    if selectedService == "Delivery" {
                                        bottomSheetState = .deliveryService
                                    }else {
                                        bottomSheetState = .nowRide
                                    }
                                    
                                }
                                sheetHeight = maxSheetHeight
                            }
                        }) {
                            Text("Next")
                                .font(.poppins(.medium, size: 14))
                                .foregroundColor(.hezzniGreen)
                        }
                    }
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
                ReservationDetailScreen(
                    bottomSheetState: $bottomSheetState,
                    namespace: animations,
                    selectedService: $selectedService,
                    showSchedulePicker: $showSchedulePicker,
                    selectedDate: $selectedDate
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .nowRide {
                NowRideDetailScreen(
                    bottomSheetState: $bottomSheetState,
                    namespace: animations,
                    selectedService: selectedService,
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .deliveryService {
                DeliveryDetailScreen(
                    bottomSheetState: $bottomSheetState,
                    showCountryPicker: $showCountryPicker,
                    namespace: animations,
                    selectedCountry: $selectedCountryForDelivery,
                    selectedService: selectedService
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
            else if bottomSheetState == .payment{
                RidePaymentScreen(
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
                FindingReservationScreen(
                    bottomSheetState: $bottomSheetState,
                    namespace: animations,
                    sheetHeight: $sheetHeight,
                    onCancel: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            bottomSheetState = .orderSummary
                            
                        }
                    }
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
        HorizontalServicesScrollView(
            items: services,
            padding: EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16),
            backgroundColor: .white
        ) { service in
            ServiceCardBuilder.createCard(
                icon: service.icon,
                title: service.title,
                isSelected: selectedService == service.title,
                action: { selectedService = service.title }
            )
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
                        if !isEditingDestination {
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
                                        searchText = pickupLocation
                                        navigationState.hideBottomBar()
                                        bottomSheetState = .journey
                                    }
                                },
                                
                                roundedEdges: .top
                                
                            ).matchedGeometryEffect(id: "pickup", in: animations)
                        }
                        
                        
                        LocationCardView(
                            imageName: "dropoff_ellipse",
                            heading: "Destination",
                            content: destinationLocation,
                            roundedEdges: .bottom
                        ).matchedGeometryEffect(id: "destination", in: animations)
                        
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
                            
                            // Suggestions list
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
    
    private func handleSuggestionSelection(_ suggestion: String) {
        if isEditingPickup {
            pickupLocation = suggestion
        } else if isEditingDestination {
            destinationLocation = suggestion
        }
        showSuggestions = false
        isEditingPickup = false
        isEditingDestination = false
        bottomSheetState = .initial
        navigationState.showBottomBar()
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            sheetHeight = midSheetHeight
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func handleChooseFromMap() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            bottomSheetState = .chooseOnMap
            sheetHeight = minSheetHeight
            showSuggestions = false
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func confirmLocationFromMap() {
        isLoadingLocation = true
        
        // Get the center coordinate of the map
        let centerCoordinate = mapView.camera.target
        
        // Reverse geocode to get the place name
        locationManager.reverseGeocode(coordinate: centerCoordinate) { placeName in
            DispatchQueue.main.async {
                if let placeName = placeName {
                    if isEditingPickup {
                        pickupLocation = placeName
                    } else if isEditingDestination {
                        destinationLocation = placeName
                    }
                }
                
                // Reset states
                isLoadingLocation = false
                isEditingPickup = false
                isEditingDestination = false
                bottomSheetState = .initial
                navigationState.showBottomBar()
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    sheetHeight = midSheetHeight
                }
            }
        }
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
            if bottomSheetState != .initial{
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
                } else {
                    sheetHeight = minSheetHeight
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
    
    private func findRide() {
            // Hide bottom bar when navigating away
//            navigationState.hideBottomBar()
//            navigationState.navigateToSchedulePicker()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showSuggestions = true
                isEditingPickup = true
                isEditingDestination = false
                sheetHeight = maxSheetHeight
                searchText = pickupLocation
                navigationState.hideBottomBar()
                bottomSheetState = .journey
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

#Preview {
    HomeScreen()
        .environmentObject(NavigationStateManager())
}
