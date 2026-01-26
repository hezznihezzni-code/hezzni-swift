//
//  MyVehiclesScreen.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/21/25.
//

import SwiftUI

struct MyVehiclesScreen: View{
    @State private var selectedTab: Int = 0
    @State private var showAddVehicle = false
    @State private var showFilters = false
    @State private var searchText = ""
    @State private var selectedVehicle: RentalVehicle?
    @State private var showVehicleDetail = false
    
    var body: some View{
        NavigationStack{
            
            VStack{
                HStack{
                    Text("My Vehicles")
                        .font(Font.custom("Poppins", size: 18).weight(.medium))
                        .foregroundColor(.black)
                    Spacer()
                    HStack(spacing: 5) {
                        Image(systemName: "plus")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.hezzniGreen)
                        Text("Add New")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.hezzniGreen)
                    }
                    .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                //            // Tab Selection
                //            HStack(spacing: 0) {
                //                ForEach(["All", "Available", "Booked", "Rejected"], id: \.self) { tab in
                //                    Button(action: {
                //                        withAnimation { selectedTab = ["All", "Available", "Booked", "Rejected"].firstIndex(of: tab) ?? 0 }
                //                    }) {
                //                        Text(tab)
                //                            .font(Font.custom("Poppins", size: 13).weight(.medium))
                //                            .foregroundColor(selectedTab == ["All", "Available", "Booked", "Rejected"].firstIndex(of: tab) ?? 0 ? .black : Color.black.opacity(0.5))
                //                            .frame(maxWidth: .infinity)
                //                            .padding(.vertical, 12)
                //                            .background(selectedTab == ["All", "Available", "Booked", "Rejected"].firstIndex(of: tab) ?? 0 ? Color.white : Color.clear)
                //                            .cornerRadius(8)
                //                    }
                //                }
                //            }
                //            .padding(8)
                //            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                //            .cornerRadius(8)
                //            .padding(.horizontal, 16)
                //            .padding(.vertical, 12)
                
                // Search and Filter
                HStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.black.opacity(0.5))
                        TextField("Search your listed vehicles...", text: $searchText)
                            .font(Font.custom("Poppins", size: 14))
                    }
                    .padding(EdgeInsets(top: 10, leading: 11, bottom: 10, trailing: 11))
                    .frame(height: 40)
                    .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .inset(by: 0.50)
                            .stroke(Color(red: 0.87, green: 0.87, blue: 0.87), lineWidth: 0.50)
                    )
                    
                    Button(action: { showFilters = true }) {
                        HStack(spacing: 4) {
                            Image("filter_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .font(.system(size: 14))
                            Text("Filters")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                        }
                        .padding(EdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12))
                        .frame(height: 40)
                        .background(.black)
                        .cornerRadius(8)
                        .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 16)
                
                
                // Vehicles List
                ScrollView {
                    VStack(spacing: 12) {
                        HStack{
                            Text("34 Vehicles Listed")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                            
                            Spacer()
                        }
                        
                        ForEach(mockVehicles, id: \.id) { vehicle in
                            vehicleCard(vehicle)
                                .onTapGesture {
                                    selectedVehicle = vehicle
                                    showVehicleDetail = true
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .sheet(isPresented: $showFilters) {
                VehicleFiltersSheet(isPresented: $showFilters)
                    .presentationDetents([.large])
            }
            .sheet(isPresented: $showAddVehicle) {
                AddNewVehicleScreen(isPresented: $showAddVehicle)
            }
            .navigationDestination(isPresented: $showVehicleDetail) {
                if let vehicle = selectedVehicle {
                    VehicleDetailsScreen(/*vehicle: vehicle*/)
                }
            }
        }
        
    }
    private func vehicleCard(_ vehicle: RentalVehicle) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(vehicle.imageName)
                    .resizable()
                    .scaledToFill()
                    .foregroundColor(.clear)
                    .frame(width: 134.43)
                    .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack{
                        Text(vehicle.name)
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        Spacer()
                        VStack(alignment: .leading, spacing: 10) {
                            Image("vertical_dots")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 5, height: 15)
                                .foregroundStyle(Color(hex: "#DDDDDD"))
                        }
                        .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                    }
                    HStack{
                        VStack(alignment: .leading){
                            HStack(spacing: 2) {
                                Image("my-vehicles")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10, height: 10)
                                    
                                Text("\(vehicle.mileage) k-s")
                                    .font(Font.custom("Poppins", size: 10))
                            }
                            HStack(spacing: 2) {
                                Image("gear_shifter")
                                    .font(.system(size: 10))
                                Text(vehicle.transmission)
                                    .font(Font.custom("Poppins", size: 10))
                            }
                        }
                        Spacer()
                        VStack(alignment: .leading){
                            HStack(spacing: 2) {
                                Image("calendar_icon")
                                    .font(.system(size: 10))
                                Text("\(vehicle.year)")
                                    .font(Font.custom("Poppins", size: 10))
                            }
                            HStack(spacing: 2) {
                                Image("gas_icon")
                                    .font(.system(size: 10))
                                Text(vehicle.fuelType)
                                    .font(Font.custom("Poppins", size: 10))
                            }
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.black.opacity(0.6))
                    
                    
                    HStack{
                        HStack(alignment: .bottom,spacing: 2){
                            Text("MAD")
                                .font(Font.custom("Poppins", size: 12).weight(.semibold))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                            Text("\(vehicle.price)")
                                .font(Font.custom("Poppins", size: 16).weight(.semibold))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                            Text("/day")
                                .font(Font.custom("Poppins", size: 12).weight(.semibold))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        }
                        
                        Spacer()
                        
                        Text(vehicle.status)
                            .font(Font.custom("Poppins", size: 10).weight(.medium))
                            .foregroundColor(statusColor(vehicle.status))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor(vehicle.status).opacity(0.1))
                            .cornerRadius(6)
                        }
                    .padding(.top, 9.5)
                    }
                
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
    }
    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Available": return Color(red: 0.22, green: 0.65, blue: 0.33)
        case "Booked": return Color(red: 1.0, green: 0.76, blue: 0.03)
        case "Rejected": return Color(red: 0.83, green: 0.18, blue: 0.18)
        default: return Color.black
        }
    }
}

#Preview{
    MyVehiclesScreen()
}
