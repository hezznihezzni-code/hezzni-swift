//
//  RideProcessScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/21/25.
//

import SwiftUI
import GoogleMaps


struct RideProcessScreen: View {
    
    @State private var sheetHeight: CGFloat = 480
    private let minSheetHeight: CGFloat = 120
    private let midSheetHeight: CGFloat = 480
    private let maxSheetHeight: CGFloat = UIScreen.main.bounds.height * 0.85

    @State private var mapView = GMSMapView()
    @State private var cameraPosition: GMSCameraPosition
    @State private var showChatScreen = false // Add this state
    @State private var showCancelConfirmation = false  // Confirmation dialog state
    @ObservedObject private var socketManager = RideSocketManager.shared
    @Environment(\.dismiss) private var dismiss

    init() {
        let marrakech = CLLocationCoordinate2D(latitude: 40.629255690273595, longitude: -73.98749804295893)
        _cameraPosition = State(initialValue: GMSCameraPosition.camera(withTarget: marrakech, zoom: 15))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GoogleMapView(mapView: $mapView, cameraPosition: $cameraPosition)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading, spacing: 0){
                
                VStack(alignment: .trailing, spacing: 7){
                    // Estimated arrival time bar
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Estimated arrival Time")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.white)
                        
                        Text("5 min")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.hezzniGreen)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.7))
                            .cornerRadius(12)
                        Spacer()
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 2)
                    .cornerRadius(24)
                    VStack(spacing: 0) {
                        
                        
                        Capsule()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                            .padding(.top, 12)
                            .padding(.bottom, 8)
                            .gesture(dragGesture)
                        
                        // Sheet content
                        VStack(spacing: 15) {
                            
                            
                            // Car info card
                            ReservationScheduleCard(
                                carInfo: "8 | أ | 26363",
                                carModel: "Toyota HR-V",
                                carColor: "White",
                                carType: "STANDARD",
                                carImage: "personal_car1"
                            )
                            
                            // Driver info
                            PersonDetailsWithActions(
                                profileImage: "profile_placeholder",
                                name: "Ahmed Hassan",
                                trips: 2847,
                                rating: 4.8,
                                badgeImage: "verified_badge",
                                onChat: {
                                    showChatScreen = true // Update this closure
                                },
                                onCall: {}
                            )
                            
                            // Pickup/Destination
                            PickupDestinationPathView(
                                pickupLocation: "Current Location, Marrakech",
                                destinationLocation: "Current Location, Marrakech"
                            )
                            
                            // Cancel button
                            Button(action: {
                                showCancelConfirmation = true  // Show confirmation dialog
                            }) {
                                Text("Cancel Ride")
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(red: 0.83, green: 0.18, blue: 0.18))
                                    .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 24)
                    }
                    .background(Color.white)
                    .cornerRadius(24)
                    
                }
                .background(.hezzniGreen)
                .cornerRadius(24)
                .offset(y: -22)
            }
            .frame(height: sheetHeight)
            .background(.white)
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: -5)
            .gesture(dragGesture)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: sheetHeight)
        }
        .background(
            NavigationLink(
                destination: ChatDetailedScreen().environmentObject(NavigationStateManager()),
                isActive: $showChatScreen
            ) {
                EmptyView()
            }
        )
        .alert("Cancel Ride", isPresented: $showCancelConfirmation) {
            Button("No, Keep Ride", role: .cancel) { }
            Button("Yes, Cancel", role: .destructive) {
                // Emit passenger:cancelRide with rideRequestId
                socketManager.cancelRide(reason: "Passenger cancelled")
                dismiss()
            }
        } message: {
            Text("Are you sure you want to cancel this ride?")
        }
        .onAppear {
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: sheetHeight, right: 0)
        }
        .ignoresSafeArea()
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let newHeight = max(minSheetHeight, sheetHeight - value.translation.height)
                sheetHeight = min(maxSheetHeight, newHeight)
            }
            .onEnded { _ in
                snapSheetToPosition()
            }
    }

    private func snapSheetToPosition() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
//            if sheetHeight > (maxSheetHeight + midSheetHeight) / 2 {
//                sheetHeight = maxSheetHeight
//            } else
            if sheetHeight > (midSheetHeight + minSheetHeight) / 2 {
                sheetHeight = midSheetHeight
            } else {
                sheetHeight = minSheetHeight
            }
        }
    }
}

#Preview {
    RideProcessScreen()
}

