//
//  WalletFilterSheet.swift
//  Hezzni Driver
//

import SwiftUI

struct WalletFilterSheet: View {
    @Binding var filterState: FilterState
    @Environment(\.dismiss) private var dismiss
    @State private var localFilterState: FilterState
    
    init(filterState: Binding<FilterState>) {
        self._filterState = filterState
        self._localFilterState = State(initialValue: filterState.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Filter")
                    .font(Font.custom("Poppins", size: 18).weight(.semibold))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 10)
            Divider()
                .padding(.bottom, 10)
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    FilterSection(title: "Transaction Type") {
                        FilterChipGroup(
                            options: [TransactionType.all.rawValue, TransactionType.topUps.rawValue, TransactionType.serviceFee.rawValue],
                            selected: localFilterState.transactionType.rawValue,
                            onSelect: { value in
                                localFilterState.transactionType = TransactionType(rawValue: value) ?? .all
                                // Reset dependent filters when transaction type changes
                                if localFilterState.transactionType == .all {
                                    localFilterState.paymentMethod = .all
                                    localFilterState.rideType = .all
                                } else if localFilterState.transactionType == .topUps {
                                    localFilterState.rideType = .all
                                } else if localFilterState.transactionType == .serviceFee {
                                    localFilterState.paymentMethod = .all
                                }
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Show Payment Method only if transactionType is .topUps
                    if localFilterState.transactionType == .topUps {
                        FilterSection(title: "Payment Method") {
                            FilterChipGroup(
                                options: [PaymentMethod.all.rawValue, PaymentMethod.wafacash.rawValue, PaymentMethod.cashplus.rawValue, PaymentMethod.mastercard.rawValue, PaymentMethod.visa.rawValue, PaymentMethod.hezzniBonus.rawValue],
                                icons: ["", PaymentMethod.wafacash.icon, PaymentMethod.cashplus.icon, PaymentMethod.mastercard.icon, PaymentMethod.visa.icon, PaymentMethod.hezzniBonus.icon],
                                selected: localFilterState.paymentMethod.rawValue,
                                onSelect: { value in
                                    localFilterState.paymentMethod = PaymentMethod(rawValue: value) ?? .all
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Show Ride Type only if transactionType is .serviceFee
                    if localFilterState.transactionType == .serviceFee {
                        FilterSection(title: "Ride Type") {
                            FilterChipGroup(
                                options: RideType.allCases.map { $0.rawValue },
                                selected: localFilterState.rideType.rawValue,
                                onSelect: { value in
                                    localFilterState.rideType = RideType(rawValue: value) ?? .all
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Divider()
                    
                    FilterSection(title: "Date Range") {
                        FilterChipGroup(
                            options: DateRange.allCases.map { $0.rawValue },
                            selected: localFilterState.dateRange.rawValue,
                            onSelect: { value in
                                localFilterState.dateRange = DateRange(rawValue: value) ?? .all
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
            }
            
            Spacer()
            Divider()
                .padding(.vertical, 24)
            VStack(spacing: 12) {
                Button(action: {
                    filterState = localFilterState
                    dismiss()
                }) {
                    HStack(spacing: 8) {
                        Text("Apply Filter")
                            .font(Font.custom("Poppins", size: 15).weight(.medium))
                            .foregroundColor(.white)
                    }
                    .padding(10)
                    .frame(width: 372, height: 50)
                    .background(.black)
                    .cornerRadius(8)
                }
                
                Button(action: {
                    localFilterState.reset()
                }) {
                    HStack(spacing: 8) {
                        Text("Reset")
                            .font(Font.custom("Poppins", size: 15).weight(.medium))
                            .foregroundColor(.black)
                    }
                    .padding(10)
                    .frame(width: 372, height: 50)
                    .background(Color(red: 0.93, green: 0.93, blue: 0.93))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 20)
//            .padding(.bottom, 34)
        }
        .background(Color.white)
    }
}

struct FilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
            
            content
        }
    }
}

struct FilterChipGroup: View {
    let options: [String]
    var icons: [String] = []
    let selected: String
    let onSelect: (String) -> Void
    
    var body: some View {
        FlowLayout(spacing: 10) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                FilterChip(
                    title: option,
                    icon: icons.indices.contains(index) ? icons[index] : nil,
                    isSelected: selected == option,
                    onTap: { onSelect(option) }
                )
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    var icon: String?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let icon = icon, !icon.isEmpty {
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                }
                
                Text(title)
                    .font(Font.custom("Poppins", size: 13).weight(.medium))
                    .foregroundColor(isSelected ? .black : Color(red: 0.5, green: 0.5, blue: 0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.black : Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrangeSubviews(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY), proposal: .unspecified)
        }
    }
    
    private func arrangeSubviews(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var frames: [CGRect] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), frames)
    }
}

#Preview {
    WalletFilterSheet(filterState: .constant(FilterState()))
}
