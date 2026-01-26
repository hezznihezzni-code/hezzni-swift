//
//  AddNewVehicleScreen.swift
//  Hezzni


import SwiftUI
import PhotosUI
struct AddNewVehicleScreen: View {
    @Binding var isPresented: Bool
    @State private var currentStep = 0
    @State private var vehicleName = ""
    @State private var pricePerDay = ""
    @State private var description = ""
    @State private var uploadedImages: [UIImage] = []
    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = ""
    @State private var licensePlate1: String = ""
    @State private var licensePlate2: String = ""
    @State private var licensePlate3: String = ""
    @State private var vehicleColor: String = ""
    @State private var numberOfSeats: String = ""
    @State private var region: String = ""
    @State private var city: String = ""
    @State private var selectedOption: String = ""
    // Single image binding replaced with an array of optional images for 6 slots
    @State private var vehicleImages: [UIImage?] = Array(repeating: nil, count: 6)
    let totalSteps = 5 // steps: 0-details,1-rental,2-photos,3-review,4-verification
    let statusOptions = ["Available", "Booked", "Under Review", "Rejected"]
    var totalTabs: Int { totalSteps }
    var currentTab: Int { currentStep }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                OnboardingAppBar(title: "Add New Vehicle", onBack: {})
                OnboardingTabBar(totalTabs: totalTabs, currentTab: currentTab)
                Divider()
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        if currentStep == 0 {
                            VehicleDetailsForm(
                                make: $make,
                                model: $model,
                                year: $year,
                                licensePlate1: $licensePlate1,
                                licensePlate2: $licensePlate2,
                                licensePlate3: $licensePlate3,
                                vehicleColor: $vehicleColor,
                                numberOfSeats: $numberOfSeats,
                                region: $region,
                                city: $city
                            )
                        } else if currentStep == 1 {
                            VStack(spacing: 22) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack{
                                        Text("Add Rental Details")
                                            .font(Font.custom("Poppins", size: 18).weight(.semibold))
                                            .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                                        Spacer()
                                    }
                                    Text("Set your vehicle’s availability and pricing preferences.")
                                        .font(Font.custom("Poppins", size: 12))
                                        .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                                }
                                VStack(alignment: .leading, spacing: 15) {
                                    // Price per Day
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack(spacing: 10) {
                                            Text("Price per Day (MAD)")
                                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                                .foregroundColor(.black)
                                        }
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                        TextField("Enter daily rental price", text: $pricePerDay)
                                            .font(Font.custom("Poppins", size: 14))
                                            .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.80))
                                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                                            .frame(height: 50)
                                            .background(.white)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .inset(by: 0.50)
                                                    .stroke(Color(red: 0, green: 0, blue: 0).opacity(0.20), lineWidth: 0.50)
                                            )
                                            .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
                                    }
                                    // Availability Status
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack(spacing: 10) {
                                            Text("Availability Status")
                                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                                .foregroundColor(.black)
                                        }
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                        
                                        Menu {
                                            ForEach(statusOptions, id: \.self) { option in
                                                Button(action: {
                                                    selectedOption = option
                                                }) {
                                                    Text(option)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                Text(selectedOption.isEmpty ? "Select Initial Status" : selectedOption)
                                                    .font(Font.custom("Poppins", size: 14))
                                                    .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.50))
                                                Spacer()
                                                Image(systemName: "chevron.down")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 12, weight: .medium))
                                            }
                                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                                            .frame(height: 50)
                                            .background(.white)
                                            .cornerRadius(10)
                                            .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                            .inset(by: 0.50)
                                            .stroke(
                                            Color(red: 0, green: 0, blue: 0).opacity(0.20), lineWidth: 0.50
                                            )
                                            )
                                            .shadow(
                                            color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4
                                            )
                                        }
                                    }
                                    // Description
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack(spacing: 10) {
                                            Text("Description")
                                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                                .foregroundColor(.black)
                                        }
                                        .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                                        ZStack(alignment: .topLeading) {
                                            TextEditor(text: $description)
                                                .font(Font.custom("Poppins", size: 14))
                                                .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.80))
                                                .padding(EdgeInsets(top: 12, leading: 15, bottom: 10, trailing: 10))
                                                .frame(height: 120)
                                                .background(.white)
                                                .cornerRadius(10)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .inset(by: 0.50)
                                                        .stroke(Color(red: 0, green: 0, blue: 0).opacity(0.20), lineWidth: 0.50)
                                                )
                                                .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
                                            if description.isEmpty {
                                                Text("Add a brief description highlighting your\nvehicle’s condition, features, or unique advantages")
                                                    .font(Font.custom("Poppins", size: 14))
                                                    .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.40))
                                                    .padding(EdgeInsets(top: 18, leading: 20, bottom: 0, trailing: 0))
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(16)
                        } else if currentStep == 2 {
                            VehicleImageUploader(
                                images: $vehicleImages,
                                label: "Upload Photos",
                                description: "Add clear photos of your vehicle for your listing.",
                                fileTypeDescription: "Max 6 images · Up to 5 MB each (.JPG or .PNG)"
                            )
                        } else if currentStep == 3 {
                            reviewDetailsStep
                        } else if currentStep == 4 {
                            verificationInProgressStep
                        }
                    }
                }
                
                // Next Button
                Button(action: { nextStep() }) {
                    Text(currentStep == totalSteps - 1 ? "Return" : "Next")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
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
    
    private var vehicleDescriptionStep: some View {
        VStack(spacing: 16) {
            Text("Vehicle Description")
                .font(Font.custom("Poppins", size: 18).weight(.semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextEditor(text: $description)
                .font(Font.custom("Poppins", size: 14))
                .frame(height: 150)
                .padding(8)
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                .cornerRadius(10)
        }
    }
    
    private var uploadPhotosStep: some View {
        VStack(spacing: 16) {
            Text("Upload Photos")
                .font(Font.custom("Poppins", size: 18).weight(.semibold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach(0..<6, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(Color.black.opacity(0.2))
                        .frame(height: 80)
                        .overlay(
                            VStack(spacing: 4) {
                                Image(systemName: "plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color.black.opacity(0.3))
                                Text("Add Photo")
                                    .font(Font.custom("Poppins", size: 12))
                                    .foregroundColor(Color.black.opacity(0.3))
                            }
                        )
                }
            }
        }
    }
    
    private var reviewDetailsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Review Your Details")
                    .font(Font.custom("Poppins", size: 20).weight(.semibold))
                    .foregroundColor(.black)
                Text("Double-check your information before adding.")
                    .font(Font.custom("Poppins", size: 13))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            
            // Vehicle details card (re-using VehicleInfoCard style)
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image("vehicle_filled_icon")
                        .foregroundColor(.hezzniGreen)
                    Text("Vehicle Details")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                }
                Divider()
                VStack(spacing: 12) {
                    ReviewInfoRow(label: "Make & Model", value: make + " " + model)
                    ReviewInfoRow(label: "Year", value: year)
                    ReviewInfoRow(label: "License Plate", value: "\(licensePlate1)-\(licensePlate2)-\(licensePlate3)")
                    ReviewInfoRow(label: "Color", value: vehicleColor)
                    ReviewInfoRow(label: "Number of Seats", value: numberOfSeats)
                }
            }
            .padding(17)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.50)
                    .stroke(Color.black.opacity(0.10), lineWidth: 0.50)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10)
            
            // Rental details card
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image("vehicle_filled_icon")
                        .foregroundColor(.hezzniGreen)
                    Text("Rental Details")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                }
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Price per Day")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color.gray)
                        Spacer()
                        Text("\(pricePerDay) MAD")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                    }
                    HStack {
                        Text("Availability Status")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color.gray)
                        Spacer()
                        Text(selectedOption.isEmpty ? "--" : selectedOption)
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.black)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(Color.gray)
                        Text(description.isEmpty ? "No description provided." : description)
                            .font(Font.custom("Poppins", size: 13))
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(17)
            .background(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.50)
                    .stroke(Color.black.opacity(0.10), lineWidth: 0.50)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10)
            
            // Photos uploaded grid
            VStack(alignment: .leading, spacing: 12) {
                Text("Photos Uploaded")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.black)
                
                let imagesToShow = vehicleImages.compactMap { $0 }
                if imagesToShow.isEmpty {
                    Text("No photos uploaded yet.")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color.gray)
                } else {
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(imagesToShow.enumerated()), id: \.offset) { item in
                            Image(uiImage: item.element)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    // MARK: - Final Verification Screen (currentStep == 4)
    private var verificationInProgressStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Image("under_review_vehicle") // ensure this asset exists
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260)
            VStack(spacing: 8) {
                Text("Verification in Progress")
                    .font(Font.custom("Poppins", size: 20).weight(.semibold))
                    .foregroundColor(.black)
                Text("Your vehicle details have been submitted and are under review. Approval may take up to 48 hours. We’ll notify you once your vehicle is approved and listed on Hezzni.")
                    .font(Font.custom("Poppins", size: 13))
                    .foregroundColor(Color.black.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
    
    private func nextStep() {
        withAnimation {
            if currentStep < totalSteps {
                currentStep += 1
            } else {
                // On final Return, dismiss the flow
                isPresented = false
            }
        }
    }
}

// Simple row used in review card to mirror VehicleInfoCard style
struct ReviewInfoRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label)
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            Spacer()
            Text(value)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    AddNewVehicleScreen(isPresented: .constant(true))
}


// MARK: - Multi-image uploader

struct VehicleImageUploader: View {
    @Binding var images: [UIImage?]   // 6 slots maximum
    let label: String
    let description: String?
    let fileTypeDescription: String
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    private let maxSlots = 6
    
    private var isFull: Bool {
        images.prefix(maxSlots).allSatisfy { $0 != nil }
    }
    
    private func binding(for index: Int) -> Binding<UIImage?> {
        Binding<UIImage?>(
            get: {
                if index < images.count { return images[index] }
                return nil
            },
            set: { newValue in
                if index < images.count {
                    images[index] = newValue
                }
            }
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(Font.custom("Poppins", size: 18).weight(.semibold))
                        .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
                    if let description = description {
                        Text(description)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                    }
                }
                Spacer()
            }
            
            VStack(spacing: 12) {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(0..<maxSlots, id: \.self) { index in
                        VehicleImageSlot(image: binding(for: index))
                    }
                }
                .padding(.horizontal, 20)
                
                Text(fileTypeDescription)
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if !isFull {
                    HStack(alignment: .top, spacing: 10) {
                        // Global Upload button: fill first empty slot via multi-selection picker
                        VehicleGlobalUploadButton(images: $images, maxSlots: maxSlots)
                        
                        // Take Photo button left as a visual-only button for now; you can wire camera later
                        HStack(spacing: 10) {
                            Image("take_picture_icon")
                                .foregroundStyle(.black)
                            Text("Take Photo")
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(.black)
                        }
                        .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .frame(height: 40)
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .inset(by: 0.50)
                                .stroke(
                                    Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                                )
                        )
                        .shadow(
                            color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
                        )
                    }
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .inset(by: 0.50)
                    .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
            )
        }
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
    }
}

// MARK: - Individual image slot

struct VehicleImageSlot: View {
    @Binding var image: UIImage?
    @State private var pickerItem: PhotosPickerItem?
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .stroke(Color.black.opacity(0.20), lineWidth: 1.5)
                    )
                
                Button(action: { image = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.red)
                        .background(Color.white.clipShape(Circle()))
                }
                .offset(x: 6, y: -6)
            } else {
                PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                    Image("upload_image")
                        .resizable()
                        .scaledToFit()
                        .opacity(0.6)
                        .frame(width: 90)
                        .foregroundColor(.clear)
                        .frame(width: 100, height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .inset(by: 1)
                                .stroke(Color.black.opacity(0.20), style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                        )
                }
                .onChange(of: pickerItem) { _, newItem in
                    guard let newItem else { return }
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            await MainActor.run {
                                self.image = uiImage
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 100, height: 100)
    }
}

// MARK: - Global upload button (multi-select)

struct VehicleGlobalUploadButton: View {
    @Binding var images: [UIImage?]
    let maxSlots: Int
    @State private var pickerItems: [PhotosPickerItem] = []
    
    private var remainingSlots: Int {
        max(0, maxSlots - images.prefix(maxSlots).filter { $0 != nil }.count)
    }
    
    var body: some View {
        PhotosPicker(
            selection: $pickerItems,
            maxSelectionCount: remainingSlots,
            matching: .images,
            photoLibrary: .shared()
        ) {
            HStack {
                Image("upload_icon")
                    .foregroundStyle(.hezzniGreen)
                Text("Upload")
                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
            }
            .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            .frame(height: 40)
            .background(.white)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .inset(by: 0.50)
                    .stroke(
                        Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                    )
            )
            .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 7
            )
        }
        .onChange(of: pickerItems) { _, newItems in
            guard !newItems.isEmpty else { return }
            Task {
                var uiImages: [UIImage] = []
                for item in newItems {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        uiImages.append(img)
                    }
                }
                if !uiImages.isEmpty {
                    await MainActor.run {
                        var remainingImages = uiImages
                        for index in 0..<maxSlots {
                            if images[index] == nil, !remainingImages.isEmpty {
                                images[index] = remainingImages.removeFirst()
                            }
                        }
                    }
                }
                await MainActor.run { pickerItems.removeAll() }
            }
        }
    }
}
