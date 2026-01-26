//
//  FundsAddReceipt.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/31/25.
//

import SwiftUI
internal import Combine

struct FundsAddReceipt: View {
    // MARK: - Input
    let code: String
    let amount: Decimal
    let currency: String
    let customerName: String
    let customerPhone: String
    let createdAt: Date
    let expiresAt: Date

    // Actions
    var onDownloadReceipt: () -> Void = {}
    var onReturnHome: () -> Void = {}

    // Local
    @State private var copied = false
    @State private var minuteTick = 0

    private var amountText: String {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        nf.usesGroupingSeparator = true
        let num = (amount as NSDecimalNumber)
        let formatted = nf.string(from: num) ?? "\(num)"
        return "\(formatted) \(currency)"
    }

    private var createdText: String {
        let df = DateFormatter()
        df.dateFormat = "dd MMM, yyyy · hh:mm a"
        return df.string(from: createdAt)
    }

    private var remainingText: String {
        let secs = max(0, Int(expiresAt.timeIntervalSinceNow))
        if secs <= 0 { return "Expired" }
        let hours = secs / 3600
        let minutes = (secs % 3600) / 60
        return String(format: "Valid for %dh %02dm", hours, minutes)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header logos
            HStack(spacing: 10) {
                Image("hezzni-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
                Text("x")
                    .font(.poppins(.medium, size: 18))
                    .foregroundColor(.black.opacity(0.6))
                Image("wafcash")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 12)

            Divider()
                .padding(.horizontal, 24)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Validity pill
                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.hezzniGreen)
                        Text(remainingText)
                            .font(.poppins(.medium, size: 14))
                            .foregroundColor(.hezzniGreen)
                    }
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 10))
                    .background(Color.hezzniGreen.opacity(0.15))
                    .clipShape(Capsule())

                    // Title
                    VStack(spacing: 6) {
                        Text("Payment Code Generated")
                            .font(.poppins(.medium, size: 16))
                            .foregroundColor(.black)
                        Text("Show this code to any Wafacash agent to complete your payment.")
                            .font(.poppins(.regular, size: 11))
                            .foregroundColor(Color(red: 0.43, green: 0.43, blue: 0.43))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 320)
                    }
                    .padding(.top, 2)

                    // Purchase Information
                    InfoCard(title: "Purchase Information", leadingIcon: "purchase_info_fill") {
                        VStack(spacing: 12) {
                            LabeledRow(label: "Code") {
                                HStack(spacing: 8) {
                                    Button {
                                        UIPasteboard.general.string = code
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        withAnimation { copied = true }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { withAnimation { copied = false } }
                                    } label: {
                                        Image("copy_icon")
                                            .font(.poppins(.medium, size: 14))
                                    }
                                    Text(code)
                                        .font(.poppins(.medium, size: 14))
                                        .foregroundColor(.black)
                                        .textSelection(.enabled)
                                    
                                }
                            }
                            
                            LabeledRow(label: "Amount") {
                                Text(amountText)
                                    .font(.poppins(.medium, size: 14))
                                    .foregroundColor(.hezzniGreen)
                            }
                        }
                    }

                    // Customer Information
                    InfoCard(title: "Customer Information", leadingIcon: "customer_info_fill") {
                        VStack(spacing: 12) {
                            LabeledRow(label: "Name") {
                                Text(customerName)
                                    .font(.poppins(.medium, size: 14))
                                    .foregroundColor(.black)
                            }
                            
                            LabeledRow(label: "Phone") {
                                Text(customerPhone)
                                    .font(.poppins(.medium, size: 14))
                                    .foregroundColor(.black)
                            }
                            
                            LabeledRow(label: "Date") {
                                Text(createdText)
                                    .font(.poppins(.semiBold, size: 14))
                                    .foregroundColor(.black)
                            }
                        }
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Instructions")
                            .font(.poppins(.medium, size: 26))
                            .foregroundColor(.black)
                        Divider().overlay(Color.black.opacity(0.08))
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionRow(index: 1, text: "Visit the nearest Wafacash branch.")
                            InstructionRow(index: 2, text: "Share your payment code with the agent.")
                            InstructionRow(index: 3, text: "Pay the amount in cash to complete your transaction.")
                        }
                    }
                    .padding(16)
                    .background(.white)
                    .cornerRadius(16)
                    .overlay(
                    RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.50)
                    .stroke(
                    Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.10), lineWidth: 0.50
                    )
                    )
                    .shadow(
                    color: Color(red: 0, green: 0, blue: 0, opacity: 0.08), radius: 10
                    )
                    .padding(.horizontal, 16)

                    // Actions
                    VStack(spacing: 12) {
                        // Secondary download button (local style, non-invasive)
                        Button(action: onDownloadReceipt) {
                            HStack(spacing: 10) {
                                Image(systemName: "arrow.down.circle")
                                Text("Download Receipt")
                                    .font(.poppins(.medium, size: 16))
                            }
                            .foregroundColor(.black.opacity(0.75))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(hex: "#EEEEEE"))
                            .cornerRadius(12)
                        }

                        // Primary CTA from shared component
                        PrimaryButton(text: "Return to Home", isEnabled: true, buttonColor: .hezzniGreen) {
                            onReturnHome()
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .padding(.top, 18)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .overlay(alignment: .top) {
            if copied {
                CopiedToast()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
            }
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
            if expiresAt > Date() { minuteTick += 1 }
        }
    }
}

// MARK: - Subviews

private struct InfoCard<Content: View>: View {
    let title: String
    let leadingIcon: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(leadingIcon)
                    .padding(8.17)
                    .frame(width: 28, height: 28)
                Text(title)
                    .font(.poppins(.medium, size: 16))
                    .foregroundColor(.black)
                Spacer()
            }
            Divider().overlay(Color.black.opacity(0.08))
            content
        }
        .padding(16)
        .background(.white)
        .cornerRadius(16)
        .overlay(
        RoundedRectangle(cornerRadius: 16)
        .inset(by: 0.50)
        .stroke(
        Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.10), lineWidth: 0.50
        )
        )
        .shadow(
        color: Color(red: 0, green: 0, blue: 0, opacity: 0.08), radius: 10
        )
        .padding(.horizontal, 16)
        
    }
}

private struct LabeledRow<Content: View>: View {
    let label: String
    @ViewBuilder var valueView: Content

    init(label: String, @ViewBuilder _ valueView: () -> Content) {
        self.label = label
        self.valueView = valueView()
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(label)
                .font(.poppins(.regular, size: 14))
                .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
            Spacer()
            valueView
        }
    }
}

private struct InstructionRow: View {
    let index: Int
    let text: String
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("\(index).")
                .font(.poppins(.medium, size: 14))
                .foregroundColor(.black.opacity(0.75))
                .frame(width: 18, alignment: .trailing)
            Text(text)
                .font(.poppins(.regular, size: 14))
                .foregroundColor(.black.opacity(0.75))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CopiedToast: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text("Code copied")
                .font(.poppins(.medium, size: 14))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.85))
        .clipShape(Capsule())
    }
}

// MARK: - Preview

struct FundsAddReceipt_Previews: PreviewProvider {
    static var previews: some View {
        FundsAddReceipt(
            code: "REFOGY8H5IXP",
            amount: 1000,
            currency: "MAD",
            customerName: "Ali Ch",
            customerPhone: "+212 657 434 099",
            createdAt: ISO8601DateFormatter().date(from: "2025-06-03T01:01:00+01:00") ?? Date(),
            expiresAt: Date().addingTimeInterval(60 * 60 * 24)
        )
    }
}
