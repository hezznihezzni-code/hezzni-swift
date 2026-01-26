//
//  AddWalletScreen.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/13/25.
//

import SwiftUI

struct AddWalletScreen: View {
    
    let wallets_banks = [
        "Bank of America",
        "Chase Bank",
        "Wells Fargo",
        "Citibank",
        "Capital One",
        "HSBC",
        "TD Bank",
        "PNC Bank",
        "US Bank",
        "BB&T",
        "SunTrust Bank",
        "Ally Bank",
        "Charles Schwab Bank",
        "Fifth Third Bank",
        "Regions Bank"
    ]
    @State private var selectedWallet_Bank: Int = -1
    @State private var showWalletPicker: Bool  = false
    @State private var accountHolderName: String = ""
    @State private var accountNumber: String = ""
    @State private var swiftCode: String = ""
    
    // Validation state
    @State private var attemptedSubmit: Bool = false
    @State private var accountHolderNameError: String? = nil
    @State private var selectedWalletBankError: String? = nil
    @State private var accountNumberError: String? = nil
    
    // Computed: enable Confirm only when required fields are present and valid
    var isFormValid: Bool {
        let holderOK = !accountHolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let bankOK = !wallets_banks[selectedWallet_Bank].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let accountOK = !accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && isValidAccountOrIBAN(accountNumber)
        return holderOK && bankOK && accountOK
    }
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack (spacing: 0){
            OnboardingAppBar(title: "Add Wallet or Bank", onBack: {
                dismiss()
            })
            Divider()
            ScrollView{
                VStack(spacing: 15){
                    // Account Holder Name
                    VStack(alignment: .leading, spacing: 4) {
                        FormField(title: "Account Holder Name", placeholder: "Enter account holder name", text: $accountHolderName)
                            .padding(.top, 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke((accountHolderNameError != nil && (attemptedSubmit || !accountHolderName.isEmpty)) ? Color.red : Color.clear, lineWidth: 1)
                            )
                        if let error = accountHolderNameError, attemptedSubmit || !accountHolderName.isEmpty {
                            Text(error)
                                .font(.poppins(.regular, size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Bank Name / Wallet Provider
                    VStack(alignment: .leading, spacing: 5) {
                        HStack {
                            Text("Bank Name / Wallet Provider")
                                .font(.poppins(.medium, size: 12))
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 5)
                        
                        Button(action: {
                            showWalletPicker = true
                        }) {
                            HStack(spacing: 8) {
                                Text(selectedWallet_Bank == -1 ? "Select bank or wallet" : wallets_banks[selectedWallet_Bank])
                                    .font(.poppins(.regular, size: 14))
                                    .foregroundColor(selectedWallet_Bank == -1 ? Color.black.opacity(0.4) : .black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .medium))
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.gray)
                            }
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 10))
                            .frame(height: 50)
                            .background(.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke((selectedWalletBankError != nil && (attemptedSubmit || !(selectedWallet_Bank == -1))) ? Color.red : Color.black.opacity(0.2), lineWidth: 0.5)
                            )
                            .shadow(color: Color(red: 0.02, green: 0.02, blue: 0.06, opacity: 0.06), radius: 50, y: 4)
                        }
                        if let error = selectedWalletBankError, attemptedSubmit || !(selectedWallet_Bank == -1) {
                            Text(error)
                                .font(.poppins(.regular, size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Account Number / IBAN
                    VStack(alignment: .leading, spacing: 4) {
                        FormField(title: "Account Number / IBAN", placeholder: "Enter account number or IBAN", text: $accountNumber)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke((accountNumberError != nil && (attemptedSubmit || !accountNumber.isEmpty)) ? Color.red : Color.clear, lineWidth: 1)
                            )
                        if let error = accountNumberError, attemptedSubmit || !accountNumber.isEmpty {
                            Text(error)
                                .font(.poppins(.regular, size: 12))
                                .foregroundColor(.red)
                        }
                    }
                    
                    // SWIFT / Bank Code (optional)
                    FormField(title: "SWIFT / Bank Code (optional)", placeholder: "Enter SWIFT or bank code", text: $swiftCode)
                   
                }
                .padding(.horizontal, 15)
            }
            .padding(.bottom, 24)
            Spacer()
            PrimaryButton(text: "Confirm", isEnabled: isFormValid, action: {
                attemptedSubmit = true
                checkValidity()
                if isFormValid {
                    // proceed with submission
                }
            })
            .padding(.horizontal, 15)
        }
        .sheet(isPresented: $showWalletPicker) {
            PickerPopup(
                title: "Select Bank / Wallet",
                currentSelected: $selectedWallet_Bank,
                list: wallets_banks,
                isPresented: $showWalletPicker
            )
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.hidden)
        }
        .navigationBarBackButtonHidden()
    }
        
    
    // MARK: - Validation helpers
    func checkValidity() {
        if accountHolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            accountHolderNameError = "Required"
        } else {
            accountHolderNameError = nil
        }
        if wallets_banks[selectedWallet_Bank].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            selectedWalletBankError = "Required"
        } else {
            selectedWalletBankError = nil
        }
        if accountNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            accountNumberError = "Required"
        } else if !isValidAccountOrIBAN(accountNumber) {
            accountNumberError = "Invalid Account or IBAN number"
        } else {
            accountNumberError = nil
        }
    }
    
    func isValidAccountOrIBAN(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // Basic check: IBAN-like (alphanumeric, 10-34) or numeric account (8-34)
        let ibanRegex = "^[A-Z0-9]{10,34}$"
        let accountRegex = "^[0-9]{8,34}$"
        let ibanPred = NSPredicate(format: "SELF MATCHES %@", ibanRegex)
        let accPred = NSPredicate(format: "SELF MATCHES %@", accountRegex)
        return ibanPred.evaluate(with: trimmed) || accPred.evaluate(with: trimmed)
    }
        
}

struct PickerPopup: View {
    var title: String
    @Binding var currentSelected: Int
    let list: [String]
    @Binding var isPresented: Bool
    @State private var temporarySelected: Int = -1
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .foregroundColor(.gray)
                
                Spacer()
                
                Text(title)
                    .font(.poppins(.semiBold, size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button("Done") {
                    if !(temporarySelected == -1) {
                        currentSelected = temporarySelected
                    }
                    isPresented = false
                }
                .foregroundColor(.hezzniGreen)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            Picker(title, selection: $temporarySelected) {
                ForEach(Array(list.enumerated()), id: \.offset) { index, element in
                    Text(element)
                        .font(.poppins(.regular, size: 16))
                        .tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding(.horizontal, 20)
            .onAppear {
                if list.isEmpty {
                    temporarySelected = -1
                } else {
                    temporarySelected = (currentSelected >= 0 && currentSelected < list.count) ? currentSelected : 0
                }
            }
            
            Spacer()
        }
        .background(Color.white)
    }
}


#Preview {
    AddWalletScreen()
}
