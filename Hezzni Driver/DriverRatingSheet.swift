//
//  DriverRatingSheet.swift
//  Hezzni Driver
//
//  Rating sheet for drivers to rate passengers after ride completion
//

import SwiftUI

struct DriverRatingSheet: View {
    let passengerName: String
    let passengerImageUrl: String?
    let rideRequestId: Int
    var onSubmit: () -> Void = {}
    var onSkip: () -> Void = {}
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var isSubmitting: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private let positiveTags = ["Polite", "On time at pickup", "Great conversation", "Friendly", "Respectful"]
    private let negativeTags = ["Rude", "Late at pickup", "Messy", "Disrespectful", "Made me wait too long"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Text("Rate Your Passenger")
                .font(Font.custom("Poppins", size: 20).weight(.semibold))
                .foregroundColor(.black)
            
            // Passenger info
            VStack(spacing: 8) {
                // Passenger image
                AsyncImage(url: URL(string: passengerImageUrl ?? "")) { phase in
                    switch phase {
                    case .empty, .failure:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    @unknown default:
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 80)
                    }
                }
                
                Text(passengerName)
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .foregroundColor(.black)
            }
            
            // Star rating
            Text("How was your ride with \(passengerName)?")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(.black.opacity(0.6))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(rating >= 4 ? Color(red: 0.22, green: 0.65, blue: 0.33) : (rating >= 3 ? .yellow : .orange))
                        .onTapGesture {
                            withAnimation { rating = index }
                        }
                }
            }
            
            if rating > 0 {
                Text(getRatingLabel())
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color.black.opacity(0.6))
            }
            
            // Tags based on rating
            if rating > 0 && rating < 4 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What went wrong?")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                    
                    DriverFlowLayout(spacing: 8) {
                        ForEach(negativeTags, id: \.self) { tag in
                            DriverTagButton(text: tag, isSelected: selectedTags.contains(tag)) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
            }
            
            if rating >= 4 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What did you enjoy?")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                    
                    DriverFlowLayout(spacing: 8) {
                        ForEach(positiveTags, id: \.self) { tag in
                            DriverTagButton(text: tag, isSelected: selectedTags.contains(tag)) {
                                if selectedTags.contains(tag) {
                                    selectedTags.remove(tag)
                                } else {
                                    selectedTags.insert(tag)
                                }
                            }
                        }
                    }
                }
            }
            
            // Comment text field
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional comments (optional)")
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color.black.opacity(0.5))
                
                TextEditor(text: $reviewText)
                    .font(Font.custom("Poppins", size: 14))
                    .frame(height: 80)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black.opacity(0.2), lineWidth: 0.5)
                    )
            }
            
            // Error message
            if showError {
                Text(errorMessage)
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(.red)
            }
            
            // Submit button
            Button(action: submitReview) {
                HStack {
                    if isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    }
                    Text(isSubmitting ? "Submitting..." : "Submit Review")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                .cornerRadius(10)
            }
            .disabled(rating == 0 || isSubmitting)
            .opacity(rating == 0 ? 0.5 : 1.0)
            
            // Skip button
            Button(action: onSkip) {
                Text("Skip")
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(20)
        .background(.white)
    }
    
    private func getRatingLabel() -> String {
        switch rating {
        case 1: return "Poor"
        case 2: return "Needs Improvement"
        case 3: return "Satisfactory"
        case 4: return "Great!"
        case 5: return "Amazing!"
        default: return ""
        }
    }
    
    private func submitReview() {
        isSubmitting = true
        showError = false
        
        Task {
            do {
                let tags = selectedTags.isEmpty ? nil : Array(selectedTags)
                let comment = reviewText.isEmpty ? nil : reviewText
                
                _ = try await APIService.shared.submitPassengerReview(
                    rideRequestId: rideRequestId,
                    rating: rating,
                    comment: comment,
                    tags: tags
                )
                
                await MainActor.run {
                    isSubmitting = false
                    onSubmit()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    showError = true
                    errorMessage = "Failed to submit review. Please try again."
                }
            }
        }
    }
}

// MARK: - Driver Tag Button
struct DriverTagButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(Font.custom("Poppins", size: 12))
                .foregroundColor(isSelected ? .white : Color.black.opacity(0.7))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : Color.black.opacity(0.2), lineWidth: 0.5)
                )
                .cornerRadius(20)
        }
    }
}

// MARK: - Driver Flow Layout (for wrapping tags)
struct DriverFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.origin.x, y: bounds.minY + frame.origin.y), proposal: .unspecified)
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var frames: [CGRect] = []
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        return (CGSize(width: maxWidth, height: currentY + lineHeight), frames)
    }
    
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
//        return result.size
//    }
//    
//    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
//        for (index, subview) in subviews.enumerated() {
//            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
//        }
//    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }
            self.size.height = y + rowHeight
        }
    }
}

#Preview {
    DriverRatingSheet(
        passengerName: "John Doe",
        passengerImageUrl: nil,
        rideRequestId: 123
    )
}
