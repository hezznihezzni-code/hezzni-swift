//
//  RideDetails.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/8/26.
//
import SwiftUI
internal import Combine

class RideDetails: ObservableObject {
    @Binding var isReservation: Bool?
    @Binding var pickupAddress: String?
    @Binding var role: String?
    @Binding var estimatedPrice: Double?
    @Binding var selectedPreferences: [Int]?
    @Binding var dropoffLatitude: Double?
    @Binding var dropoffLongitude: Double?
    @Binding var dropoffAddress: String?
    @Binding var serviceTypeId: Int?
    @Binding var pickupLatitude: Double?
    @Binding var pickupLongitude: Double?

    @Binding var selectedService: SelectedService?
    @Binding private var bottomSheetState: BottomSheetState?

    @State private var selectedRideOption: CalculateRidePriceResponse.RideOption?
    @State private var estimatedDistance: Double?
    @State private var estimatedDuration: Int?
    @State private var selectedDate: Date?
    @State private var appliedCoupon: AppliedCoupon?
    @State var selectedRideInformation: CalculateRidePriceResponse.RideOption?

    init(
        isReservation: Binding<Bool?>,
        pickupAddress: Binding<String?>,
        role: Binding<String?>,
        estimatedPrice: Binding<Double?>,
        selectedPreferences: Binding<[Int]?>,
        dropoffLatitude: Binding<Double?>,
        dropoffLongitude: Binding<Double?>,
        dropoffAddress: Binding<String?>,
        serviceTypeId: Binding<Int?>,
        pickupLatitude: Binding<Double?>,
        pickupLongitude: Binding<Double?>,
        selectedService: Binding<SelectedService?>,
        bottomSheetState: Binding<BottomSheetState?>,
        selectedRideInformation: CalculateRidePriceResponse.RideOption?
    ) {
        _isReservation = isReservation
        _pickupAddress = pickupAddress
        _role = role
        _estimatedPrice = estimatedPrice
        _selectedPreferences = selectedPreferences
        _dropoffLatitude = dropoffLatitude
        _dropoffLongitude = dropoffLongitude
        _dropoffAddress = dropoffAddress
        _serviceTypeId = serviceTypeId
        _pickupLatitude = pickupLatitude
        _pickupLongitude = pickupLongitude
        _selectedService = selectedService
        _bottomSheetState = bottomSheetState
        self.selectedRideInformation = selectedRideInformation
    }
}

