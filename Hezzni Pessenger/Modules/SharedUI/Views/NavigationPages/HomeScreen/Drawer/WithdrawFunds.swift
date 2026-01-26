//
//  WithdrawFunds.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/11/25.
//

import SwiftUI

struct WithdrawFunds: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddWalletScreen = false
    @State private var showWithdrawFundsScreen = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
               OnboardingAppBar(title: "Withdraw Funds", onBack: {
                   dismiss()
               })
                Divider()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        EarningsBalanceCard(balance: "55.66 MAD", showButtons: false)
                            .padding(.horizontal, 15)
                        VStack(alignment: .leading, spacing: 0){
                            Text("Choose Withdrawal Method")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(.black)
                            Text("Select how you’d like to receive your payout.")
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        }
                        .padding(.horizontal, 15)
                        VStack (spacing: 12){
                            WalletMethodCard(
                                title: "Hezzni Wallet",
                                subtitle: "Top up your Wallet using earnings",
                                onPress: {
                                    showWithdrawFundsScreen = true
                                }
                            )
                            .padding(.horizontal, 15)
                            WalletMethodCard(
                                image: "bank_icon",
                                title: "Attijariwafa Bank",
                                subtitle: "****8921",
                                onPress: {
                                    showWithdrawFundsScreen = true
                                }
                            )
                            .padding(.horizontal, 15)
                            WalletMethodCard(
                                image: "bank_icon",
                                title: "Add Bank Account",
                                subtitle: "Link a payout option",
                                isAddCard: true,
                                onPress: {
                                    showAddWalletScreen = true
                                }
                            )
                            .padding(.horizontal, 15)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showAddWalletScreen) {
                AddWalletScreen()
            }
            .navigationDestination(isPresented: $showWithdrawFundsScreen) {
                AddFundsView(pageTitle: "Withdraw Funds",withdrawFunds: true, currentBalance: 1055.66){ amount in
                    
                }
            }
        }
    }
}

struct WalletMethodCard: View {
    var image: String = "hezzni_wallet_icon_colored"
    let title: String
    let subtitle: String
    var isAddCard: Bool = false
    var onPress: (() -> Void)
    var body: some View {
        Button(
            action: onPress
        ){
            HStack(spacing: 80) {
                HStack(spacing: 11) {
                    VStack(spacing: nil) {
                        if isAddCard{
                            ZStack() {
                                Image(systemName: "plus")
                                    .foregroundStyle(Color(red: 0.84, green: 0.84, blue: 0.84))
                            }
                            .frame(width: 45, height: 45)
                            .cornerRadius(93.94)
                            .overlay(
                                RoundedRectangle(cornerRadius: 93.94)
                                    .inset(by: 0.47)
                                    .stroke(Color(red: 0.84, green: 0.84, blue: 0.84), style: StrokeStyle(lineWidth: 0.47, dash: [3,3]))
                            )
                        }else {
                            Image(image)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .frame(width: 30, height: 30)
                    .padding(.horizontal, 5)
                    HStack{
                        VStack(alignment: .leading, spacing: 3) {
                            Text(title)
                                .font(Font.custom("Poppins", size: 14).weight(.medium))
                                .foregroundColor(.black)
                            Text(subtitle)
                                .font(Font.custom("Poppins", size: 12))
                                .lineSpacing(13)
                                .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        }
                        Spacer()
                        if !isAddCard {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(.black.opacity(0.25))
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .frame(height: 80)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .inset(by: 0.50)
                    .stroke(
                        Color(red: 0.89, green: 0.89, blue: 0.89),
                        style: isAddCard ? StrokeStyle(lineWidth: 0.5, dash: [3,3]) : StrokeStyle(lineWidth: 0.5)
                    )
            )
            .shadow(
                color: Color(red: 1, green: 1, blue: 1, opacity: 1), radius: 47, y: 4
            )
        }
    }
}

#Preview {
    WithdrawFunds()
}
