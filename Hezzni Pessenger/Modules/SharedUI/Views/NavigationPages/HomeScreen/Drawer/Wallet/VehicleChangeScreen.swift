//
//  VehicleChangeScreen.swift
//  Hezzni Driver
//

import SwiftUI

enum DocumentStatus: String {
    case pending = "PENDING"
    case uploaded = "UPLOADED"
    case approved = "APPROVED"
    case rejected = "REJECTED"
    
    var color: Color {
        switch self {
        case .pending: return .black.opacity(0.05)
        case .uploaded: return Color.orange
        case .approved: return .hezzniGreen
        case .rejected: return Color.red
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .pending: return Color(red: 0.95, green: 0.95, blue: 0.95)
        case .uploaded: return Color.orange.opacity(0.15)
        case .approved: return Color.hezzniGreen.opacity(0.15)
        case .rejected: return Color.red.opacity(0.15)
        }
    }
}

struct VehicleDocument: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    var status: DocumentStatus
    var rejectionReason: String? = nil
}

struct VehicleChangeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var documents: [VehicleDocument] = [
        VehicleDocument(title: "National ID Card (CIN)", subtitle: "Government-issued identification.", status: .pending),
        VehicleDocument(title: "Driver's License", subtitle: "Valid and current driver's license.", status: .pending),
        VehicleDocument(title: "Pro Driver Card / Carte Professionnelle", subtitle: "Professional permit required for commercial drivers.", status: .pending),
        VehicleDocument(title: "Vehicle Registration (Carte Grise)", subtitle: "Proof of vehicle ownership.", status: .pending),
        VehicleDocument(title: "Vehicle Insurance", subtitle: "Add current vehicle insurance details.", status: .pending),
        VehicleDocument(title: "Vehicle Details", subtitle: "Provide make, model, and plate number.", status: .pending),
        VehicleDocument(title: "Vehicle Photos", subtitle: "Upload clear exterior photos of your vehicle.", status: .pending),
        VehicleDocument(title: "Face Verification", subtitle: "Take a selfie to confirm your identity.", status: .pending)
    ]
    @State private var showResultDialog = false
    @State private var isApproved = true
    
    var allDocumentsUploaded: Bool {
        documents.allSatisfy { $0.status != .pending }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingAppBar(title: "Vehicle Change", onBack: {
                dismiss()
            })
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Upload all required documents to update your vehicle details")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .padding(.horizontal, 16)
                    
                    ForEach($documents) { $document in
                        DocumentUploadRow(document: $document)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 16)
            }
            PrimaryButton(text: "Submit", isEnabled: allDocumentsUploaded) {
                isApproved = Bool.random()
                showResultDialog = true
            }
            .padding(.horizontal, 16)
            
            
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(isPresented: $showResultDialog) {
            VehicleChangeResultDialog(isApproved: isApproved) {
                showResultDialog = false
                if isApproved {
                    dismiss()
                }
            }
            .presentationDetents([.medium])
        }
    }
}

struct DocumentUploadRow: View {
    @Binding var document: VehicleDocument
    
    var body: some View {
        Button(action: {
            if document.status == .pending {
                document.status = .uploaded
            }
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(document.status.rawValue)
                            .font(Font.custom("Poppins", size: 10).weight(.medium))
                            .foregroundColor(document.status.color)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(document.status.backgroundColor)
                            .cornerRadius(4)
                    }
                    
                    Text(document.title)
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(document.subtitle)
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                        .multilineTextAlignment(.leading)
                    
                    if let reason = document.rejectionReason {
                        Text(reason)
                            .font(Font.custom("Poppins", size: 11))
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.92, green: 0.92, blue: 0.92), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }
}

struct VehicleChangeResultDialog: View {
    let isApproved: Bool
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            ZStack(alignment: .top){
                HStack{
                    Spacer()
                    Button(action: {onDismiss()}){
                        Image(systemName: "xmark")
                            .foregroundStyle(.black.opacity(0.3))
                    }
                }
                .padding(.horizontal, 16)
                    
                Image(isApproved ? "vehicle_approved" : "vehicle_declined")
                    .resizable()
                    .scaledToFit()
    //                    .frame(width: 200, height: 1)
                    .foregroundColor(isApproved ? .hezzniGreen : .red)
                    
            
            }
            
            VStack(spacing: 8) {
                Text(isApproved ? "Vehicle Change Approved!" : "Vehicle Change Request Declined")
                    .font(Font.custom("Poppins", size: 20).weight(.semibold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(isApproved ?
                     "Your new vehicle has been verified and is now ready for rides. Drive safe!" :
                     "Your submitted documents didn't meet the requirements. Please review and resubmit the correct details.")
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Text(isApproved ? "Got It" : "View Request")
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(isApproved ? Color.hezzniGreen : Color.red)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
//            .padding(.bottom, 30)
        }
        .background(Color.white)
    }
}

#Preview {
    VehicleChangeScreen()
}
