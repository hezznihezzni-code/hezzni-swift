//
//  FundsWithdrawReceipt.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/13/25.
//

import SwiftUI

struct FundsWithdrawReceiptCard: View {
    let amount: String
    let transactionID: String
    let dateTime: String
    let withdrawalMethod: String
    let maskedAccount: String
    let status: String
    let statusColor: Color
    let bankIcon: Image? // Optional for future extensibility

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 15) {
                VStack(spacing: 2) {
                    Text("Withdraw Successful")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                    Text("Funds have been sent to your selected account")
                        .font(Font.custom("Poppins", size: 11))
                        .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                }
                Text(amount)
                    .font(Font.custom("Poppins", size: 32).weight(.medium))
                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
            }
            Divider()
                .padding(.horizontal, 25)
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 4) {
                    Text("Transaction ID")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.60))
                    Spacer()
                    HStack(spacing: 6) {
                        Text(transactionID)
                            .font(Font.custom("Poppins", size: 14).weight(.medium))
                            .foregroundColor(.black)
                    }
                }
                .frame(width: 332)
                HStack(spacing: 4) {
                    Text("Date & Time")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.60))
                    Spacer()
                    Text(dateTime)
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.black)
                }
                .frame(width: 332)
                HStack(alignment: .top, spacing: 4) {
                    Text("Withdrawal Method")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.60))
                    HStack(spacing: 8) {
                        VStack(alignment: .trailing, spacing: 0) {
                            HStack(spacing: 4) {
                                VStack(spacing: 10) {
                                    // Placeholder for bank icon
                                    if let bankIcon = bankIcon {
                                        bankIcon
                                            .resizable()
                                            .frame(width: 19, height: 19)
                                    }
                                }
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 2.5, trailing: 0))
                                .frame(width: 19, height: 19)
                                Spacer()
                                Text(withdrawalMethod)
                                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                                    .foregroundColor(.black)
                            }
                            Text(maskedAccount)
                                .font(Font.custom("Poppins", size: 12).weight(.medium))
                                .foregroundColor(Color(red: 0.53, green: 0.53, blue: 0.53))
                        }
                    }
                }
                .frame(width: 332)
                HStack(spacing: 4) {
                    Text("Status")
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.60))
                    Spacer()
                    Text(status)
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(statusColor)
                }
                .frame(width: 332)
            }
            
        }
        .padding(EdgeInsets(top: 60, leading: 15, bottom: 15, trailing: 15))
        .background(.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.50)
                .stroke(
                    Color(red: 0, green: 0, blue: 0).opacity(0.10), lineWidth: 0.50
                )
        )
        .shadow(
            color: Color(red: 0, green: 0, blue: 0, opacity: 0.08), radius: 10
        )
        .overlay(alignment: .top){
            VStack(spacing: 9.41) {
                VStack(spacing: 9.41) {
                    Image("success_tick")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 54.59, height: 54.59)
                .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                .cornerRadius(188.24)
                
            }
            .padding(12.24)
            .frame(height: 80)
            .background(Color(red: 0.67, green: 0.85, blue: 0.72))
            .cornerRadius(188.24)
            .offset(x: 0, y: -40)
        }
        .padding(.horizontal, 20)
    }
}

struct FundsWithdrawReceipt: View {
@Environment(\.dismiss) private var dismiss     
    var body: some View {
        VStack{
            
            Image("hezzni-logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .padding(.top, 50)
            Spacer()
            FundsWithdrawReceiptCard(
                amount: "55.66 MAD",
                transactionID: "TXN_1751555882063",
                dateTime: "03 Jun, 2025 · 01:01 AM",
                withdrawalMethod: "Attijariwafa Bank",
                maskedAccount: "(****8921)",
                status: "PAID",
                statusColor: Color(red: 0.22, green: 0.65, blue: 0.33),
                bankIcon: nil
            )
            
            Spacer()
            VStack(spacing: 10){
                Button(action: {
                    
                }){
                    HStack(spacing: 10) {
                        Spacer()
                        Image("upload_icon")
                            .foregroundStyle(Color(red: 0.33, green: 0.33, blue: 0.33))
                        Text("Download Receipt")
                            .font(Font.custom("Poppins", size: 15).weight(.medium))
                            .foregroundColor(Color(red: 0.33, green: 0.33, blue: 0.33))
                        Spacer()
                    }
                    .padding(10)
                    .frame(height: 50)
                    .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                    .cornerRadius(7.51)
                    
                }
                PrimaryButton(text: "Done", action: {
                    dismiss()
                })
                
            }.padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    FundsWithdrawReceipt()
}
