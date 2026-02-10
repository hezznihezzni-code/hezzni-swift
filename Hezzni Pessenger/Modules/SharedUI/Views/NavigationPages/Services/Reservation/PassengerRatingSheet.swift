//
//  PassengerRatingSheet.swift
//  Hezzni Pessenger
//
//  Rating sheet for passengers to rate their driver after ride completion
//

import SwiftUI

struct PassengerRatingSheet: View {
    let driverName: String
    var onSubmit: (Int, String?, [String]?) -> Void = { _, _, _ in }
    
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var selectedTags: Set<String> = []
    
    private let positiveTags = ["Smooth driving", "Great conversation", "Clean car", "On time", "Polite & friendly", "Safe driving"]
    private let negativeTags = ["Rude or unfriendly", "Unsafe driving", "Dirty car", "Wrong route", "Late pickup", "Bad communication"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How was your ride with \(driverName)?")
                .font(Font.custom("Poppins", size: 18).weight(.medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 36, height: 36)
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
            
            if rating > 0 && rating < 4 {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What went wrong?")
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                    
                    PassengerFlowLayout(spacing: 8) {
                        ForEach(negativeTags, id: \.self) { tag in
                            PassengerTagButton(text: tag, isSelected: selectedTags.contains(tag)) {
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
                    
                    PassengerFlowLayout(spacing: 8) {
                        ForEach(positiveTags, id: \.self) { tag in
                            PassengerTagButton(text: tag, isSelected: selectedTags.contains(tag)) {
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Additional comments...")
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
            
            Button(action: {
                onSubmit(
                    rating,
                    reviewText.isEmpty ? nil : reviewText,
                    selectedTags.isEmpty ? nil : Array(selectedTags)
                )
            }) {
                Text("Submit Review")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .cornerRadius(10)
            }
            .disabled(rating == 0)
            .opacity(rating == 0 ? 0.5 : 1.0)
            
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
}

// MARK: - Passenger Tag Button
struct PassengerTagButton: View {
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
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - Passenger Flow Layout for Tags
struct PassengerFlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            if index < result.positions.count {
                subview.place(at: CGPoint(
                    x: bounds.minX + result.positions[index].x,
                    y: bounds.minY + result.positions[index].y
                ), proposal: .unspecified)
            }
        }
    }
    
    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
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
            maxHeight = max(maxHeight, y + rowHeight)
        }
        
        return (positions, CGSize(width: maxWidth, height: maxHeight))
    }
}

#Preview {
    PassengerRatingSheet(driverName: "Ahmed Hassan")
}
