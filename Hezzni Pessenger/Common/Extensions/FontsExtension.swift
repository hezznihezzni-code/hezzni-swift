//
//  FontsExtension.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/7/25.
//
import SwiftUI
internal import Combine

extension Font {
    static func poppins(_ weight: PoppinsWeight = .regular, size: CGFloat) -> Font {
        return .custom(weight.rawValue, size: size)
    }
    
    enum PoppinsWeight: String {
        case light = "Poppins-Light"
        case regular = "Poppins-Regular"
        case medium = "Poppins-Medium"
        case semiBold = "Poppins-SemiBold"
        case bold = "Poppins-Bold"
        case extraBold = "Poppins-ExtraBold"
        case extraLight = "Poppins-ExtraLight"
        case thin = "Poppins-Thin"
        case black = "Poppins-Black"
    }
}
