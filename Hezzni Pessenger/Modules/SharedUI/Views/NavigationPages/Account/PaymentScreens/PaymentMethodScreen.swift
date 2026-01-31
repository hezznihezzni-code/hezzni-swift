//
//  PaymentMethodScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/29/25.
//

import SwiftUI


struct PaymentMethodScreen: View {
    var onBack: (() -> Void)? = nil
    var onEditCard: (Card) -> Void
    var onAddCard: (() -> Void)? = nil
    var onAddFunds: (() -> Void)? = nil
    var onRemoveCard: ((Card) -> Void)? = nil
    var isManagePayment: Bool = false
    @State private var selectedMethodIndex: Int = -1
    @State private var selectedTab: Int = 0 // 0: Trip Payments, 1: Wallet Top-Up
    @State private var selectedCard: Card? = nil // Use this for sheet presentation
    @State private var showRemoveConfirmation = false
    private let methods: [Card] = [
//        .init(iconName: "cash_on_deliver_icon", title: "Cash Payment", subtitle: "pay the driver directly", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
//        .init(iconName: "hezzni_wallet", title: "Hezzni Wallet", subtitle: "Pay with Hezzni balance", badge: "55.66 MAD", cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "visa", title: "Visa Card", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: "mastercard", title: "Mastercard", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: nil, title: "Add Credit / Debit Card", subtitle: "Add Visa or Mastercard for trips", badge: nil, cardNumber: nil, isAddCard: true, cardHolder: nil, expiry: nil)
    ]
    private let walletTop_ups: [Card] = [
        .init(iconName: "wafcash", title: "Wafcash", subtitle: "Recharge your balance", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "cashplus", title: "CashPlus", subtitle: "Recharge your balance", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "visa", title: "Visa Card", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: "mastercard", title: "Mastercard", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: nil, title: "Add Credit / Debit Card", subtitle: "Add Visa or Mastercard for trips", badge: nil, cardNumber: nil, isAddCard: true, cardHolder: nil, expiry: nil)
    ]
    var body: some View {
        NavigationView{
            VStack{
                CustomAppBar(title: "Payment Methods", backButtonAction: {
                    onBack?()
                })
                .padding(.horizontal, 16)
                Divider()
                if !isManagePayment {
                    // Toggle Button
                    HStack(spacing: 0) {
                        Button(action: { selectedTab = 0 }) {
                            Text("Trip Payments")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(selectedTab == 0 ? .black : Color(.sRGB, white: 0.36, opacity: 1))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Group {
                                        if selectedTab == 0 {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white)
                                                .shadow(color: Color(.sRGB, white: 0.9, opacity: 1), radius: 8, y: 2)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        }
                        Button(action: { selectedTab = 1 }) {
                            Text("Wallet Top-Up")
                                .font(Font.custom("Poppins", size: 16).weight(.medium))
                                .foregroundColor(selectedTab == 1 ? .black : Color(.sRGB, white: 0.36, opacity: 1))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    Group {
                                        if selectedTab == 1 {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.white)
                                                .shadow(color: Color(.sRGB, white: 0.9, opacity: 1), radius: 8, y: 2)
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        }
                    }
                    .padding(5)
                    .background(Color(.sRGB, white: 0.97, opacity: 1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                ScrollView{
                    VStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 24) {
                            if selectedTab != 0 {
                                WalletBalanceCard(
                                    balance: "55.66 MAD",
                                    subtitle: "Wallet Balance",
                                    backgroundImage: "hezzni_wallet",
                                    logo: { Image("logo_white")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                    },
                                    infoText: "Virtual balance is non-redeemable and can only be used for Hezzni services."
                                )
                                .shadow(
                                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 15, y: 5
                                )
                                .frame(height: 180)
                                
                            }
                            VStack(alignment: .leading, spacing: 0){
                                Text(selectedTab == 0 ? !isManagePayment ? "Trip Payment Methods" : "Manage Payment Methods" : "Add Funds to Wallet")
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                Text(selectedTab == 0 ? !isManagePayment ? "Manage your payment methods" : "Your saved methods for topping up your Hezzni Wallet" : "Top up your Hezzni Balance using these payment methods")
                                    .font(Font.custom("Poppins", size: 12))
                                    .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                            }
                            .padding(.horizontal, 16)
                            if selectedTab == 0 {
                                PaymentMethodList(methods: methods, selectedIndex: $selectedMethodIndex, showCheckMark: false, onTap: { index in
                                    if !methods[index].isAddCard {
                                        selectedCard = methods[index]
                                    } else {
                                        onAddCard?()
                                    }
                                })
                                .padding(.horizontal, 16)
                            } else {
                                PaymentMethodList(methods: walletTop_ups, selectedIndex: $selectedMethodIndex, showCheckMark: false, onTap: { index in
                                    onAddFunds?()
//                                        if !walletTop_ups[index].isAddCard {
//                                            selectedCard = walletTop_ups[index]
//                                        } else {
//                                            onAddFunds?()
//                                        }
                                })
                                .padding(.horizontal, 16)
                            }
                        }
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 35, trailing: 0))
                    .background(.white)
                }
                
            }
            .sheet(item: $selectedCard) { method in
                CardDetailBottomSheet(method: method, onClose: {
                    selectedCard = nil
                }, onEditCard: { card in
                    onEditCard(card)
                }, showRemoveConfirmation: $showRemoveConfirmation)
            }
            
            .overlay(
                Group {
                    if showRemoveConfirmation, let card = selectedCard {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        VStack(spacing: 24) {
                            Image("remove_card_icon")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .padding(.top, 24)
                            Text("Remove Card?")
                                .font(Font.custom("Poppins", size: 22).weight(.medium))
                                .foregroundColor(Color(red: 0.83, green: 0.18, blue: 0.18))
                            Text("Are you sure you want to delete this card?\nIt will no longer be available for payments.")
                                .font(Font.custom("Poppins", size: 15))
                                .foregroundColor(Color(.sRGB, white: 0.36, opacity: 1))
                                .multilineTextAlignment(.center)
                            Button(action: {
                                showRemoveConfirmation = false
                                onRemoveCard?(card)
                                selectedCard = nil
                            }) {
                                Text("Remove Card")
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.83, green: 0.18, blue: 0.18))
                                    .cornerRadius(10)
                            }
                            Button(action: {
                                showRemoveConfirmation = false
                            }) {
                                Text("Cancel")
                                    .font(Font.custom("Poppins", size: 16).weight(.medium))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(24)
                        .background(Color.white)
                        .cornerRadius(24)
                        .padding(.horizontal, 32)
                        .shadow(radius: 20)
                        
                    }
                }
            )
        }
        .navigationBarBackButtonHidden()
    }
}


struct WalletTopUpScreen: View {
    var onBack: (() -> Void)? = nil
    var onAddFunds: (() -> Void)? = nil
    
    @State private var selectedMethodIndex: Int = -1
    @State private var selectedCard: Card? = nil // Use this for sheet presentation
    @State private var showRemoveConfirmation = false
    private let methods: [Card] = [
//        .init(iconName: "cash_on_deliver_icon", title: "Cash Payment", subtitle: "pay the driver directly", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
//        .init(iconName: "hezzni_wallet", title: "Hezzni Wallet", subtitle: "Pay with Hezzni balance", badge: "55.66 MAD", cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "visa", title: "Visa Card", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: "mastercard", title: "Mastercard", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: nil, title: "Add Credit / Debit Card", subtitle: "Add Visa or Mastercard for trips", badge: nil, cardNumber: nil, isAddCard: true, cardHolder: nil, expiry: nil)
    ]
    private let walletTop_ups: [Card] = [
        .init(iconName: "wafcash", title: "Wafcash", subtitle: "Recharge your balance", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "cashplus", title: "CashPlus", subtitle: "Recharge your balance", badge: nil, cardNumber: nil, isAddCard: false, cardHolder: nil, expiry: nil),
        .init(iconName: "visa", title: "Visa Card", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: "mastercard", title: "Mastercard", subtitle: "", badge: nil, cardNumber: "2221 0057 4680 2345", isAddCard: false, cardHolder: "Emiway Bantai", expiry: "02/30"),
        .init(iconName: nil, title: "Add Credit / Debit Card", subtitle: "Add Visa or Mastercard for trips", badge: nil, cardNumber: nil, isAddCard: true, cardHolder: nil, expiry: nil)
    ]
    var body: some View {
        NavigationView{
            ZStack{
                VStack{
                    CustomAppBar(title: "Payment Methods", backButtonAction: {
                        onBack?()
                    })
                    .padding(.horizontal, 16)
                    Divider()
                    
                    ScrollView{
                        VStack(spacing: 15) {
                            VStack(alignment: .leading, spacing: 24) {
                                VStack(alignment: .leading, spacing: 0){
                                    Text("Add Funds to Wallet")
                                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                                    Text("Top up your Hezzni Balance using these payment methods")
                                        .font(Font.custom("Poppins", size: 12))
                                        .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                                }
                                .padding(.horizontal, 16)
                                
                                
                                    PaymentMethodList(methods: walletTop_ups, selectedIndex: $selectedMethodIndex, showCheckMark: false, onTap: { index in
                                        onAddFunds?()
//                                        if !walletTop_ups[index].isAddCard {
//                                            selectedCard = walletTop_ups[index]
//                                        } else {
//                                            onAddFunds?()
//                                        }
                                    })
                                    .padding(.horizontal, 16)
                                
                            }
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 15, leading: 0, bottom: 35, trailing: 0))
                        .background(.white)
                    }
                    
                }
                .overlay(
                    Group {
                        if showRemoveConfirmation, let card = selectedCard {
                            Color.black.opacity(0.3).ignoresSafeArea()
                            VStack(spacing: 24) {
                                Image("remove_card_icon")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .padding(.top, 24)
                                Text("Remove Card?")
                                    .font(Font.custom("Poppins", size: 22).weight(.medium))
                                    .foregroundColor(Color(red: 0.83, green: 0.18, blue: 0.18))
                                Text("Are you sure you want to delete this card?\nIt will no longer be available for payments.")
                                    .font(Font.custom("Poppins", size: 15))
                                    .foregroundColor(Color(.sRGB, white: 0.36, opacity: 1))
                                    .multilineTextAlignment(.center)
                                Button(action: {
                                    showRemoveConfirmation = false
                                    
                                    selectedCard = nil
                                }) {
                                    Text("Remove Card")
                                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(red: 0.83, green: 0.18, blue: 0.18))
                                        .cornerRadius(10)
                                }
                                Button(action: {
                                    showRemoveConfirmation = false
                                }) {
                                    Text("Cancel")
                                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                                        .cornerRadius(10)
                                }
                            }
                            .padding(24)
                            .background(Color.white)
                            .cornerRadius(24)
                            .padding(.horizontal, 32)
                            .shadow(radius: 20)
                            
                        }
                    }
                )
            }
        }
        .navigationBarBackButtonHidden()
    }
}


struct CardDetailBottomSheet: View {
    let method: Card
    var onClose: () -> Void
    var onEditCard: (Card) -> Void
    var onRemoveCard: ((Card) -> Void)? = nil
    @Binding var showRemoveConfirmation: Bool
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                Text("Card Details")
                    .font(Font.custom("Poppins", size: 20).weight(.medium))
                    .foregroundColor(.black)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }
            .padding(.horizontal)
            ZStack(alignment: .topTrailing) {
                Image("card_detail_background")
                    .resizable()
                    .frame(height: 210)
                    .padding(.horizontal, 16)
                if let iconName = method.iconName {
                    Image(iconName)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 32)
                        .padding(.top, 26)
                        .padding(.trailing, 36)
                }
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    Text(method.cardNumber ?? "")
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundColor(.white)
                        .padding(.bottom, 2)
                    HStack {
                        Text(method.cardHolder ?? "")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(.white)
                        Spacer()
                        Text(method.expiry ?? "")
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(.bottom, 26)
                .padding([.leading,.trailing], 36)
            }
            .shadow(
                color: Color(red: 0, green: 0, blue: 0, opacity: 0.25), radius: 15, y: 5
            )
            .frame(height: 180)
            .padding(.bottom, 16)
            VStack(spacing: 16) {
                Button(action: {onEditCard(method)}) {
                    Text("Edit Card Details")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.94, green: 0.94, blue: 0.94))
                        .cornerRadius(10)
                }
                Button(action: { showRemoveConfirmation = true }) {
                    Text("Remove Card")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.83, green: 0.18, blue: 0.18))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding(.top, 24)
        .background(Color.white)
        .presentationDetents([.medium, .large])
        
    }
}

#Preview{
    PaymentMethodScreen(
        onEditCard: {_ in}
    )
}

#Preview{
    WalletTopUpScreen()
}
