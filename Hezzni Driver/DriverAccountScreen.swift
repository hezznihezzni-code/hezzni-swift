import SwiftUI

// Copy of AccountRoute for driver
enum DriverAccountRoute: Hashable {
    case login
    case completeProfile
    case changePhone
    case paymentMethods
    case editPayment
    case addPayment
    case addFunds
    case fundsReceipt
    case reviewHistory
    case transactionHistory
    case languageRegion
    case helpSupport
    case termsPrivacy
    case cancelRide
    case vehicleDetails
}

struct DriverAccountScreenDriver: View {
    @State private var currentRoute: DriverAccountRoute? = nil
    @State private var currentCard: Card? = nil
    // Toast state
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            if let route = currentRoute {
                switch route {
                case .login:
                    OnboardingView()
                        .transition(AnyTransition.move(edge: .trailing))
                case .completeProfile:
                    CompleteProfile(
                        isUpdateProfile: true,
                        onBack: {
                            currentRoute = nil
                        },
                        onProfileUpdated: { message in
                            currentRoute = nil
                            showTopToast(message: message)
                        }
                    )
                    .transition(AnyTransition.move(edge: .trailing))
                case .languageRegion:
                    LanguageSettingsScreen(
                        onBack: {
                            currentRoute = nil
                        }
                    )
                        .transition(AnyTransition.move(edge: .trailing))
                case .changePhone:
                    ChangePhoneScreen(
                        onBack: {
                            currentRoute = nil
                        }
                    )
                        .transition(AnyTransition.move(edge: .trailing))
                case .paymentMethods:
                    PaymentMethodScreen(
                        onBack: {
                            currentRoute = nil
                        },
                        onEditCard: { card in
                            currentCard = card
                            currentRoute = .editPayment
                        },
                        onAddCard: {
                            currentRoute = .addPayment
                        },
                        onAddFunds: {
                            currentRoute = .addFunds
                        }
                    )
                    .transition(AnyTransition.move(edge: .trailing))
                case .editPayment:
                    Add_EditCard(mode: .edit, existing: currentCard!, onSave: { newCard in
                        // Add logic to save card
                    }, onBack: {
                        currentRoute = .paymentMethods
                    })
                    .transition(AnyTransition.move(edge: .trailing))
                case .addPayment:
                    Add_EditCard(mode: .add, onSave: { newCard in
                        // Add logic to save card
                    }, onBack: {
                        currentRoute = .paymentMethods
                    })
                    .transition(AnyTransition.move(edge: .trailing))
                case .addFunds:
                    AddFundsView(
                        currentBalance: 150.00,
                        onAddFunds: { amount in
                            currentRoute = .fundsReceipt
                        },
                        onBack: {
                            currentRoute = .paymentMethods
                        }
                    )
                    .transition(AnyTransition.move(edge: .trailing))
                case .fundsReceipt:
                    FundsAddReceipt(
                        code: "REFOGY8H5IXP",
                        amount: 1000,
                        currency: "MAD",
                        customerName: "Ali Ch",
                        customerPhone: "+212 657 434 099",
                        createdAt: ISO8601DateFormatter().date(from: "2025-06-03T01:01:00+01:00") ?? Date(),
                        expiresAt: Date().addingTimeInterval(60 * 60 * 24),
                        onReturnHome: {
                            currentRoute = .paymentMethods
                        }
                    )
                        .transition(AnyTransition.move(edge: .trailing))
                case .transactionHistory:
                    TransactionHistoryScreen(
                        onBack: {
                            currentRoute = nil
                        }
                    )
                        .transition(AnyTransition.move(edge: .trailing))
                case .reviewHistory:
                    ReviewScreen(
                        onBack: {
                            currentRoute = nil
                        }
                    )
                        .transition(AnyTransition.move(edge: .trailing))
                case .helpSupport:
                    HelpSupportScreen(
                        onBack: {
                            currentRoute = nil
                        }
                    )
                        .transition(AnyTransition.move(edge: .trailing))
                case .termsPrivacy:
                    TermsPrivacyScreen()
                        .transition(AnyTransition.move(edge: .trailing))
                case .cancelRide:
                    // CancelRideScreen(
                    //     onBack: {
                    //         currentRoute = nil
                    //     }
                    // )
                    //     .transition(AnyTransition.move(edge: .trailing))
                    EmptyView()
                case .vehicleDetails:
                    // VehicleDetailsScreen(
                    //     onBack: {
                    //         currentRoute = nil
                    //     }
                    // )
                    //     .transition(AnyTransition.move(edge: .trailing))
                    EmptyView()
                }
            }
            if showToast {
                TopToastView(message: toastMessage)
                    .padding(.top, 12)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .zIndex(1000)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: showToast)
        .navigationBarBackButtonHidden()
    }

    private func showTopToast(message: String) {
        toastMessage = message
        showToast = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showToast = false
        }
    }

    private struct TopToastView: View {
        let message: String

        var body: some View {
            HStack(spacing: 7) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                Text(message)
                    .font(Font.custom("Poppins", size: 12).weight(.medium))
                    .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
            }
            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
            .background(Color(red: 0.92, green: 0.96, blue: 0.93))
            .cornerRadius(7)
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .inset(by: 0.50)
                    .stroke(Color(red: 0.22, green: 0.65, blue: 0.33), lineWidth: 0.50)
            )
            .shadow(
                color: Color(red: 0.22, green: 0.65, blue: 0.33, opacity: 0.20), radius: 10, y: 1
            )
            .padding(.horizontal, 16)
        }
    }
}
