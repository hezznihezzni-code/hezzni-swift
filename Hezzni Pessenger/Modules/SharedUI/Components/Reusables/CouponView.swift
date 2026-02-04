//
//  CouponView.swift
//  Hezzni
//
//  Created by Zohaib Ahmed on 2/1/26.
//

import SwiftUI


#Preview {
    CouponView(
        couponField: .constant(""),
        showCouponError: .constant(false),
        appliedCoupon: .constant(nil),
        errorMessage: "Invalid coupon code",
        isCouponFieldEmpty: true,
        shouldShowError: false,
        isApplyButtonEnabled: true,
        isLoading: false,
        applyCoupon: {},
        removeCoupon: {}
    )
}

struct CouponShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cutoutRadius: CGFloat = 13
        let cornerRadius: CGFloat = 8
        let cutoutYOffset = rect.midY
        let minX = rect.minX
        let maxX = rect.maxX
        let minY = rect.minY
        let maxY = rect.maxY
        
        // Start at top-left corner (after rounding)
        path.move(to: CGPoint(x: minX + cornerRadius, y: minY))
        // Top edge to top-right corner (before rounding)
        path.addLine(to: CGPoint(x: maxX - cornerRadius, y: minY))
        // Top-right corner arc
        path.addArc(center: CGPoint(x: maxX - cornerRadius, y: minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 0),
                    clockwise: false)
        // Right edge to cutout start
        path.addLine(to: CGPoint(x: maxX, y: cutoutYOffset - cutoutRadius))
        // Right side cutout
        path.addArc(center: CGPoint(x: maxX, y: cutoutYOffset),
                    radius: cutoutRadius,
                    startAngle: Angle(degrees: 270),
                    endAngle: Angle(degrees: 90),
                    clockwise: true)
        // Right edge to bottom-right corner (before rounding)
        path.addLine(to: CGPoint(x: maxX, y: maxY - cornerRadius))
        // Bottom-right corner arc
        path.addArc(center: CGPoint(x: maxX - cornerRadius, y: maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 0),
                    endAngle: Angle(degrees: 90),
                    clockwise: false)
        // Bottom edge to bottom-left corner (before rounding)
        path.addLine(to: CGPoint(x: minX + cornerRadius, y: maxY))
        // Bottom-left corner arc
        path.addArc(center: CGPoint(x: minX + cornerRadius, y: maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 180),
                    clockwise: false)
        // Left edge to cutout start
        path.addLine(to: CGPoint(x: minX, y: cutoutYOffset + cutoutRadius))
        // Left side cutout
        path.addArc(center: CGPoint(x: minX, y: cutoutYOffset),
                    radius: cutoutRadius,
                    startAngle: Angle(degrees: 90),
                    endAngle: Angle(degrees: 270),
                    clockwise: true)
        // Left edge to top-left corner (before rounding)
        path.addLine(to: CGPoint(x: minX, y: minY + cornerRadius))
        // Top-left corner arc
        path.addArc(center: CGPoint(x: minX + cornerRadius, y: minY + cornerRadius),
                    radius: cornerRadius,
                    startAngle: Angle(degrees: 180),
                    endAngle: Angle(degrees: 270),
                    clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct CouponView: View {
    @Binding var couponField: String
    @Binding var showCouponError: Bool
    @Binding var appliedCoupon: AppliedCoupon?
    var errorMessage: String = "Invalid coupon code"
    let isCouponFieldEmpty: Bool
    let shouldShowError: Bool
    let isApplyButtonEnabled: Bool
    var isLoading: Bool = false
    let applyCoupon: () -> Void
    let removeCoupon: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Coupon Code")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.6))
            if let coupon = appliedCoupon {
                ZStack(alignment: .trailing) {
                    HStack(spacing: 0) {
                        HStack(alignment: .center, spacing: 10) {
                            Image("gift_box")
                        }
                        .padding(.leading, 17)
                        .padding(.trailing, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 13)
                        .frame(width: 70, height: 65, alignment: .center)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.22, green: 0.65, blue: 0.33), location: 0.00),
                                    Gradient.Stop(color: Color(red: 0.11, green: 0.45, blue: 0.2), location: 1.00),
                                ],
                                startPoint: UnitPoint(x: 0.42, y: 0),
                                endPoint: UnitPoint(x: 0.98, y: 1)
                            )
                        )
                        VStack(alignment: .leading, spacing: 0) {
                            Text(coupon.discount)
                                .font(Font.custom("Poppins", size: 18).weight(.semibold))
                                .foregroundColor(.hezzniGreen)
                            Text(coupon.validity)
                                .font(Font.custom("Poppins", size: 12))
                                .foregroundColor(.hezzniGreen)
                        }
                        .padding(.leading, 16)
                        .padding(.trailing, 40)
                        .frame(height: 65, alignment: .center)
                        Spacer()
                    }
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.15))
                    .clipShape(CouponShape())
                    .overlay(
                        CouponShape()
                            .stroke(.hezzniGreen, style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                    )
                    Button(action: removeCoupon) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.system(size: 10, weight: .bold))
                    }
                    .frame(width: 20, height: 20)
                    .background(.hezzniGreen)
                    .clipShape(Circle())
                    .offset(x: 10)
                }
                .frame(height: 80)
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 0) {
                        TextField("Enter your coupon", text: $couponField)
                            .padding(.leading, 15)
                            .padding(.vertical, 5)
                            .frame(minHeight: 50, maxHeight: 50)
                            .font(Font.custom("Poppins", size: 18))
                            .foregroundColor(Color(.label))
                            .onChange(of: couponField) { oldValue, newValue in
                                if showCouponError && newValue != oldValue {
                                    showCouponError = false
                                }
                            }
                        Button(action: applyCoupon) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: 100, maxHeight: 40)
                                    .frame(minWidth: 80)
                                    .background(Color.black)
                                    .cornerRadius(8)
                            } else {
                                Text("Apply")
                                    .font(Font.custom("Poppins", size: 18).weight(.medium))
                                    .foregroundColor(isApplyButtonEnabled ? .white : Color(.systemGray3))
                                    .frame(maxWidth: 100, maxHeight: 40)
                                    .frame(minWidth: 80)
                                    .background(isApplyButtonEnabled ? Color.black : Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(!isApplyButtonEnabled || isLoading)
                        .padding(.trailing, 8)
                    }
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .inset(by: 0.5)
                            .stroke(.black.opacity(0.2), lineWidth: 1)
                        
                    )
                    .cornerRadius(10)
                    if shouldShowError {
                        Text(errorMessage)
                            .font(Font.custom("Poppins", size: 12))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(0)
        .frame(width: .infinity, alignment: .topLeading)
    }
}
