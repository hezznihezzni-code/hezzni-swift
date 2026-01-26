//
//  CustomAppBar.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/7/25.
//

import SwiftUI

struct CustomAppBar<TrailingView: View>: View {
    var title: String
    var weight: Font.PoppinsWeight?
    var subtitle: String?
    var backButtonVisible: Bool
    let backButtonAction: () -> Void
    var trailingView: TrailingView
    @Environment(\.dismiss) private var dismiss
    
    init(
        title: String,
        weight: Font.PoppinsWeight? = .semiBold,
        subtitle: String? = nil,
        backButtonVisible: Bool = true,
        backButtonAction: @escaping () -> Void = {},
        @ViewBuilder trailingView: () -> TrailingView = {
            Image(systemName: "arrow.left")
                .hidden()
                .accessibilityHidden(true)
        }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.backButtonVisible = backButtonVisible
        self.backButtonAction = backButtonAction
        self.trailingView = trailingView()
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Button(action: {
                backButtonAction()
                dismiss()
            }) {
                Image(systemName: "arrow.left")
                    .fontWeight(.semibold)
                    .foregroundStyle(.foreground)
            }
            .disabled(!backButtonVisible)
            .opacity(backButtonVisible ? 1.0 : 0.0)
            
            Spacer()
            
            VStack(spacing: 8){
                Text(title)
                    .font(.poppins(weight ?? .semiBold, size: 18))
                if subtitle != nil {
                    Text(subtitle ?? "")
                      .font(Font.custom("Poppins", size: 12))
                      .multilineTextAlignment(.center)
                      .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
                      .frame(width: 203, alignment: .top)
                }
            }
            
            Spacer()
            
            trailingView
        }
        .padding(.top)
    }
}
