//
//  AddFunds.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/31/25.
//

import SwiftUI

struct AddFundsView: View {
    
    var pageTitle: String = "Add Funds"
    var withdrawFunds: Bool = false
    // Config
    let currencyCode: String = "MAD"
    let minAmount: Int = 20
    let maxAmount: Int = 5000
    let quickAmounts: [Int] = [50, 100, 150, 200, 500, 1000, 1500, 2000]
    let currentBalance: Decimal
    var onAddFunds: (Int) -> Void
    var onBack: (() -> Void)? = nil
    @State private var showReceipt: Bool = false

    // State
    @State private var rawDigits: String = "" // only 0-9
    @FocusState private var amountFocused: Bool

    // Environment
    @Environment(\.dismiss) private var dismiss

    // Derived
    private var amount: Int {
        Int(rawDigits) ?? 0
    }

    private var isTooLow: Bool { amount > 0 && amount < minAmount }
    private var isTooHigh: Bool { amount > maxAmount }
    private var isValid: Bool { amount >= minAmount && amount <= maxAmount }

    private var formattedAmount: String {
        NumberFormatter.groupedNumber.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }

    private var balanceLine: String {
        let fmt = NumberFormatter.currency(code: currencyCode)
        let current = fmt.string(from: currentBalance as NSDecimalNumber) ?? "-"
        if amount == 0 {
            return "current balance: \(current)"
        } else {
            let newBalance = (currentBalance as NSDecimalNumber).decimalValue + Decimal(amount)
            let new = fmt.string(from: newBalance as NSDecimalNumber) ?? "-"
            return "New balance: \(new)"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Nav
            VStack(spacing: 0){
                OnboardingAppBar(title:pageTitle, onBack: { dismiss() })
                    Divider()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    PaymentMethodCard(
                        logo: Image("wafcash")
                            .renderingMode(.original),
                        title: "Wafcash",
                        subtitle: "Mobile payment service"
                    )
                    
                    VStack(spacing: 12) {
                        Text("Enter Amount")
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.70))
                        
                        // Amount input
                        VStack(spacing: 6) {
                            Button {
                                amountFocused = true
                            } label: {
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(currencyCode)
                                        .font(Font.custom("Poppins", size: 32).weight(.medium))
                                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.50))
                                    Text(formattedAmount)
                                        .font(Font.custom("Poppins", size: 32).weight(.medium))
                                        .foregroundColor(.black)
                                        .contentTransition(.numericText())
                                }
                                //                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                            
                            
                            // underline + helper/error
                            VStack(spacing: 6) {
                                Rectangle()
                                    .fill(isTooLow || isTooHigh ? Color.red : Color.secondary.opacity(0.3))
                                    .frame(width: 135,height: 2)
                                
                                if isTooLow {
                                    Text("Minimum \(minAmount) \(currencyCode) required")
                                        .font(Font.custom("Poppins", size: 10))
                                        .foregroundColor(.red)
                                } else if isTooHigh {
                                    Text("Maximum \(maxAmount) \(currencyCode) required")
                                        .font(Font.custom("Poppins", size: 10))
                                        .foregroundColor(.red)
                                } else {
                                    Text(balanceLine)
                                        .font(Font.custom("Poppins", size: 10))
                                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.55))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Hidden numeric field that drives the amount
                        HiddenNumberPad(text: $rawDigits, focused: _amountFocused, maxDigits: 6)
                        
                        // Quick amount chips grid
                        QuickAmountGrid(
                            amounts: quickAmounts,
                            selected: amount,
                            tap: { setAmount($0) }
                        )
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 24)
                }
                .padding(.horizontal)
                .padding(.top, 4)
                .padding(.bottom, 100) // leave room for CTA above keyboard
            }
            
            // CTA
            VStack {
                
                PrimaryCTA(title: pageTitle, enabled: isValid) {
                    showReceipt = true
                    onAddFunds(amount)
                }
                
                
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            .background(.ultraThinMaterial)
            
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear { amountFocused = true }
        .animation(.easeInOut(duration: 0.18), value: isTooLow)
        .animation(.easeInOut(duration: 0.18), value: isTooHigh)
        .navigationDestination(isPresented: $showReceipt) {
            if !withdrawFunds {
                FundsAddReceipt(
                    code: "REFOGY8H5IXP",
                    amount: Decimal(amount),
                    currency: currencyCode,
                    customerName: "Ali Ch",
                    customerPhone: "+212 657 434 099",
                    createdAt: ISO8601DateFormatter().date(from: "2025-06-03T01:01:00+01:00") ?? Date(),
                    expiresAt: Date().addingTimeInterval(60 * 60 * 24)
                )
            } else {
                FundsWithdrawReceipt()
            }
        }
    }

    private func setAmount(_ value: Int) {
        rawDigits = String(value)
        amountFocused = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func dismissKeyboardAndPop() {
        amountFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        // If you are inside a NavigationStack, pop here if needed.
    }
}

// MARK: - Reusable subviews (replace with your project’s shared components if available)

private struct PaymentMethodCard: View {
    let logo: Image
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                
                logo
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
            .frame(width: 54, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(Font.custom("Poppins", size: 12))
                    .lineSpacing(13)
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.70))
            }
            Spacer()
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        .frame(height: 75)
        .cornerRadius(15)
        .overlay(
        RoundedRectangle(cornerRadius: 15)
        .inset(by: 0.50)
        .stroke(
        Color(red: 0, green: 0, blue: 0).opacity(0.20), lineWidth: 0.50
        )
        )
        .shadow(
        color: Color(red: 1, green: 1, blue: 1, opacity: 1), radius: 47, y: 4
        )
    }
}

private struct QuickAmountGrid: View {
    let amounts: [Int]
    let selected: Int
    var tap: (Int) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(amounts, id: \.self) { amt in
                Button {
                    tap(amt)
                } label: {
                    Text(NumberFormatter.groupedNumber.string(from: NSNumber(value: amt)) ?? "\(amt)")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(selected == amt ? .white : Color(hex:"#555555"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 3.76)
                                .fill(selected == amt ? Color.black : Color(hex: "#EEEEEE"))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct PrimaryCTA: View {
    let title: String
    let enabled: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 7.51)
                        .fill(enabled ? .hezzniGreen : .hezzniGreen.opacity(0.45))
                )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// Hidden number pad text field to capture digits and keep UI formatted label
private struct HiddenNumberPad: View {
    @Binding var text: String
    @FocusState var focused: Bool
    var maxDigits: Int = 6

    var body: some View {
        // Use a zero-sized field but keep it tappable via outer button
        TextField("", text: Binding(
            get: { text },
            set: { new in
                let digits = new.filter(\.isNumber)
                if digits.count <= maxDigits {
                    text = digits
                } else {
                    text = String(digits.prefix(maxDigits))
                }
            }
        ))
        .keyboardType(.numberPad)
        .focused($focused)
        .frame(width: 1, height: 1)
        .opacity(0.01)
        .accessibilityHidden(true)
    }
}

// MARK: - Formatters

private extension NumberFormatter {
    static let groupedNumber: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.usesGroupingSeparator = true
        nf.groupingSize = 3
        return nf
    }()

    static func currency(code: String) -> NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = code
        nf.maximumFractionDigits = 2
        nf.minimumFractionDigits = 2
        // Use grouping with comma to match mockups (adjust to locale if needed)
        nf.locale = Locale(identifier: "en_US_POSIX")
        return nf
    }
}

// MARK: - Preview

struct AddFundsView_Previews: PreviewProvider {
    static var previews: some View {
        AddFundsView(currentBalance: 55.66) { amount in
            print("Add funds: \(amount)")
        }
        .preferredColorScheme(.light)

        AddFundsView(currentBalance: 1055.66) { _ in }
            .previewDisplayName("Filled")
    }
}
