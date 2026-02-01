//
//  PessengerHomeScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/9/25.
//

import SwiftUI

struct ServicesHome: View {
    @State private var selectedService: String = "Car" // Default selected service
    @State private var navigateToService: String? = nil
    @EnvironmentObject private var navigationState: NavigationStateManager

    @StateObject private var servicesVM = PassengerServicesViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    CustomAppBar(title: "Choose a Service", backButtonVisible: false, backButtonAction: {}, trailingView: {
                        HStack {
                            NotificationButton()
                        }
                    })

                    if servicesVM.isLoading {
                        ProgressView()
                            .padding(.top, 24)
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
                                NavigationLink(
                                    destination: serviceWelcomeView(for: service.name),
                                    tag: service.name,
                                    selection: $navigateToService
                                ) {
                                    ServiceCard(
                                        icon: service.iconAssetName,
                                        title: service.name,
                                        isSelected: selectedService == service.name,
                                        action: {
                                            selectedService = service.name
                                            navigateToService = service.name
                                        }
                                    )
                                }
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            .navigationBarHidden(true)
            .onAppear {
                navigationState.showBottomBar()
            }
            .task {
                await servicesVM.loadServices()

                // Keep default selection consistent with API data.
                if selectedService == "Car", let first = servicesVM.services.first {
                    selectedService = first.name
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

#Preview {
    ServicesHome()
        .environmentObject(NavigationStateManager())
}
