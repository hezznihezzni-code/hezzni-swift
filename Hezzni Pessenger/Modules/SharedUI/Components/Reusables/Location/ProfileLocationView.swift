//
//  ProfileLocationView.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/3/25.
//

import SwiftUI

struct ProfileLocationView: View {
    @StateObject private var locationService = LocationDataService()
    @State private var selectedCountry: Country?
    @State private var selectedCity: LocationCity?

    var filteredCities: [LocationCity] {
        if let countryCode = selectedCountry?.code {
            return locationService.getCities(for: countryCode)
        }
        return []
    }

    var body: some View {
        ZStack() {
            Text("Location")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(.black)
                .offset(x: -134.50, y: -93.50)

            VStack(alignment: .leading, spacing: 16) {
                // Country Wheel Picker
                WheelPickerPopup(
                    title: "Country",
                    selection: $selectedCountry,
                    options: locationService.countries,
                    placeholder: "Enter your country"
                )
                .onChange(of: selectedCountry) { _ in
                    // Reset city when country changes
                    selectedCity = nil
                }

                // City Wheel Picker
                WheelPickerPopup(
                    title: "City",
                    selection: $selectedCity,
                    options: filteredCities,
                    placeholder: selectedCountry == nil ? "Select country first" : "Enter your city"
                )
                .disabled(selectedCountry == nil)
                .opacity(selectedCountry == nil ? 0.6 : 1.0)
            }
            .frame(width: 342)
            .offset(x: 0, y: 22.50)
        }
        .frame(width: 370, height: 243)
        .background(.white)
        .cornerRadius(8)
        .shadow(
            color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4
        )
        .onAppear {
            // Ensure countries are loaded
            if locationService.countries.isEmpty {
                locationService.loadCountries()
            }
        }
    }
}

#Preview {
    ProfileLocationView()
}

// WheelPickerPopup.swift


struct WheelPickerPopup<T: Identifiable & Hashable>: View where T: CustomStringConvertible {
    let title: String
    @Binding var selection: T?
    let options: [T]
    let placeholder: String

    @State private var showPicker = false
    @State private var tempSelection: T?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))

            Button(action: {
                tempSelection = selection
                showPicker = true
            }) {
                ZStack(alignment: .leading) {
                    HStack {
                        Text(selection?.description ?? placeholder)
                            .font(Font.custom("Poppins", size: 14).weight(.light))
                            .foregroundColor(selection == nil ? Color(red: 0.09, green: 0.09, blue: 0.09) : .black)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 46)
                    .background(Color.white)
                    .cornerRadius(7.51)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7.51)
                            .inset(by: 0.47)
                            .stroke(Color(red: 0.86, green: 0.86, blue: 0.86), lineWidth: 0.47)
                    )
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .sheet(isPresented: $showPicker) {
            NavigationView {
                VStack {
                    if options.isEmpty {
                        Text("No options available")
                            .font(Font.custom("Poppins", size: 16))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Picker("Select \(title)", selection: $tempSelection) {
                            ForEach(options) { option in
                                Text(option.description)
                                    .font(Font.custom("Poppins", size: 16))
                                    .tag(Optional(option))
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .labelsHidden()
                    }
                }
                .navigationTitle("Select \(title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showPicker = false
                        }
                        .font(Font.custom("Poppins", size: 16))
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            selection = tempSelection
                            showPicker = false
                        }
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                    }
                }
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            tempSelection = selection
        }
    }
}
