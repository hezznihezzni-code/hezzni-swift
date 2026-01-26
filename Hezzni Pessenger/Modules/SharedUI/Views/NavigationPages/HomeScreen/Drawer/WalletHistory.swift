//
//  WalletHistory.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 12/15/25.
//

import SwiftUI

struct WalletHistory: View {
    var body: some View {
        VStack {
            CustomAppBar(title: "Wallet History", backButtonAction: {}, trailingView: {
                Button(action: {}){
                    Image("filter_icon")
                        .foregroundColor(.black)
                }
            })
            Spacer()
        }
        .padding(.horizontal, 10)
    }
}

#Preview{
    WalletHistory()
}
