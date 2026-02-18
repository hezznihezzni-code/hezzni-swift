//
//  AccountScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/10/25.
//

import SwiftUI

// Add a typed route enum to avoid stringly-typed navigation
enum AccountRoute: Hashable {
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
    //For testing purpose
//    case cancelRide
    case vehicleDetails // for Driver only
    
}

struct AccountScreen: View {
    @State private var currentRoute: AccountRoute? = nil
    @EnvironmentObject private var navigationState: NavigationStateManager
    @State private var currentCard: Card? = nil
    @StateObject private var authController = AuthController.shared

    // Toast state
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""

    var body: some View {
        ZStack(alignment: .top) {
            if let route = currentRoute {
                switch route {
                case .login:
                    OnboardingView()
                        .transition(.move(edge: .trailing))
                case .completeProfile:
                    CompleteProfile(
                        isUpdateProfile: true,
                        onBack: {
                            currentRoute = nil
                            navigationState.showBottomBar()
                        },
                        onProfileUpdated: { message in
                            // Ensure we return to Account screen then show toast
                            currentRoute = nil
                            navigationState.showBottomBar()
                            showTopToast(message: message)
                        }
                    )
                    .transition(.move(edge: .trailing))
                case .languageRegion:
                    LanguageSettingsScreen(
                        onBack: {
                            currentRoute = nil
                            navigationState.showBottomBar()
                        }
                    )
                        .transition(.move(edge: .trailing))
                case .changePhone:
                    ChangePhoneScreen(
                        onBack: {
                            currentRoute = nil
                            navigationState.showBottomBar()
                        }
                    )
                        .transition(.move(edge: .trailing))
                case .paymentMethods:
                    PaymentMethodScreen(
                        onBack: {
                            currentRoute = nil
                            navigationState.showBottomBar()
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
                    .transition(.move(edge: .trailing))
                case .editPayment:
                    Add_EditCard(mode: .edit, existing: currentCard!, onSave: { newCard in
                        // Add logic to save card
                    }, onBack: {
                        currentRoute = .paymentMethods
                    })
                    .transition(.move(edge: .trailing))
                case .addPayment:
                    Add_EditCard(mode: .add, onSave: { newCard in
                        // Add logic to save card
                    }, onBack: {
                        currentRoute = .paymentMethods
                    })
                    .transition(.move(edge: .trailing))
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
                    .transition(.move(edge: .trailing))
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
                        .transition(.move(edge: .trailing))
                case .transactionHistory:
                    TransactionHistoryScreen(
                        onBack: {
                            currentRoute = nil
                            navigationState.showBottomBar()
                        },
                    )
                        .transition(.move(edge: .trailing))
                case .reviewHistory:
                    ReviewScreen(
                        onBack: {
                            currentRoute = nil
                            navigationState.showBottomBar()
                        }
                    )
                        .transition(.move(edge: .trailing))
                case .helpSupport:
                    HelpSupportScreen(
                        onBack: {
                            currentRoute = nil
                            navigationState.showBottomBar()
                        }
                    )
                        .transition(.move(edge: .trailing))
                case .termsPrivacy:
                    TermsPrivacyScreen()
                        .transition(.move(edge: .trailing))
                    //TO BE REMOVED
//                case .cancelRide:
//                    RideCancelScreen(
//                        isDriver: false,
//                        onDismiss: {
//                            currentRoute = nil
//                            navigationState.showBottomBar()
//                        },
//                    )
//                        .transition(.move(edge: .trailing))
                case .vehicleDetails:
                    VehicleDetailsScreen()
                }
                
                
                
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        NewProfileCard(
                            person: Person(
                                id: "\(String(describing: authController.currentUser?.id) )",
                                name: authController.currentUser?.name ?? "Ahmed Hassan",
                                phoneNumber: authController.currentUser?.phone ?? "+212 666 666 6666",
                                rating: 4.8,
                                tripCount: 2847,
                                imageUrl: "https://api.hezzni.com\(authController.currentUser?.imageUrl ?? "default_profile.png")"
                            )
                        )
                        .onTapGesture{
                            currentRoute = .completeProfile
                            navigationState.hideBottomBar()
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            SectionTitle(title: "Account Details")

                            AccountListTile(
                                iconName: "person_icon",
                                title: "Update Profile",
                                subtitle: "Edit your name, photo, and personal details",
                                includeShadow: true,
                                isSystemImage: false,
                                action: {
                                    currentRoute = .completeProfile
                                    navigationState.hideBottomBar()
                                }
                            )
                            AccountListTile(
                                iconName: "phone_icon",
                                title: "Change Phone Number",
                                subtitle: "+212 666 789 234",
                                includeShadow: true,
                                isSystemImage: false,
                                action: {
                                    currentRoute = .changePhone
                                    navigationState.hideBottomBar()
                                }
                            )
                            AccountListTile(
                                iconName: "payment_method_icon",
                                title: "Payment Methods",
                                subtitle: "Manage cards and payment options",
                                includeShadow: true,
                                isSystemImage: false,
                                action: {
                                    currentRoute = .paymentMethods
                                    navigationState.hideBottomBar()
                                }
                            )
                            AccountListTile(
                                iconName: "history_icon",
                                title: "Transaction History",
                                subtitle: "View your payment history",
                                includeShadow: true,
                                isSystemImage: false,
                                action: {
                                    currentRoute = .transactionHistory
                                    navigationState.hideBottomBar()
                                }
                            )
                            AccountListTile(
                                iconName: "review_icon",
                                title: "Rating History",
                                subtitle: "View ratings you’ve given and received",
                                includeShadow: true,
                                isSystemImage: false,
                                action: {
                                    currentRoute = .reviewHistory
                                    navigationState.hideBottomBar()
                                }
                            )
                            SectionTitle(title: "App Settings")
                            AccountListTile(
                                iconName: "globe_icon",
                                title: "Change Language",
                                subtitle: "English (US)",
                                includeShadow: true,
                                isSystemImage: false,
                                action: {
                                    currentRoute = .languageRegion
                                    navigationState.hideBottomBar()
                                }
                            )
                            SectionTitle(title: "Support & About")
                            VStack(alignment: .leading, spacing: 10) {
                                AccountListTile(
                                    iconName: "help_icon",
                                    title: "Help & Support",
                                    subtitle: "Get help with your account",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        currentRoute = .helpSupport
                                        navigationState.hideBottomBar()
                                    }
                                )
                                AccountListTile(
                                    iconName: "terms_icon",
                                    title: "Terms & Privacy",
                                    subtitle: "Legal documents and policies",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        currentRoute = .termsPrivacy
                                        
                                    }
                                )
                                AccountListTile(
                                    iconName: "heart_icon",
                                    title: "Rate Hezzni",
                                    subtitle: "Share your feedback",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        print("Rate Hezzni Tapped")
                                    }
                                )
                                AccountListTile(
                                    iconName: "phone_icon",
                                    title: "Invite Friends",
                                    subtitle: "Earn rewards for referrals",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        print("Invite Tapped")
                                    }
                                )
                                AccountListTile(
                                    iconName: "become_driver_icon",
                                    title: "Become a Driver",
                                    subtitle: "Earn rewards for referrals",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        print("Driver Icon Tapped")
                                    }
                                )
                                AccountListTile(
                                    iconName: "logout_icon",
                                    title: "Sign out",
                                    titleColor: Color.red,
                                    subtitle: "Sign out of your account",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        print("Sign out Tapped")
                                        currentRoute = .login
                                        navigationState.hideBottomBar()
                                        
                                    }
                                )
                                
//                                Text("----For Testing only----")
//                                AccountListTile(
//                                    iconName: "logout_icon",
//                                    title: "Cancel Ride",
//                                    titleColor: Color.red,
//                                    subtitle: "Cancellation testing screen",
//                                    includeShadow: true,
//                                    isSystemImage: false,
//                                    action: {
//                                        print("Sign out Tapped")
//                                        currentRoute = .cancelRide
//                                        navigationState.hideBottomBar()
//                                        
//                                    }
//                                )
                                Spacer()
                                    .frame(height: 150)
                            }
                        }
                        .padding(0)
                        .frame(width: .infinity, alignment: .center)
                        Spacer()
                    }
                    .padding()
                }
                .navigationBarTitleDisplayMode(.inline)
            }

            if showToast {
                TopToastView(message: toastMessage)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
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
}

#Preview {
    AccountScreen()
}

struct DriverAccountScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentRoute: AccountRoute? = nil
    @StateObject private var authController = AuthController.shared
    @State private var currentCard: Card? = nil
    var body: some View {
        ZStack {
            if let route = currentRoute {
                switch route {
                case .login:
                    RootView()
                        .transition(.move(edge: .trailing))
                case .completeProfile:
                    CompleteProfile(
                        isUpdateProfile: true,
                        onBack: {
                            currentRoute = nil
                            
                        }
                    )
                    .transition(.move(edge: .trailing))
                case .languageRegion:
                    LanguageSettingsScreen(
                        onBack: {
                            currentRoute = nil
                            
                        }
                    )
                        .transition(.move(edge: .trailing))
                case .changePhone:
                    ChangePhoneScreen(
                        onBack: {
                            currentRoute = nil
                            
                        }
                    )
                        .transition(.move(edge: .trailing))
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
                    .transition(.move(edge: .trailing))
                case .editPayment:
                    Add_EditCard(mode: .edit, existing: currentCard!, onSave: { newCard in
                        // Add logic to save card
                    }, onBack: {
                        currentRoute = .paymentMethods
                    })
                    .transition(.move(edge: .trailing))
                case .addPayment:
                    Add_EditCard(mode: .add, onSave: { newCard in
                        // Add logic to save card
                    }, onBack: {
                        currentRoute = .paymentMethods
                    })
                    .transition(.move(edge: .trailing))
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
                    .transition(.move(edge: .trailing))
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
                        .transition(.move(edge: .trailing))
                case .transactionHistory:
                    TransactionHistoryScreen(
                        onBack: {
                            currentRoute = nil
                            
                        },
                    )
                        .transition(.move(edge: .trailing))
                case .reviewHistory:
                    ReviewScreen(
                        onBack: {
                            currentRoute = nil
                            
                        }
                    )
                        .transition(.move(edge: .trailing))
                case .helpSupport:
                    HelpSupportScreen(
                        onBack: {
                            currentRoute = nil
                            
                        }
                    )
                        .transition(.move(edge: .trailing))
                case .termsPrivacy:
                    TermsPrivacyScreen()
                        .transition(.move(edge: .trailing))
                    //TO BE REMOVED
//                case .cancelRide:
//                    RideCancelScreen(
//                        onBack: {
//                            currentRoute = nil
//                            
//                        },
//                    )
//                        .transition(.move(edge: .trailing))
                case .vehicleDetails:
                    VehicleDetailsScreen(
                        onBack: {
                            currentRoute = nil
                        }
                    )
                }
                
                
                
            } else {
                VStack{
                    OnboardingAppBar(title: "Account", onBack: {
                        dismiss()
                    })
                    Divider()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            NewProfileCard(
                                person: Person(
                                    id: "\(String(describing: authController.currentUser?.id) )",
                                    name: authController.currentUser?.name ?? "Ahmed Hassan",
                                    phoneNumber: authController.currentUser?.phone ?? "+212 666 666 6666",
                                    rating: 4.8,
                                    tripCount: 2847,
                                    imageUrl: "https://api.hezzni.com\(authController.currentUser?.imageUrl ?? "default_profile.png")"
                                )
                            )
                            .onTapGesture{
                                currentRoute = .completeProfile
                                
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                SectionTitle(title: "Account Details")
                                
                                AccountListTile(
                                    iconName: "person_icon",
                                    title: "Update Profile",
                                    subtitle: "Edit your name, photo, and personal details",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        currentRoute = .completeProfile
                                        
                                    }
                                )
                                AccountListTile(
                                    iconName: "phone_icon",
                                    title: "Change Phone Number",
                                    subtitle: "+212 666 789 234",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        currentRoute = .changePhone
                                        
                                    }
                                )
//                                AccountListTile(
//                                    iconName: "payment_method_icon",
//                                    title: "Payment Methods",
//                                    subtitle: "Manage cards and payment options",
//                                    includeShadow: true,
//                                    isSystemImage: false,
//                                    action: {
//                                        currentRoute = .paymentMethods
//
//                                    }
//                                )
//                                AccountListTile(
//                                    iconName: "history_icon",
//                                    title: "Transaction History",
//                                    subtitle: "View your payment history",
//                                    includeShadow: true,
//                                    isSystemImage: false,
//                                    action: {
//                                        currentRoute = .transactionHistory
//
//                                    }
//                                )
                                AccountListTile(
                                    iconName: "review_icon",
                                    title: "Rating History",
                                    subtitle: "View ratings you’ve given and received",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        currentRoute = .reviewHistory
                                        
                                    }
                                )
                                AccountListTile(
                                    iconName: "vehicle_details_icon",
                                    title: "Vehicle Details",
                                    subtitle: "View registered car info or request an update",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        currentRoute = .vehicleDetails
                                        
                                    }
                                )
                                SectionTitle(title: "App Settings")
                                AccountListTile(
                                    iconName: "globe_icon",
                                    title: "Change Language",
                                    subtitle: "English (US)",
                                    includeShadow: true,
                                    isSystemImage: false,
                                    action: {
                                        currentRoute = .languageRegion
                                        
                                    }
                                )
                                SectionTitle(title: "Support & About")
                                VStack(alignment: .leading, spacing: 10) {
                                    AccountListTile(
                                        iconName: "help_icon",
                                        title: "Help & Support",
                                        subtitle: "Get help with your account",
                                        includeShadow: true,
                                        isSystemImage: false,
                                        action: {
                                            currentRoute = .helpSupport
                                            
                                        }
                                    )
                                    AccountListTile(
                                        iconName: "terms_icon",
                                        title: "Terms & Privacy",
                                        subtitle: "Legal documents and policies",
                                        includeShadow: true,
                                        isSystemImage: false,
                                        action: {
                                            currentRoute = .termsPrivacy
                                            
                                        }
                                    )
                                    AccountListTile(
                                        iconName: "heart_icon",
                                        title: "Rate Hezzni",
                                        subtitle: "Share your feedback",
                                        includeShadow: true,
                                        isSystemImage: false,
                                        action: {
                                            print("Rate Hezzni Tapped")
                                        }
                                    )
                                    AccountListTile(
                                        iconName: "phone_icon",
                                        title: "Invite Friends",
                                        subtitle: "Earn rewards for referrals",
                                        includeShadow: true,
                                        isSystemImage: false,
                                        action: {
                                            print("Invite Tapped")
                                        }
                                    )
                                    
                                    AccountListTile(
                                        iconName: "logout_icon",
                                        title: "Sign out",
                                        titleColor: Color.red,
                                        subtitle: "Sign out of your account",
                                        includeShadow: true,
                                        isSystemImage: false,
                                        action: {
                                            print("Sign out Tapped")
                                            currentRoute = .login
                                            
                                            
                                        }
                                    )
                                    
                                }
                                Spacer()
                                    .frame(height: 150)
                            }
                            .padding(0)
                            .frame(width: .infinity, alignment: .center)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .animation(.easeInOut, value: currentRoute)
        .navigationBarBackButtonHidden()
    }
}


// Keep the existing AccountListTile implementation as is
struct AccountListTile: View {
    let iconName: String
    let title: String
    let titleColor: Color?
    let subtitle: String?
    let trailingText: String?
    let showChevron: Bool
    let showToggle: Bool
    let includeShadow: Bool
    let isSystemImage: Bool
    let isOn: Bool?
    let action: (() -> Void)?
    let toggleAction: ((Bool) -> Void)?
    
    init(
        iconName: String,
        title: String,
        titleColor: Color? = nil,
        subtitle: String? = nil,
        trailingText: String? = nil,
        showChevron: Bool = true,
        showToggle: Bool = false,
        includeShadow: Bool = false,
        isSystemImage: Bool = true,
        isOn: Bool? = nil,
        action: (() -> Void)? = nil,
        toggleAction: ((Bool) -> Void)? = nil
    ) {
        self.iconName = iconName
        self.title = title
        self.titleColor = titleColor
        self.subtitle = subtitle
        self.trailingText = trailingText
        self.showChevron = showChevron
        self.showToggle = showToggle
        self.includeShadow = includeShadow
        self.isSystemImage = isSystemImage
        self.isOn = isOn
        self.action = action
        self.toggleAction = toggleAction
        
        // Validation
        if showToggle && showChevron {
            fatalError("Cannot show both chevron and toggle. Use either showChevron or showToggle.")
        }
    }
    
    var body: some View {
        HStack(alignment: .center) {
            // Leading Content
            HStack(alignment: .center, spacing: 11) {
                iconView
                    .frame(width: 40, height: 40)
                    .background(.white)
                    .foregroundStyle(.hezzniGreen)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(.poppins(.medium, size: 15))
                        .foregroundColor(titleColor ?? .blackwhite)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.poppins(size: 11))
                            .foregroundColor(Color.blackwhite.opacity(0.7))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            // Middle Spacer or Text
            if let trailingText = trailingText {
                Text(trailingText)
                    .font(.poppins(size: 14))
                    .foregroundColor(.gray)
            } else {
                Spacer()
            }
            // Trailing Content - Chevron or Toggle
            if showChevron {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 12))
                    .foregroundStyle(.black.opacity(0.25))
            } else if showToggle, let isOn = isOn {
                Toggle("", isOn: Binding(
                    get: { isOn },
                    set: { newValue in
                        toggleAction?(newValue)
                    }
                ))
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: .hezzniGreen))
            }
        }
        .padding(16)
        .background(.white)
        .cornerRadius(7.5)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
            .inset(by: 0.50)
            .stroke(.black.opacity(0.25), lineWidth: 0.50)
        )
        .shadow(
            color: includeShadow ? Color(red: 0, green: 0, blue: 0, opacity: 0.07) : .clear,
            radius: 10, y: 4
        )
        .contentShape(Rectangle()) // Makes entire area tappable
        .onTapGesture {
            if !showToggle { // Only trigger tap action if not a toggle
                action?()
            }
        }
    }
    
    @ViewBuilder
    private var iconView: some View {
        if isSystemImage {
            Image(systemName: iconName)
        } else {
            Image(iconName)
                .resizable()
                .scaledToFit()
        }
    }
}


struct ChangePhoneNumberScreen: View {
    var body: some View {
        Text("Change Phone Number Screen")
            .navigationTitle("Change Phone Number")
    }
}




struct TermsPrivacyScreen: View {
    var body: some View {
        Text("Terms & Privacy Screen")
            .navigationTitle("Terms & Privacy")
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
