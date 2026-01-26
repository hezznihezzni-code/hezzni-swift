//
//  EarningsScreen.swift
//  Hezzni Driver
//

import SwiftUI

struct EarningsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPeriod: String = "Today"
    @State private var showWalletHistory = false
    @State private var showWithdrawFunds = false
    
    let periods = ["Today", "Weekly", "Monthly"]
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingAppBar(title: "Earnings", onBack: {
                dismiss()
            })
            Divider()
            
            ScrollView {
                VStack(spacing: 13) {
                    EarningsBalanceCard(
                        balance: "55.66 MAD",
                        showButtons: true,
                        onWithdraw: { showWithdrawFunds = true },
                        onViewHistory: { showWalletHistory = true }
                    )
                    .padding(.horizontal, 16)
                    
                    HStack(spacing: 0) {
                        ForEach(periods, id: \.self) { period in
                            PeriodTab(
                                title: period,
                                isSelected: selectedPeriod == period,
                                onTap: { selectedPeriod = period }
                            )
                        }
                    }
                    .padding(4)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    
                    EarningsBarChartCard()
                    EarningsStatsCard()
                    Spacer()
                }
                .padding(.bottom, 100)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $showWalletHistory) {
            WalletHistoryScreen()
        }
        .navigationDestination(isPresented: $showWithdrawFunds) {
            WithdrawFunds()
        }
    }
}
//
//struct EarningsBalanceCard: View {
//    let balance: String
//    var showButtons: Bool = true
//    var onWithdraw: (() -> Void)? = nil
//    var onViewHistory: (() -> Void)? = nil
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            LinearGradient(
//                colors: [
//                    Color(red: 0.22, green: 0.65, blue: 0.33),
//                    Color(red: 0.15, green: 0.50, blue: 0.28)
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .cornerRadius(20)
//
//            VStack(alignment: .leading, spacing: 12) {
//                Text("Earnings Balance")
//                    .font(Font.custom("Poppins", size: 13))
//                    .foregroundColor(.white.opacity(0.85))
//
//                Text(balance)
//                    .font(Font.custom("Poppins", size: 32).weight(.semibold))
//                    .foregroundColor(.white)
//
//                Text("Earnings ready to withdraw")
//                    .font(Font.custom("Poppins", size: 11))
//                    .foregroundColor(.white.opacity(0.7))
//
//                if showButtons {
//                    VStack(spacing: 10) {
//                        Button(action: { onWithdraw?() }) {
//                            Text("Withdraw")
//                                .font(Font.custom("Poppins", size: 14).weight(.medium))
//                                .foregroundColor(.hezzniGreen)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 44)
//                                .background(Color.white)
//                                .cornerRadius(10)
//                        }
//
//                        Button(action: { onViewHistory?() }) {
//                            Text("View History")
//                                .font(Font.custom("Poppins", size: 14).weight(.medium))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .frame(height: 44)
//                                .background(Color.white.opacity(0.2))
//                                .cornerRadius(10)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
//                                )
//                        }
//                    }
//                    .padding(.top, 8)
//                }
//            }
//            .padding(24)
//        }
//        .frame(height: showButtons ? 240 : 140)
//    }
//}

struct PeriodTab: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(Font.custom("Poppins", size: 13).weight(.medium))
                .foregroundColor(isSelected ? .black : Color(red: 0.5, green: 0.5, blue: 0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? Color.white : Color.clear)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.custom("Poppins", size: 12))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            
            Text(value)
                .font(Font.custom("Poppins", size: 24).weight(.semibold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.92, green: 0.92, blue: 0.92), lineWidth: 1)
        )
    }
}

struct EarningsChartView: View {
    let data: [CGFloat] = [0.1, 0.3, 0.15, 0.5, 0.35, 0.45, 0.25, 0.1]
    let labels = ["12 AM", "3 AM", "6 AM", "9 AM", "12 PM", "3 PM", "6 PM", "9 PM"]
    
    var body: some View {
        GeometryReader { geometry in
            let barWidth: CGFloat = 24
            let spacing = (geometry.size.width - barWidth * CGFloat(data.count)) / CGFloat(data.count + 1)
            
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: spacing) {
                    ForEach(0..<data.count, id: \.self) { index in
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.hezzniGreen.opacity(0.3))
                                .frame(width: barWidth, height: max(20, data[index] * (geometry.size.height - 40)))
                        }
                    }
                }
                .frame(height: geometry.size.height - 30)
                
                HStack(spacing: 0) {
                    ForEach(labels, id: \.self) { label in
                        Text(label)
                            .font(Font.custom("Poppins", size: 9))
                            .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

#Preview {
    EarningsScreen()
}

#Preview{
    EarningsBalanceCard(
        balance: "55.66 MAD",
        showButtons: true,
        onWithdraw: {},
        onViewHistory: {}
    )
}
