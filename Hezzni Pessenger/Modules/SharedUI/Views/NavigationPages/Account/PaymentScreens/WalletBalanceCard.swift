import SwiftUI

struct WalletBalanceCard<Logo: View>: View {
    let balance: String
    let subtitle: String
    let backgroundImage: String
    let logo: () -> Logo
    let infoText: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(backgroundImage)
                .resizable()
                .frame(height: 210)
            logo()
                .padding(.top, 36)
                .padding(.leading, 36)
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                VStack(alignment: .leading) {
                    Text(subtitle)
                        .font(Font.custom("Poppins", size: 12.83))
                        .foregroundColor(.white)
                    HStack(spacing: 9.33) {
                        Text(balance)
                            .font(Font.custom("Poppins", size: 30.32).weight(.medium))
                            .foregroundColor(.white)
                    }
                    Text(infoText)
                        .font(Font.custom("Poppins", size: 9.33))
                        .foregroundColor(Color.white.opacity(0.75))
                }
            }
            .padding(.bottom, 36)
            .padding([.leading,.trailing], 36)
        }
        .frame(height: 180)
    }
}

struct WalletBalanceCard_Previews: PreviewProvider {
    static var previews: some View {
        WalletBalanceCard(
            balance: "55.66 MAD",
            subtitle: "Wallet Balance",
            backgroundImage: "hezzni_wallet",
            logo: { Image("logo_white").resizable()
                .frame(width: 40, height: 40) },
            infoText: "Virtual balance is non-redeemable and can only be used for Hezzni services."
        )
        .padding()
        .background(Color.gray)
    }
}
