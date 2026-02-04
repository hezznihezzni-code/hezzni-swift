//
//  PessengerHomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/9/25.
//

import SwiftUI

struct ServicesHome: View {
    @State private var navigateToService: String? = nil
    @State private var showRentalScreen: Bool = false
    @EnvironmentObject private var navigationState: NavigationStateManager

    @StateObject private var servicesVM = PassengerServicesViewModel()
    
    @Binding var selectedTab: BottomNavigationBar.Tab
    @Binding var selectedService: SelectedService
    @Binding var isNowSelected: Bool
    @Binding var pickupLocation: String
    @Binding var destinationLocation: String
    
    @Binding var bottomSheetState: BottomSheetState

    var body: some View {
        NavigationView {
            ZStack {
                if showRentalScreen { CarRentalScreen(
                    onBack: {
                        navigationState.showBottomBar()
                        
                        withAnimation(.easeInOut){
                            showRentalScreen = false
                        }
                    }
                )
                .transition(.move(edge: .trailing))
                } else {
                    VStack {
                        CustomAppBar(title: "Choose a Service", backButtonVisible: false, backButtonAction: {}, trailingView: {
                            HStack {
                                NotificationButton()
                            }
                        })
                        
                        if servicesVM.isLoading {
                            ServicesGridShimmer()
                                .padding(.top, 16)
                        } else if let error = servicesVM.errorMessage {
                            VStack(spacing: 12) {
                                Text(error)
                                    .font(.poppins(.regular, size: 14))
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                                
                                Button("Retry") {
                                    Task { await servicesVM.loadServices(force: true) }
                                }
                                .font(.poppins(.medium, size: 14))
                            }
                            .padding(.top, 24)
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 16) {
                                ForEach(servicesVM.services) { service in
                                    ServiceCard(
                                        icon: service.iconAssetName,
                                        title: service.name,
                                        isSelected: selectedService.id == service.id,
                                        action: {
                                            selectedService = SelectedService(from: service)
                                            if service.name == "Rental Car" {
                                                withAnimation(.easeInOut){
                                                    showRentalScreen = true
                                                }
                                                navigationState.hideBottomBar()
                                            }
                                            else{
                                                selectedTab = .home
                                                navigationState.hideBottomBar()
                                                if service.name == "Reservation" {
                                                    isNowSelected = false
                                                }
                                                bottomSheetState = .journey
                                            }
                                            
                                            //                                            navigateToService = service.name
                                        }
                                    )
                                    //                                NavigationLink(
                                    //                                    destination: serviceWelcomeView(for: service.name),
                                    //                                    tag: service.name,
                                    //                                    selection: $navigateToService
                                    //                                ) {
                                    //                                    ServiceCard(
                                    //                                        icon: service.iconAssetName,
                                    //                                        title: service.name,
                                    //                                        isSelected: selectedService == service.name,
                                    //                                        action: {
                                    //                                            selectedService = service.name
                                    //                                            selectedTab = .home
                                    //                                            bottomSheetState = .nowRide
                                    ////                                            navigateToService = service.name
                                    //                                        }
                                    //                                    )
                                    //                                }
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                navigationState.showBottomBar()
            }
            .task {
                await servicesVM.loadServices()

                // Keep default selection consistent with API data.
                if selectedService.name == "Car Rides" || selectedService.id == 1, let first = servicesVM.services.first {
                    selectedService = SelectedService(from: first)
                }
            }
        }
    }

    @ViewBuilder
    private func serviceWelcomeView(for service: String) -> some View {
        switch service {
        //        case "Car":
        //            HomeScreen()
        case "Motorcycle":
            BikeRideWelcomeScreen()
        case "Airport Ride", "Ride to Airport":
            AirportRideWelcomeScreen()
        case "Rental Car":
            RentalRideWelcomeScreen()
        case "City to City Taxi", "City to City":
            CityRideWelcomeScreen()
        case "Taxi":
            TaxiRideWelcomeScreen()
        case "Delivery":
            DeliveryRideWelcomeScreen()
        case "Group Ride":
            GroupRideWelcomeScreen()
        default:
            Text("Service not available")
        }
    }
}

private struct ServicesGridShimmer: View {
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<9, id: \.self) { _ in
                ShimmerServiceCard()
            }
        }
    }
}

private struct ShimmerServiceCard: View {
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.06))
                .frame(width: 90, height: 90)

            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.06))
                .frame(height: 14)
                .padding(.horizontal, 18)
                .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color(hex: "#04060F").opacity(0.06), radius: 30, x: 0, y: 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .shimmer(isActive: true)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct ServiceCard: View {
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
                    .font(.poppins(.medium, size: 14))
                    .foregroundColor(.primary)
                    .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundStyle(.white)
                    .shadow(color: Color(hex: "#04060F").opacity(0.06), radius: 30, x: 0, y: 0)
                    .background(Color.white.cornerRadius(12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? .hezzniGreen : .white.opacity(0), lineWidth: 2)
            )
        }
    }
}


//// Swift
//#Preview {
//    struct ServicesHomePreview: View {
//        @State private var selectedService = "Car"
//        @State private var isNowSelected = true
//        @State private var pickupLocation = "From?"
//        @State private var destinationLocation = "Where To?"
//        @State private var bottomSheetState = BottomSheetState.initial
//        @State private var selectedTab: BottomNavigationBar.Tab = .services
//
//        var body: some View {
//            ServicesHome(
//                selectedTab: $selectedTab,
//                selectedService: $selectedService,
//                isNowSelected: $isNowSelected,
//                pickupLocation: $pickupLocation,
//                destinationLocation: $destinationLocation,
//                bottomSheetState: $bottomSheetState
//            )
//            .environmentObject(NavigationStateManager())
//        }
//    }
//    return ServicesHomePreview()
//}
