import SwiftUI

struct TransactionHistoryCard: View {
    let title: String
    let amount: String
    let amountColor: Color
    let paymentMethodImage: String
    let paymentMethodText: String
    let date: String

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(title)
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(.black)
                        Spacer()
                        Text(amount)
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .lineSpacing(12)
                            .foregroundColor(amountColor)
                    }
                    HStack(spacing: 6) {
                        Image(paymentMethodImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 18)
                        Text(paymentMethodText)
                            .font(Font.custom("Poppins", size: 12))
                            .lineSpacing(13)
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.70))
                    }
                }
                Text(date)
                    .font(Font.custom("Poppins", size: 10))
                    .lineSpacing(13)
                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.50))
            }
        }
        .padding(EdgeInsets(top: 15, leading: 17, bottom: 15, trailing: 17))
        .background(.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .inset(by: 0.50)
                .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
        )
        .padding(.horizontal, 16)
    }
}

#Preview {
    TransactionHistoryCard(
        title: "Wallet Top-Up",
        amount: "+ 55.66 MAD",
        amountColor: Color(red: 0.22, green: 0.65, blue: 0.33),
        paymentMethodImage: "mastercard",
        paymentMethodText: "via Mastercard •••• 4532",
        date: "03 Jun, 2025 at 12:00 PM"
    )
}
