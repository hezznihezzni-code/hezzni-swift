//
//  WalletHistoryScreen.swift
//  Hezzni Driver
//

import SwiftUI

struct WalletHistoryScreen: View {
    @Environment(\.dismiss) private var pop
    @StateObject private var viewModel = WalletViewModel()
    @State private var showFilterSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            CustomAppBar(
                title: "Wallet History",
                backButtonAction: { pop() },
                trailingView: {
                    Button(action: { showFilterSheet = true }) {
                        Image("filter_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.black)
                    }
                }
            )
            .padding(.bottom, 10)
            .padding(.horizontal, 16)
            
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.filteredTransactions) { section in
                        TransactionSectionView(section: section)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .sheet(isPresented: $showFilterSheet) {
            WalletFilterSheet(filterState: $viewModel.filterState)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }
}

struct TransactionSectionView: View {
    let section: TransactionSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(section.title)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                .padding(.top, 20)
                .padding(.bottom, 8)
            
            ForEach(section.transactions) { transaction in
                TransactionRowView(transaction: transaction)
            }
        }
        
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {

                
                Image(transaction.method.icon.isEmpty ? "hezzni_bonus_icon" : transaction.method.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 7)
                        .inset(by: 0.50)
                        .stroke(
                            Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                        )
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(Font.custom("Poppins", size: 15).weight(.medium))
                    .foregroundColor(.black)
                
                Text(transaction.subtitle)
                    .font(Font.custom("Poppins", size: 12))
                    .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(transaction.formattedAmount)
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(transaction.amountColor)
                
                Text(transaction.time)
                    .font(Font.custom("Poppins", size: 11))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
            .inset(by: 0.50)
            .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
        )
        .background(Color.white)
        
    }
}

#Preview {
    WalletHistoryScreen()
}
