//
//  InviteFriendsScreen.swift
//  Hezzni Driver
//

import SwiftUI

struct InviteFriendsScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var copied = false
    let inviteLink = "https://hezzni.app/invite/ali123"
    
    var body: some View {
        VStack(spacing: 0) {
            OnboardingAppBar(title: "Invite Friends", onBack: {
                dismiss()
            })
            Divider()
            
            
            ScrollView {
                VStack(spacing: 24) {
                    ReferralBannerCard()
                    
                    HowItWorksSection()
                    
                    InviteLinkSection(
                        inviteLink: inviteLink,
                        copied: $copied,
                        onCopy: {
                            UIPasteboard.general.string = inviteLink
                            copied = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copied = false
                            }
                        }
                    )
                    
                    Button(action: {
                        let activityVC = UIActivityViewController(
                            activityItems: ["Join me on Hezzni Driver and start earning! Use my invite link: \(inviteLink)"],
                            applicationActivities: nil
                        )
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            rootVC.present(activityVC, animated: true)
                        }
                    }) {
                        Text("Share")
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.hezzniGreen)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 50)
                }
                .padding(.top, 16)
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .overlay(alignment: .top) {
            if copied {
                CopiedToastView()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 60)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: copied)
    }
}

struct ReferralBannerCard: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.hezzniGreen.opacity(0.1))
            
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Earn MAD 100+")
                        .font(Font.custom("Poppins", size: 11).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black)
                        .cornerRadius(100)
                    
                    VStack{
                        Text("Refer & Earn Rewards")
                            .font(Font.custom("Poppins", size: 15).weight(.medium))
                            .foregroundColor(.black)
                        
                        Text("Invite fellow drivers to Hezzni and earn bonuses when they start driving.")
                            .font(Font.custom("Poppins", size: 11))

                            .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                            .lineLimit(nil) // Allow the text to display fully without truncation
                            .fixedSize(horizontal: false, vertical: true) // Ensure the text expands vertically if needed
                    }
                }
                
                Spacer()
                
                Image("invite_friends")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(1.2)
                    
            }
            .padding(.horizontal, 20)
        }
        
        .overlay(
            RoundedRectangle(cornerRadius: 15)
            .inset(by: 0.50)
            .stroke(
            Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.50), lineWidth: 0.50
            )
        )
        .padding(.horizontal, 16)
    }
}

struct HowItWorksSection: View {
    let steps = [
        ("Share your invite link with friends.", "square.and.arrow.up"),
        ("They sign up and start driving with Hezzni.", "person.badge.plus"),
        ("Earn a bonus when they complete 10 rides.", "gift.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack{
                Text("How it works:")
                    .font(Font.custom("Poppins", size: 14).weight(.medium))
                    .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                Spacer()
            }
            
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.hezzniGreen.opacity(0.15))
                            .frame(width: 32, height: 32)
                        
                        Image(systemName: step.1)
                            .font(.system(size: 14))
                            .foregroundColor(.hezzniGreen)
                    }
                    
                    Text(step.0)
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(.black)
                }
            }
        }
        .padding(.horizontal, 16)
        
    }
}

struct InviteLinkSection: View {
    let inviteLink: String
    @Binding var copied: Bool
    let onCopy: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your invite link:")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "link")
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    
                    Text(inviteLink)
                        .font(Font.custom("Poppins", size: 13))
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Button(action: onCopy) {
                    Text(copied ? "Copied!" : "Copy Link")
                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)
                        )
                }
            }
            .padding(12)
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .cornerRadius(10)
        }
        .padding(.horizontal, 16)
    }
}

struct CopiedToastView: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text("Link copied!")
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.85))
        .clipShape(Capsule())
    }
}

#Preview {
    InviteFriendsScreen()
}
