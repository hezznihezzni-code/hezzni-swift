//WalletModels.swift
//  Hezzni Driver
//

import SwiftUI
internal import Combine

enum TransactionType: String, CaseIterable {
    case all = "All"
    case topUps = "Top-ups"
    case serviceFee = "Service Fee"
    case withdrawal = "Withdrawals"
    case tripEarnings = "Trip Earnings"
}

enum PaymentMethod: String, CaseIterable {
    case all = "All"
    case wafacash = "Wafacash"
    case cashplus = "Cashplus"
    case mastercard = "Mastercard"
    case visa = "Visa Card"
    case hezzniBonus = "Hezzni Bonus"
    case debitCard = "Debit Card"
    case hezzniWallet = "Hezzni Wallet"
    
    var icon: String {
        switch self {
        case .all: return ""
        case .wafacash: return "wafacash"
        case .cashplus: return "cashplus_icon"
        case .mastercard: return "mastercard"
        case .visa: return "visa"
        case .hezzniBonus: return "hezzni_bonus_icon"
        case .debitCard: return "debit_card_icon"
        case .hezzniWallet: return "hezzni_wallet_icon_colored"
        }
    }
}

enum RideType: String, CaseIterable {
    case all = "All"
    case standardRide = "Standard Ride"
    case comfortRide = "Comfort Ride"
    case xlRide = "XL Ride"
    case deliveryRide = "Delivery Ride"
    case cancellations = "Cancellations"
}

enum DateRange: String, CaseIterable {
    case all = "All"
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
}

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let amount: Decimal
    let currency: String
    let date: Date
    let time: String
    let type: TransactionType
    let method: PaymentMethod
    
    var isCredit: Bool {
        type == .tripEarnings || type == .topUps
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        let sign = isCredit ? "+ " : "- "
        let amountStr = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "\(sign)\(amountStr) \(currency)"
    }
    
    var amountColor: Color {
        isCredit ? Color(red: 0.13, green: 0.55, blue: 0.13) : Color(red: 0.8, green: 0.2, blue: 0.2)
    }
    
    var iconName: String {
        if !method.icon.isEmpty {
            return method.icon
        }
        switch type {
        case .topUps: return "wallet_topup_icon"
        case .serviceFee: return "service_fee_icon"
        case .withdrawal: return "withdrawal_icon"
        case .tripEarnings: return "trip_earnings_icon"
        default: return "wallet_icon"
        }
    }
}

struct TransactionSection: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let transactions: [Transaction]
}

struct FilterState {
    var transactionType: TransactionType = .all
    var paymentMethod: PaymentMethod = .all
    var rideType: RideType = .all
    var dateRange: DateRange = .all
    
    var isDefault: Bool {
        transactionType == .all && paymentMethod == .all && rideType == .all && dateRange == .all
    }
    
    mutating func reset() {
        transactionType = .all
        paymentMethod = .all
        rideType = .all
        dateRange = .all
    }
}

class WalletViewModel: ObservableObject {
    @Published var transactions: [TransactionSection] = []
    @Published var filterState = FilterState()
    @Published var walletBalance: Decimal = 55.66
    let currency = "MAD"
    
    var formattedWalletBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: walletBalance as NSDecimalNumber) ?? "\(walletBalance)"
    }
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        let today = Date()
        let calendar = Calendar.current
        let oct17 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 17)) ?? today
        let oct16 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 16)) ?? today
        let oct13 = calendar.date(from: DateComponents(year: 2025, month: 10, day: 13)) ?? today
        
        transactions = [
            TransactionSection(
                title: "Today",
                date: today,
                transactions: [
                    Transaction(title: "Wallet Top-Up", subtitle: "Mastercard •••• 4532", amount: 100.00, currency: currency, date: today, time: "11:03 AM", type: .topUps, method: .mastercard),
                    Transaction(title: "Wallet Top-Up", subtitle: "Visa Card •••• 4532", amount: 100.00, currency: currency, date: today, time: "11:03 AM", type: .topUps, method: .visa),
                    Transaction(title: "Wallet Top-Up", subtitle: "Cashplus", amount: 100.00, currency: currency, date: today, time: "11:02 AM", type: .topUps, method: .cashplus),
                    Transaction(title: "Wallet Top-Up", subtitle: "Wafacash", amount: 100.00, currency: currency, date: today, time: "11:02 AM", type: .topUps, method: .wafacash),
                    Transaction(title: "Hezzni Bonus", subtitle: "Credited by Hezzni", amount: 50.00, currency: currency, date: today, time: "11:03 AM", type: .topUps, method: .hezzniBonus),
                    Transaction(title: "Service Fee", subtitle: "Standard Ride", amount: 3.50, currency: currency, date: today, time: "11:03 AM", type: .serviceFee, method: .all),
                    Transaction(title: "Service Fee", subtitle: "Comfort Ride", amount: 3.50, currency: currency, date: today, time: "11:03 AM", type: .serviceFee, method: .all),
                    Transaction(title: "Service Fee", subtitle: "XL Ride", amount: 3.50, currency: currency, date: today, time: "11:03 AM", type: .serviceFee, method: .all),
                    Transaction(title: "Service Fee", subtitle: "Delivery Ride", amount: 3.50, currency: currency, date: today, time: "11:03 AM", type: .serviceFee, method: .all),
                    Transaction(title: "Service Fee", subtitle: "Cancellation Charge", amount: 3.50, currency: currency, date: today, time: "11:03 AM", type: .serviceFee, method: .all)
                ]
            ),
            TransactionSection(
                title: "17 Oct, 2025",
                date: oct17,
                transactions: [
                    Transaction(title: "Wallet Top-Up", subtitle: "Mastercard •••• 4532", amount: 100.00, currency: currency, date: oct17, time: "11:03 AM", type: .topUps, method: .mastercard),
                    Transaction(title: "Wallet Top-Up", subtitle: "Mastercard •••• 4532", amount: 100.00, currency: currency, date: oct17, time: "11:03 AM", type: .topUps, method: .mastercard)
                ]
            ),
            TransactionSection(
                title: "16 Oct, 2025",
                date: oct16,
                transactions: [
                    Transaction(title: "Wallet Top-Up", subtitle: "Mastercard •••• 4532", amount: 100.00, currency: currency, date: oct16, time: "11:03 AM", type: .topUps, method: .mastercard)
                ]
            ),
            TransactionSection(
                title: "13 Oct, 2025",
                date: oct13,
                transactions: [
                    Transaction(title: "Wallet Top-Up", subtitle: "Mastercard •••• 4532", amount: 100.00, currency: currency, date: oct13, time: "11:03 AM", type: .topUps, method: .mastercard),
                    Transaction(title: "Wallet Top-Up", subtitle: "Visa Card •••• 4532", amount: 100.00, currency: currency, date: oct13, time: "11:03 AM", type: .topUps, method: .visa),
                    Transaction(title: "Wallet Top-Up", subtitle: "Visa Card •••• 4532", amount: 100.00, currency: currency, date: oct13, time: "11:03 AM", type: .topUps, method: .visa)
                ]
            )
        ]
    }
    
    var filteredTransactions: [TransactionSection] {
        transactions.compactMap { section in
            let filtered = section.transactions.filter { transaction in
                let typeMatch = filterState.transactionType == .all || transaction.type == filterState.transactionType
                let methodMatch = filterState.paymentMethod == .all || transaction.method == filterState.paymentMethod
                return typeMatch && methodMatch
            }
            return filtered.isEmpty ? nil : TransactionSection(title: section.title, date: section.date, transactions: filtered)
        }
    }
}
