//
//  TransactionHistoryScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 11/4/25.
//

import SwiftUI
import Foundation

struct TransactionHistoryScreen: View {
    var onBack: (() -> Void)? = nil
    @EnvironmentObject private var navigationState: NavigationStateManager
    @State private var selectedPaymentMethod: MethodOfPayment? = nil
    var body: some View {
        ZStack{
            VStack{
                CustomAppBar(title: "Transaction History", backButtonAction: {
                    onBack?()
                })
                .padding(.horizontal, 16)
                ScrollView{
                    VStack{
                        WalletBalanceCard(
                            balance: "55.66 MAD",
                            subtitle: "Wallet Balance",
                            backgroundImage: "hezzni_wallet",
                            logo: {
                                Button(action: {}) {
                                    HStack(spacing: 0) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.white)
                                        Text("Top up")
                                            .font(Font.custom("Poppins", size: 9).weight(.regular))
                                            .foregroundColor(.white)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 16)
                                    .background(Color(red: 61/255, green: 120/255, blue: 74/255))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            },
                            infoText: "Virtual balance is non-redeemable and can only be used for Hezzni services."
                        )
                        .frame(height: 180)
                        ForEach(paymentMethods) { method in
                            Button(action: {
                                selectedPaymentMethod = method
                            }) {
                                TransactionHistoryCard(
                                    title: method.title,
                                    amount: method.isAddCard ? "" : "+ 55.66 MAD",
                                    amountColor: method.isAddCard ? .clear : Color(red: 0.22, green: 0.65, blue: 0.33),
                                    paymentMethodImage: method.iconName ?? "",
                                    paymentMethodText: method.cardNumber != nil ? "via \(method.title) •••• \(method.cardNumber!.suffix(4))" : method.subtitle,
                                    date: method.isAddCard ? "" : "03 Jun, 2025 at 12:00 PM"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedPaymentMethod) { method in
            TransactionDetailsSheet(
                type: "Top-up",
                transactionID: "REFOGY8H5IXP",
                amount: "250.00 MAD",
                method: "Debit Card",
                cardType: method.title,
                dateTime: "2023-10-01 14:30",
                status: "Completed",
                onClose: { selectedPaymentMethod = nil },
                onDownload: { /* handle download */ }
            )
            .presentationDetents([.medium])
        }
    }
}

struct TransactionDetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = Color(red: 0.09, green: 0.09, blue: 0.09)
    var valueFontWeight: Font.Weight = .regular
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Text(label)
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                Spacer()
                Text(value)
                    .font(Font.custom("Poppins", size: 14).weight(valueFontWeight))
                    .foregroundColor(valueColor)
            }
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 0)
                .overlay(
                    Rectangle()
                        .stroke(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08), lineWidth: 0.5)
                )
        }
    }
}

struct TransactionDetailsSheet: View {
    let type: String
    let transactionID: String
    let amount: String
    let method: String
    let cardType: String
    let dateTime: String
    let status: String
    var onClose: (() -> Void)? = nil
    var onDownload: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Transaction Details")
                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                    .lineSpacing(28.80)
                    .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.80))
                Spacer()
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.label))
                }
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            VStack(spacing: 10) {
                Group {
                    TransactionDetailRow(label: "Type", value: type)
                    Rectangle()
                        .foregroundStyle(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                        .frame(height: 1)
                    TransactionDetailRow(label: "Transaction ID", value: transactionID)
                    Rectangle()
                        .foregroundStyle(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                        .frame(height: 1)
                    TransactionDetailRow(label: "Amount", value: amount, valueColor: Color(red: 0.22, green: 0.65, blue: 0.33), valueFontWeight: .medium)
                    Rectangle()
                        .foregroundStyle(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                        .frame(height: 1)
                    TransactionDetailRow(label: "Method", value: method)
                    Rectangle()
                        .foregroundStyle(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                        .frame(height: 1)
                    TransactionDetailRow(label: "Card type", value: cardType)
                    Rectangle()
                        .foregroundStyle(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                        .frame(height: 1)
                }
                Group {
                    TransactionDetailRow(label: "Date & Time", value: dateTime)
                    Rectangle()
                        .foregroundStyle(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.08))
                        .frame(height: 1)
                    TransactionDetailRow(label: "Status", value: status)
                }
            }
            .padding(15)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.10), lineWidth: 0.5)
            )
            .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.05), radius: 10)
            .padding(.horizontal, 24)
            .padding(.top, 16)
            Spacer(minLength: 10)
            Button(action: { onDownload?() }) {
                HStack {
                    Image(systemName: "arrow.down.to.line")
                        .font(.system(size: 18, weight: .bold))
                    Text("Download Receipt")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .padding(.bottom, 10)
        }
        
        .background(.white)
        .cornerRadius(24)
        .ignoresSafeArea()
    }
}

struct MethodOfPayment: Identifiable {
    let id = UUID()
    let iconName: String?
    let title: String
    let subtitle: String
    let badge: String?
    let cardNumber: String?
    let isAddCard: Bool
    let cardHolder: String?
    let expiry: String?
}

let paymentMethods: [MethodOfPayment] = [
    .init(iconName: "wafcash", title: "Wafcash", subtitle: "Recharge your balance", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
    .init(iconName: "cashplus", title: "CashPlus", subtitle: "Recharge your balance", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
    .init(iconName: "visa", title: "Visa Card", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
    .init(iconName: "mastercard", title: "Mastercard", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
]

#Preview {
    
    TransactionHistoryScreen()
}
