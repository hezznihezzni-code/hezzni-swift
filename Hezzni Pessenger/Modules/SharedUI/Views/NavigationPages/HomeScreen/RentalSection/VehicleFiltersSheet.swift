//
//  VehicleFiltersSheet.swift
//  Hezzni
//
//  Rental Vehicle Filters

import SwiftUI
import UIKit

// RangeSliderRepresentable is defined in Modules/SharedUI/Components/Reusables/RangeSliderRepresentable.swift and must be in the same target.

enum FilterExpandedState {
    case none
    case status
    case makeModel
    case year
    case transmission
    case engineType
    case price
}

struct MakeModelPair: Identifiable, Hashable {
    let id = UUID()
    let make: String
    let model: String
}

struct VehicleFiltersSheet: View {
    @Binding var isPresented: Bool
    @State private var selectedStatus: String = "All"
    @State private var selectedMake: String = ""
    @State private var selectedModel: String = ""
    @State private var makeModelList: [MakeModelPair] = []
    @State private var transmissionTypes: Set<String> = []
    @State private var engineTypes: Set<String> = []
    @State private var priceRange: ClosedRange<Double> = 400...5700
    @State private var appliedFilters: [String] = []
    @State private var filterState: FilterExpandedState = FilterExpandedState.none
    @State private var startYear: Int = 2000
    @State private var endYear: Int = 2025
    
    let makes = ["Audi", "Honda", "BMW", "Toyota"]
    let transmissions = ["Automatic", "Manual"]
    let engines = ["Gas", "Diesel", "Hybrid", "Electric (EV)", "Hybrid electric (HEV)"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(16)
                    .background(.white)
                    .overlay(Rectangle().stroke(Color.black.opacity(0.1), lineWidth: 0.5))
                ScrollView {
                    VStack(spacing: 0) {
                        // Applied Filters
                        if !appliedFilters.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Applied Filters")
                                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                                    .foregroundColor(Color.black.opacity(0.6))
                                
                                FlowLayout(spacing: 8) {
                                    ForEach(appliedFilters, id: \.self) { filter in
                                        HStack(spacing: 4) {
                                            Text(filter)
                                                .font(Font.custom("Poppins", size: 12))
                                                .foregroundColor(.white)
                                            Button(action: { removeFilter(filter) }) {
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 10, weight: .semibold))
                                                    .foregroundColor(.hezzniGreen)
                                                    .padding(3)
                                                    .background{
                                                        Circle()
                                                            .foregroundStyle(.white)
                                                    }
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.05))
                        }
                        
                        VStack(spacing: 20) {
                            // Status Filter
                            filterSection(title: "Status", expandedState: .status) {
                                HStack(spacing: 8) {
                                    ForEach(["All", "Active", "Inactive", "Booked"], id: \.self) { status in
                                        Button(action: { selectedStatus = status; updateFilters() }) {
                                            Text(status)
                                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                                .foregroundColor(.black)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 15)
                                                .background(Color.white)
                                                .cornerRadius(8)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(selectedStatus == status ? .black : Color.black.opacity(0.2), lineWidth: 0.5)
                                                )
                                        }
                                    }
                                }
                            }
                            
                            // Make & Model
                            filterSection(title: "Make & Model", expandedState: .makeModel) {
                                VStack(spacing: 8) {
                                    // Display saved make-model pairs
                                    if !makeModelList.isEmpty {
                                        FlowLayout(spacing: 8) {
                                            ForEach(makeModelList) { pair in
                                                HStack(spacing: 4) {
                                                    Text("\(pair.make) \(pair.model)")
                                                        .font(Font.custom("Poppins", size: 12))
                                                        .foregroundColor(.hezzniGreen)
                                                    Button(action: {
                                                        makeModelList.removeAll { $0.id == pair.id }
                                                        updateFilters()
                                                    }) {
                                                        Image(systemName: "xmark")
                                                            .font(.system(size: 10))
                                                            .foregroundColor(.hezzniGreen)
                                                            .padding(3)
                                                    }
                                                }
                                                .padding(EdgeInsets(top: 7, leading: 10, bottom: 7, trailing: 10))
                                                .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.10))
                                                .cornerRadius(20)
                                                .overlay(
                                                RoundedRectangle(cornerRadius: 20)
                                                .inset(by: 0.50)
                                                .stroke(
                                                Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.40), lineWidth: 0.50
                                                )
                                                )
                                            }
                                        }
                                    }
                                    
                                    Menu {
                                        ForEach(makes, id: \.self) { make in
                                            Button(action: {
                                                selectedMake = make
                                            }) {
                                                Text(make)
                                            }
                                        }
                                    } label: {
                                        HStack {
                                            Text(selectedMake.isEmpty ? "Select Car Make" : selectedMake)
                                                .font(Font.custom("Poppins", size: 14))
                                                .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.50))
                                            Spacer()
                                            Image(systemName: "chevron.down")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 12, weight: .medium))
                                        }
                                        .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
                                        .background(Color(red: 0, green: 0, blue: 0).opacity(0.03))
                                        .cornerRadius(10)
                                        .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                        .inset(by: 0.50)
                                        .stroke(
                                        Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                                        )
                                        )
                                    }
                                    
                                    if selectedMake != "" {
                                        Menu {
                                            Button(action: {
                                                selectedModel = "Accord"
                                                let newPair = MakeModelPair(make: selectedMake, model: selectedModel)
                                                makeModelList.append(newPair)
                                                updateFilters()
                                            }) {
                                                Text("Accord")
                                            }
                                            Button(action: {
                                                selectedModel = "Civic"
                                                let newPair = MakeModelPair(make: selectedMake, model: selectedModel)
                                                makeModelList.append(newPair)
                                                updateFilters()
                                            }) {
                                                Text("Civic")
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedModel.isEmpty ? "Select Car Model" : selectedModel)
                                                    .font(Font.custom("Poppins", size: 14))
                                                    .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.50))
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .padding(EdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15))
                                            .background(Color(red: 0, green: 0, blue: 0).opacity(0.03))
                                            .cornerRadius(10)
                                            .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                            .inset(by: 0.50)
                                            .stroke(
                                            Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                                            )
                                            )
                                        }
                                    }
                                    
                                    if !selectedMake.isEmpty{
                                        Button(action: {
                                            if selectedModel.isEmpty {
                                                let newPair = MakeModelPair(make: selectedMake, model: selectedModel)
                                                makeModelList.append(newPair)
                                                updateFilters()
                                            }
                                            // Clear selections for next entry
                                            selectedMake = ""
                                            selectedModel = ""
                                        }) {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus")
                                                    .font(.system(size: 10))
                                                Text("Add another make")
                                                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                                                Spacer()
                                            }
                                            .foregroundColor(.hezzniGreen)
                                        }
                                    }
                                }
                            }
                            
                            // Year
                            filterSection(title: "Year", expandedState: .year) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("From")
                                        Picker("Start Year", selection: $startYear) {
                                            ForEach(1990...endYear, id: \.self) { year in
                                                Text("\(year)").tag(year)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        Spacer()
                                        Text("to")
                                        Picker("End Year", selection: $endYear) {
                                            ForEach(startYear...2025, id: \.self) { year in
                                                Text("\(year)").tag(year)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                    }
                                    .font(Font.custom("Poppins", size: 12))
                                }
                            }
                            
                            // Transmission
                            filterSection(title: "Transmission", expandedState: .transmission) {
                                VStack(spacing: 8) {
                                    ForEach(transmissions, id: \.self) { transmission in
                                        HStack {
                                            Image(systemName: transmissionTypes.contains(transmission) ? "checkmark.square.fill" : "square")
                                                .foregroundColor(transmissionTypes.contains(transmission) ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color.gray)
                                            
                                            Text(transmission)
                                                .font(Font.custom("Poppins", size: 14))
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            Text("(505)")
                                                .font(Font.custom("Poppins", size: 12))
                                                .foregroundColor(Color.gray)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if transmissionTypes.contains(transmission) {
                                                transmissionTypes.remove(transmission)
                                            } else {
                                                transmissionTypes.insert(transmission)
                                            }
                                            updateFilters()
                                        }
                                    }
                                }
                            }
                            
                            // Engine Type
                            filterSection(title: "Engine Type", expandedState: .engineType) {
                                VStack(spacing: 8) {
                                    ForEach(engines, id: \.self) { engine in
                                        HStack {
                                            Image(systemName: engineTypes.contains(engine) ? "checkmark.square.fill" : "square")
                                                .foregroundColor(engineTypes.contains(engine) ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color.gray)
                                            
                                            Text(engine)
                                                .font(Font.custom("Poppins", size: 14))
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            Text("(50)")
                                                .font(Font.custom("Poppins", size: 12))
                                                .foregroundColor(Color.gray)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            if engineTypes.contains(engine) {
                                                engineTypes.remove(engine)
                                            } else {
                                                engineTypes.insert(engine)
                                            }
                                            updateFilters()
                                        }
                                    }
                                }
                            }
                            
                            // Price Range
                            filterSection(title: "Price", expandedState: .price) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Min")
                                        TextField("Min", value: Binding(
                                            get: { Int(priceRange.lowerBound) },
                                            set: { priceRange = Double($0)...priceRange.upperBound }
                                        ), format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        Text("to")
                                        TextField("Max", value: Binding(
                                            get: { Int(priceRange.upperBound) },
                                            set: { priceRange = priceRange.lowerBound...Double($0) }
                                        ), format: .number)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                    .font(Font.custom("Poppins", size: 12))
                                    
                                    Slider(value: Binding(
                                        get: { priceRange.lowerBound },
                                        set: { priceRange = $0...priceRange.upperBound }
                                    ), in: 0...10000)
                                    .tint(Color(red: 0.22, green: 0.65, blue: 0.33))
                                    
                                    Slider(value: Binding(
                                        get: { priceRange.upperBound },
                                        set: { priceRange = priceRange.lowerBound...$0 }
                                    ), in: 0...10000)
                                    .tint(Color(red: 0.22, green: 0.65, blue: 0.33))
                                }
                            }
                        }
                        .padding(16)
                    }
                }
                
                // Apply Button
                Button(action: { isPresented = false }) {
                    Text("Apply Filter")
                        .font(Font.custom("Poppins", size: 14).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .cornerRadius(10)
                }
                .padding(16)
            }
            .background(Color.white)
        }
    }
    
    private var headerView: some View {
        HStack {
            EmptyView()
            Spacer()
            Text("Filter")
                .font(Font.custom("Poppins", size: 16).weight(.semibold))
                .foregroundColor(.black)
            Spacer()
            if !appliedFilters.isEmpty {
                clearAllButton
            }
            closeButton
        }
    }
    
    private var clearAllButton: some View {
        Button(action: {
            clearFilters()
        }) {
            Text("Clear all")
                .font(Font.custom("Poppins", size: 12).weight(.medium))
                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
        }
    }
    
    private var closeButton: some View {
        Button(action: {
            isPresented = false
        }) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
        }
    }
    
    private func filterSection<Content: View>(
        title: String,
        expandedState: FilterExpandedState,
        @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: filterState == expandedState ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .font(.system(size: 12, weight: .medium))
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if filterState == expandedState {
                    filterState = .none
                } else {
                    filterState = expandedState
                }
            }
            if filterState == expandedState {
                content()
            }
            Divider()
                .padding(.horizontal, -16)
        }
    }
    
    private func updateFilters() {
        appliedFilters.removeAll()
        if selectedStatus != "All" { appliedFilters.append(selectedStatus) }
        for pair in makeModelList {
            appliedFilters.append("\(pair.make) - \(pair.model)")
        }
        // Add year filter summary
        if startYear != 1990 || endYear != 2025 {
            appliedFilters.append("Year: \(startYear)-\(endYear)")
        }
    }
    
    private func clearFilters() {
        selectedStatus = "All"
        selectedMake = ""
        selectedModel = ""
        makeModelList.removeAll()
        transmissionTypes.removeAll()
        engineTypes.removeAll()
        appliedFilters.removeAll()
        startYear = 2000
        endYear = 2025
    }
    
    private func removeFilter(_ filter: String) {
        if filter == selectedStatus {
            selectedStatus = "All"
        }
        // Check if it's a make-model pair
        if let pairIndex = makeModelList.firstIndex(where: { "\($0.make) - \($0.model)" == filter }) {
            makeModelList.remove(at: pairIndex)
        }
        appliedFilters.removeAll { $0 == filter }
    }
}

#Preview {
    VehicleFiltersSheet(isPresented: .constant(true))
}
