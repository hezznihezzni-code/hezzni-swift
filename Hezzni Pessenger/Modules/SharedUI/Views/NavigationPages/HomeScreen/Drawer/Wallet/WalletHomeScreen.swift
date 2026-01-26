//
//  WalletHomeScreen.swift
//  Hezzni Driver
//

import SwiftUI

struct WalletHomeScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = WalletViewModel()
    @State private var showWalletHistory = false
    @State private var showAddFunds = false
    @State private var showAddTopUp = false
    @State private var showManagePayments = false
    @State private var showAddCardScreen = false
    
    var body: some View {
        
            VStack(spacing: 0) {
                OnboardingAppBar(title: "Hezzni Wallet", onBack: {
                    dismiss()
                })
                Divider()
                
                ScrollView {
                    VStack(spacing: 12) {
                        WalletBalanceCard(
                            balance: "\(viewModel.formattedWalletBalance) \(viewModel.currency)",
                            subtitle: "Wallet Balance",
                            backgroundImage: "hezzni_wallet",
                            logo: { Image("logo_white").resizable()
                                .frame(width: 40, height: 40) },
                            infoText: "Wallet balance is non-redeemable and can only be used for Hezzni services."
                        )
                        
                        
                        VStack(spacing: 12) {
                            WalletActionCard(
                                icon: "wallet_history_icon",
                                iconBackgroundColor: Color(red: 0.91, green: 0.96, blue: 0.92),
                                title: "View Wallet History",
                                subtitle: "See your top-ups, bonuses and service fee deductions",
                                onTap: {
                                    showWalletHistory = true
                                }
                            )
                            
                            WalletActionCard(
                                icon: "top_up_icon",
                                iconBackgroundColor: Color(red: 0.91, green: 0.96, blue: 0.92),
                                title: "Top Up Wallet",
                                subtitle: "Add funds to your Hezzni Wallet",
                                onTap: {
                                    showAddFunds = true
                                }
                            )
                            
                            WalletActionCard(
                                icon: "manage_payments_icon",
                                iconBackgroundColor: Color(red: 0.91, green: 0.96, blue: 0.92),
                                title: "Manage Payment Methods",
                                subtitle: "Edit or remove your saved payment options",
                                onTap: {
                                    showManagePayments = true
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 16)
                }
            }
            .background(Color.white)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showWalletHistory) {
                WalletHistoryScreen()
            }
            .navigationDestination(isPresented: $showAddFunds) {
                WalletTopUpScreen(onAddFunds: {
                    showAddTopUp = true
                })
            }
            .navigationDestination(isPresented: $showManagePayments) {
                PaymentMethodScreen(onEditCard: { card in
                    
                },onAddCard: {
                    showAddCardScreen = true
                }, isManagePayment: true)
            }
            .navigationDestination(isPresented: $showAddCardScreen) {
                Add_EditCard()
            }
            .navigationDestination(isPresented: $showAddTopUp){
                AddFundsView(currentBalance: viewModel.walletBalance) { amount in
                                    print("Added funds: \(amount)")
                                }
            }
        }
    
}

struct WalletActionCard: View {
    let icon: String
    var iconBackgroundColor: Color = Color(red: 0.91, green: 0.96, blue: 0.92)
    let title: String
    let subtitle: String
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: { onTap?() }) {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(iconBackgroundColor)
                        .frame(width: 44, height: 44)
                    
                    Image(icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.hezzniGreen)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.hezzniGreen)
                    
                    Text(subtitle)
                        .font(Font.custom("Poppins", size: 13))
                        .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.92, green: 0.92, blue: 0.92), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WalletHomeScreen()
}
