//
//  Add_EditCard.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/30/25.
//

import SwiftUI

struct Add_EditCard: View {
    enum Mode { case add, edit }
    var mode: Mode = .edit
    var existing: Card? = nil
    var onSave: ((CardDetails) -> Void)? = nil
    var onBack: (() -> Void)? = nil
    
    // MARK: - State
    @State private var cardholderName: String = ""
    @State private var cardNumber: String = ""
    @State private var expiry: String = ""
    @State private var cvv: String = ""
    
    @State private var nameError: String? = nil
    @State private var numberError: String? = nil
    @State private var expiryError: String? = nil
    @State private var cvvError: String? = nil
    
    @State private var submitted: Bool = false
    
    // MARK: - Init with existing
    init(mode: Mode = .edit,
         existing: Card? = nil,
         onSave: ((CardDetails) -> Void)? = nil,
         onBack: (() -> Void)? = nil) {
        self.mode = mode
        self.existing = existing
        self.onSave = onSave
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomAppBar(title: mode == .edit ? "Edit Card" : "Add Card") {
                onBack?()
            }
            .padding(.horizontal, 16)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    // Cardholder Name
                    VStack(alignment: .leading, spacing: 8){
                        FieldLabel("Cardholder Name")
                        OutlinedField(
                            placeholder: "Enter card holder name",
                            text: $cardholderName,
                            isSecure: false,
                            error: nameError
                        )
                    }
                    
                    // Card Number
                    VStack(alignment: .leading, spacing: 8){
                        FieldLabel("Card Number")
                        OutlinedField(
                            placeholder: "0000 0000 0000 0000",
                            text: $cardNumber,
                            isSecure: false,
                            error: numberError,
                            trailing: {
                                if let brand = cardBrandIconName(numberOnly(cardNumber)) {
                                    Image(brand)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundStyle(Color(hex: "#172B85"))
                                        .frame(width: 28, height: 18)
                                }
                            }
                        )
                        .keyboardType(.numberPad)
                    }
                    
                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            FieldLabel("Expiry Date")
                            OutlinedField(
                                placeholder: "MM/YY",
                                text: $expiry,
                                isSecure: false,
                                error: expiryError
                            )
                            .keyboardType(.numberPad)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            FieldLabel("Security Code")
                            OutlinedField(
                                placeholder: "\u{2022}\u{2022}\u{2022}",
                                text: $cvv,
                                isSecure: true,
                                error: cvvError
                            )
                            .keyboardType(.numberPad)
                        }
                    }
                    
                    Spacer(minLength: 300)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }
            
            // Save Button
            PrimaryButton(
                text: mode == .edit ? "Save Changes" : "Add Card",
                isEnabled: isFormValid,
                isLoading: false,
                buttonColor: Color.hezzniGreen
            ) {
                submitted = true
                validateAll()
                guard isFormValid else { return }
                let details = CardDetails(
                    holder: cardholderName.trimmingCharacters(in: .whitespaces),
                    number: numberOnly(cardNumber),
                    formattedNumber: formattedCardNumber(numberOnly(cardNumber)),
                    expiry: normalizedExpiry(expiry),
                    cvv: cvv,
                    brandIcon: cardBrandIconName(numberOnly(cardNumber))
                )
                onSave?(details)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .background(Color.white)
        .onAppear { prefill() }
        .onChange(of: cardNumber) { _, newValue in
            let digits = numberOnly(newValue)
            let limited = String(digits.prefix(19))
            let formatted = formattedCardNumber(limited)
            if formatted != newValue {
                cardNumber = formatted
            }
            if submitted || !digits.isEmpty {
                validateCardNumber()
            }
        }
        .onChange(of: expiry) { _, newValue in
            let formatted = formattedExpiry(newValue)
            if formatted != newValue {
                expiry = formatted
            }
            if submitted || !newValue.isEmpty { validateExpiry() }
        }
        .onChange(of: cardholderName) { _, _ in
            if submitted || !cardholderName.isEmpty { validateName() }
        }
        .onChange(of: cvv) { _, newValue in
            let digits = numberOnly(newValue)
            let limit = isAmex(numberOnly(cardNumber)) ? 4 : 3
            let limited = String(digits.prefix(limit))
            if limited != newValue { cvv = limited }
            if submitted || !newValue.isEmpty { validateCVV() }
        }
        .navigationBarBackButtonHidden(true)
    }
        
    
    // MARK: - Prefill
    private func prefill() {
        if let existing = existing {
            cardholderName = existing.cardHolder ?? ""
            let number = existing.cardNumber?.replacingOccurrences(of: "*", with: "").replacingOccurrences(of: " ", with: "") ?? ""
            if !number.isEmpty {
                cardNumber = formattedCardNumber(number)
            }
            expiry = existing.expiry ?? ""
        }
    }
    
    // MARK: - Validation
    private var isFormValid: Bool {
        validateAll(silent: true)
        return nameError == nil && numberError == nil && expiryError == nil && cvvError == nil && !cardholderName.isEmpty && !cardNumber.isEmpty && !expiry.isEmpty && !cvv.isEmpty
    }
    
    private func validateAll(silent: Bool = false) {
        validateName()
        validateCardNumber()
        validateExpiry()
        validateCVV()
    }
    
    private func validateName() {
        let trimmed = cardholderName.trimmingCharacters(in: .whitespaces)
        nameError = trimmed.isEmpty ? "Required" : nil
    }
    
    private func validateCardNumber() {
        let digits = numberOnly(cardNumber)
        guard !digits.isEmpty else { numberError = "Required"; return }
        if digits.count < 13 || digits.count > 19 || !luhnCheck(digits) {
            numberError = "Invalid card number"
        } else {
            numberError = nil
        }
    }
    
    private func validateExpiry() {
        let norm = normalizedExpiry(expiry)
        guard !norm.isEmpty else { expiryError = "Required"; return }
        if !isValidExpiry(norm) { expiryError = "Invalid expiry" } else { expiryError = nil }
    }
    
    private func validateCVV() {
        let digits = numberOnly(cvv)
        guard !digits.isEmpty else { cvvError = "Required"; return }
        let needed = isAmex(numberOnly(cardNumber)) ? 4 : 3
        cvvError = digits.count == needed ? nil : "Invalid CVV"
    }
    
    // MARK: - Helpers
    struct CardDetails {
        let holder: String
        let number: String
        let formattedNumber: String
        let expiry: String // MM/YY
        let cvv: String
        let brandIcon: String?
    }
    
    private func numberOnly(_ s: String) -> String { s.filter { $0.isNumber } }
    
    private func formattedCardNumber(_ digits: String) -> String {
        // Simple 4-digit grouping
        let cleaned = digits.filter { $0.isNumber }
        var result: [String] = []
        var idx = cleaned.startIndex
        while idx < cleaned.endIndex {
            let next = cleaned.index(idx, offsetBy: 4, limitedBy: cleaned.endIndex) ?? cleaned.endIndex
            result.append(String(cleaned[idx..<next]))
            idx = next
        }
        return result.joined(separator: " ")
    }
    
    private func formattedExpiry(_ input: String) -> String {
        let digits = numberOnly(input)
        let capped = String(digits.prefix(4))
        if capped.count <= 2 { return capped }
        let mm = String(capped.prefix(2))
        let yy = String(capped.dropFirst(2))
        return mm + "/" + yy
    }
    
    private func normalizedExpiry(_ input: String) -> String {
        let parts = input.split(separator: "/").map(String.init)
        if parts.count == 2, parts[0].count == 2, parts[1].count == 2 { return input }
        return formattedExpiry(input)
    }
    
    private func isValidExpiry(_ mmYY: String) -> Bool {
        let comps = mmYY.split(separator: "/")
        guard comps.count == 2, let mm = Int(comps[0]), let yy = Int(comps[1]), (1...12).contains(mm) else { return false }
        // Compare with current date (YY): consider this month still valid
        let cal = Calendar.current
        let now = Date()
        let currentYearYY = cal.component(.year, from: now) % 100
        let currentMonth = cal.component(.month, from: now)
        if yy < currentYearYY { return false }
        if yy == currentYearYY && mm < currentMonth { return false }
        return true
    }
    
    private func luhnCheck(_ digits: String) -> Bool {
        var sum = 0
        let reversed = digits.reversed().map { Int(String($0)) ?? 0 }
        for (idx, num) in reversed.enumerated() {
            if idx % 2 == 1 {
                let doubled = num * 2
                sum += doubled > 9 ? doubled - 9 : doubled
            } else {
                sum += num
            }
        }
        return sum % 10 == 0
    }
    
    private func isAmex(_ digits: String) -> Bool {
        return digits.hasPrefix("34") || digits.hasPrefix("37")
    }
    
    private func cardBrandIconName(_ digits: String) -> String? {
        if digits.hasPrefix("4") { return "visa" }
        // Mastercard: 51-55 or 2221-2720
        if let firstTwo = Int(digits.prefix(2)), (51...55).contains(firstTwo) { return "mastercard" }
        if let firstFour = Int(digits.prefix(4)), (2221...2720).contains(firstFour) { return "mastercard" }
        return nil
    }
}

// MARK: - Subviews
private struct FieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.poppins(.medium, size: 14))
            .foregroundColor(.black)
    }
}

private struct OutlinedField<Trailing: View>: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool
    var error: String?
    var trailing: Trailing
    
    init(placeholder: String, text: Binding<String>, isSecure: Bool, error: String?, @ViewBuilder trailing: () -> Trailing) {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.error = error
        self.trailing = trailing()
    }
    
    // Convenience initializer when no trailing content is provided
    init(placeholder: String, text: Binding<String>, isSecure: Bool, error: String?) where Trailing == EmptyView {
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.error = error
        self.trailing = EmptyView()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.poppins(.regular, size: 14))
                        .textContentType(.password)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.poppins(.regular, size: 14))
                }
                trailing
            }
            .padding(14)
            .frame(height: 54)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(error == nil ? Color.black.opacity(0.2) : Color.red, lineWidth: 1)
            )
            .cornerRadius(12)
            .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
            if let error = error {
                Text(error)
                    .font(.poppins(.regular, size: 12))
                    .foregroundColor(.red)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack { Add_EditCard(mode: .edit, existing: Card(iconName: "mastercard", title: "Mastercard", subtitle: "", badge: nil, cardNumber: "", isAddCard: false, cardHolder: "", expiry: "")) { _ in } }
}
