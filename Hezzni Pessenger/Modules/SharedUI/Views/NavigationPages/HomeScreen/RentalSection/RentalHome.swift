//
//  RentalHome.swift
//  Hezzni
//
//  Rental Management - My Vehicles Screen

import SwiftUI

struct RentalHome: View {
    
    @State private var showAddVehicle = false
    @State private var showFilters = false
    @State private var searchText = ""
    @State private var selectedVehicle: RentalVehicle?
    @State private var showVehicleDetail = false
    
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .top) {
                Image("help_support_background")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Profile Section
                        HStack(spacing: 12) {
                            // Profile Image
                            Image("car_profile_placeholder")
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(800)
                                .font(.system(size: 30))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                                .frame(width: 53, height: 53)
                                .background{
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 55, height: 55)
                                    
                                }
                            
                            
                            
                            VStack(alignment: .leading, spacing: 4) {
                                
                                Text("Welcome Back!")
                                    .font(Font.custom("Poppins", size: 14))
                                    .foregroundColor(.white)
                                
                                
                                Text("Car Rental Company")
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(.white)
                                
                                
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                ZStack {
                                    circularButton(icon: "notification_bell_icon")
                                    notificationBadge
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                        
                        //                            headerSection
                        //
                        //                            StartConversationCard {
                        //                                showChatScreen = true
                        //                            }
                        //                            .padding(.horizontal, 16)
                        //                            .offset(y: -8)
                        //
                        //                            recentChatsSection
                        
                        // Header
                        VStack(spacing: 16) {
                            
                            // Vehicle Summary Cards
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("28")
                                            .font(Font.custom("Poppins", size: 36).weight(.medium))
                                            .foregroundColor(.black)
                                        Text("Total Vehicles")
                                            .font(Font.custom("Poppins", size: 14))
                                            .foregroundColor(Color.black.opacity(0.6))
                                    }
                                    Spacer()
                                    Image("total_vehicles")
                                        .resizable()
                                        .foregroundColor(.clear)
                                        .frame(width: 129, height: 86)
                                        .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                                }
                                HStack(spacing: 12) {
                                    Button(action: {}) {
                                        Text("View All")
                                            .font(Font.custom("Poppins", size: 12).weight(.medium))
                                            .foregroundColor(Color.black.opacity(0.7))
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 40)
                                            .background(Color(red: 0.93, green: 0.93, blue: 0.93))
                                            .cornerRadius(10)
                                    }
                                    
                                    Button(action: { showAddVehicle = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "plus")
                                                .font(.system(size: 12, weight: .semibold))
                                            Text("Add Vehicle")
                                        }
                                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                                        .cornerRadius(10)
                                    }
                                }
                            }
                            .padding(13)
                            .frame(width: 362)
                            .background(.white)
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .inset(by: 0.50)
                                    .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
                            )
                            .shadow(
                                color: Color(red: 0, green: 0, blue: 0, opacity: 0.10), radius: 10
                            )
                            VStack{
                                
                                
                                
                                HStack(spacing: 16) {
                                    statusCard(title: "Available", count: "18", icon: "available_vehicle", )
                                    statusCard(title: "Booked", count: "6", icon: "booked_vehicle", )
                                }
                                
                                HStack(spacing: 16) {
                                    statusCard(title: "Under Review", count: "16", icon: "under_review_vehicle")
                                    statusCard(title: "Rejected", count: "4", icon: "rejected_vehicle")
                                }
                            }
                            
                            
                        }
                        .padding(16)
                        
                        
                    }
                    
                    .fullScreenCover(isPresented: $showAddVehicle) {
                        AddNewVehicleScreen(isPresented: $showAddVehicle)
                    }
                    
                    
                    
                }
                
            }
                .background(
                    LinearGradient(
                        colors: [Color.white, Color.white.opacity(0.98), Color(red: 0.93, green: 0.98, blue: 0.94)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .navigationBarHidden(true)
//                .navigationDestination(isPresented: $showChatScreen) {
//                    ChatBotScreen()
//                }
            
            
        }
    }
    
    private func statusCard(title: String, count: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack{
                HStack{
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color.black.opacity(0.6))
                        Text(count)
                            .font(Font.custom("Poppins", size: 24).weight(.medium))
                            .foregroundColor(.black)
                        
                    }
                    Spacer()
                }
                Spacer()
            }
            .overlay(alignment: .bottom){
                HStack {
                    
                    
                    Spacer()
                    Image(icon)
                        .resizable()
                        .foregroundColor(.clear)
                        .frame(width: 107, height: 107)
                        .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                }
            }
            
        }
        .padding(13)
        .frame(height: 160)
        .background(.white)
        .cornerRadius(15)
        .overlay(
        RoundedRectangle(cornerRadius: 15)
        .inset(by: 0.50)
        .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
        )
        .shadow(
        color: Color(red: 0, green: 0, blue: 0, opacity: 0.10), radius: 10
        )
    }
    
    
}

// MARK: - Models
struct RentalVehicle: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let mileage: Int
    let transmission: String
    let fuelType: String
    let price: Int
    let status: String
    let make: String
    let model: String
    let year: Int
    let licensePlate: String
}

let mockVehicles = [
    RentalVehicle(name: "Dacia Logan", imageName: "car_placeholder1", mileage: 12000, transmission: "Automatic", fuelType: "Gas", price: 380, status: "Available", make: "Dacia", model: "Logan", year: 2020, licensePlate: "12345-A-6"),
    RentalVehicle(name: "Dacia Logan", imageName: "car_placeholder1", mileage: 12000, transmission: "Automatic", fuelType: "Gas", price: 380, status: "Available", make: "Dacia", model: "Logan", year: 2020, licensePlate: "12345-A-6"),
    RentalVehicle(name: "Dacia Logan", imageName: "car_placeholder1", mileage: 12000, transmission: "Automatic", fuelType: "Gas", price: 380, status: "Booked", make: "Dacia", model: "Logan", year: 2020, licensePlate: "12345-A-6"),
]

#Preview {
    RentalHome()
}
