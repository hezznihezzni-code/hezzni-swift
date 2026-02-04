//
//  VehicleInformationScreen.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/4/26.
//

import SwiftUI

struct VehicleInformationScreen: View {
    var onBack: (() -> Void)? = nil
    @State private var currentImageIndex = 0
    @State private var isFavorite = false
    
    // Sample data - replace with actual vehicle data
    let vehicleImages = ["vehicle1", "vehicle2", "vehicle3"] // Add more images
    let vehicleName = "Mercedes G Wagon"
    let location = "Marrakech"
    let price = 380
    let year = 2025
    let transmission = "Automatic"
    let fuelType = "Petrol"
    let color = "Black"
    let description = "Perfect for city driving and short trips around Marrakech. This reliable Toyota Corolla offers comfort and fuel efficiency for your travels."
    let rentalCompanyName = "Makao Car Rental"
    let rentalCompanyVerified = true
    let availableCars = "150+ cars available"
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Image Carousel
                    ZStack(alignment: .topLeading) {
                        TabView(selection: $currentImageIndex) {
                            ForEach(0..<12, id: \.self) { index in
                                Image("car_placeholder1")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 400)
                                    .clipped()
                                    .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 400)
                        
                        // Back button
                        Button(action: {
                            onBack?()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 20)
                        .padding(.top, 50)
                        
                        // Page indicator
                        HStack {
                            Text("1/12")
                                .font(Font.custom("Poppins", size: 16).weight(.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(20)
                        }
                        .padding(.leading, 20)
                        .padding(.top, 350)
                        
                        // Action buttons (heart and share)
                        HStack(spacing: 12) {
                            Button(action: {
                                isFavorite.toggle()
                            }) {
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 20))
                                    .foregroundColor(isFavorite ? .red : .black)
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            
                            Button(action: {
                                // Share action
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 20))
                                    .foregroundColor(.black.opacity(0.7))
                                    .frame(width: 48, height: 48)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 340)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    // Content
                    VStack(alignment: .center, spacing: 20) {
                        // Title and Location
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(vehicleName)
                                    .font(Font.custom("Poppins", size: 24).weight(.semibold))
                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                
                                HStack(spacing: 4) {
                                    Image("suggestion_pin")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.black.opacity(0.5))
                                    Text(location)
                                        .font(Font.custom("Poppins", size: 14))
                                        .foregroundColor(Color.black.opacity(0.5))
                                }
                            }
                            
                            Spacer()
                            
                            // Price
                            VStack(alignment: .trailing, spacing: 2) {
                                HStack(alignment: .bottom, spacing: 2) {
                                    Text("\(price)")
                                        .font(Font.custom("Poppins", size:16).weight(.bold))
                                        .foregroundColor(.white)
                                    Text("MAD/day")
                                        .font(Font.custom("Poppins", size: 10).weight(.medium))
                                        .foregroundColor(.white)
                                        .padding(.bottom, 4)
                                }
                            }
                            .padding(EdgeInsets(top: 5, leading: 8, bottom: 5, trailing: 8))
                            .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                            .cornerRadius(6)
                        }
                        .padding(.top, 20)
                        
                        // Specifications
                        HStack(spacing: 12) {
                            SpecificationCard(icon: "calendar_icon", title: String(year))
                            SpecificationCard(icon: "gear_shifter", title: transmission)
                            SpecificationCard(icon: "gas_icon", title: fuelType)
                            SpecificationCard(icon: "my-vehicles", title: color)
                        }
                        
                        // Description
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Description")
                                .font(Font.custom("Poppins", size: 18).weight(.semibold))
                                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                            
                            Text(description)
                                .font(Font.custom("Poppins", size: 14))
                                .foregroundColor(Color.black.opacity(0.5))
                                .lineSpacing(4)
                        }
                        .padding(.top, 8)
                        
                        // Rental Company Card
                        HStack(spacing: 12) {
                            // Company Logo
                            Image("company_logo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .background(Color.black)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(rentalCompanyName)
                                        .font(Font.custom("Poppins", size: 16).weight(.semibold))
                                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                    
                                    if rentalCompanyVerified {
                                        Image("verified_badge")
                                            .font(.poppins(size: 16))
                                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                                    }
                                }
                                Text("availableCars")
                                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                                    .foregroundColor(Color(red: 0.45, green: 0.44, blue: 0.44))
                            }
                            
                            Spacer()
                            
                            // Action Buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    // Message action
                                }) {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                                        .clipShape(Circle())
                                }
                                
                                Button(action: {
                                    // Call action
                                }) {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .frame(width: 48, height: 48)
                                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
                        .cornerRadius(12)
                        .padding(.top, 8)
                        
                        // Bottom spacing for floating button
                        Color.clear.frame(height: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .ignoresSafeArea(edges: .top)
            
//            // Floating Book Now Button
//            VStack {
//                Spacer()
//                
//                Button(action: {
//                    // Book now action
//                }) {
//                    Text("Book Now")
//                        .font(Font.custom("Poppins", size: 16).weight(.semibold))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
//                        .cornerRadius(12)
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 20)
//                .background(
//                    LinearGradient(
//                        gradient: Gradient(colors: [Color.white.opacity(0), Color.white]),
//                        startPoint: .top,
//                        endPoint: .bottom
//                    )
//                    .frame(height: 120)
//                    .allowsHitTesting(false)
//                )
//            }
        }
        .navigationBarHidden(true)
    }
}

struct SpecificationCard: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.black.opacity(0.6))
            
            Text(title)
                .font(Font.custom("Poppins", size: 12).weight(.medium))
                .foregroundColor(Color.black.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(red: 0.96, green: 0.96, blue: 0.96))
        .cornerRadius(12)
    }
}

#Preview {
    VehicleInformationScreen()
}
