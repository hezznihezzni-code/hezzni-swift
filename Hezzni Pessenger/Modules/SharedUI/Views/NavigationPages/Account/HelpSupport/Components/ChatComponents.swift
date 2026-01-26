//
//  ChatComponents.swift
//  Hezzni Driver
//

import SwiftUI

struct StartConversationCard: View {
    var startAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Start a conversation")
                .font(Font.custom("Poppins", size: 13))
                .foregroundColor(.black.opacity(0.6))
            
            HStack(alignment: .center, spacing: 12) {
                OverlappedAvatars()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Chat with our support team")
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                    Text("Replies within a few minutes")
                        .font(Font.custom("Poppins", size: 12))
                        .foregroundColor(.black.opacity(0.6))
                }
                Spacer()
            }
            PrimaryButton(text: "Start a Conversation"){
                startAction()
            }
//            Button(action: startAction) {
//                Text("Start a Conversation")
//                    .font(Font.custom("Poppins", size: 15).weight(.medium))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 48)
//                    .background(Color.hezzniGreen)
//                    .cornerRadius(10)
//            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 25, y: 8)
        )
    }
}

struct OverlappedAvatars: View {
    var body: some View {
        HStack(spacing: -10) {
            ForEach(0..<4, id: \.self) { idx in
                Circle()
                    .fill(avatarColor(for: idx))
                    .frame(width: 35, height: 35)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
        }
    }
    
    private func avatarColor(for idx: Int) -> Color {
        switch idx {
        case 0: return Color(red: 0.18, green: 0.35, blue: 0.89)
        case 1: return Color(red: 0.91, green: 0.39, blue: 0.14)
        case 2: return Color(red: 0.54, green: 0.35, blue: 0.86)
        default: return Color(red: 0.10, green: 0.65, blue: 0.42)
        }
    }
}

struct RecentChatRow: View {
    let chat: SupportChat
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: { onTap?() }) {
            HStack(alignment: .center, spacing: 12) {
                Circle()
                    .fill(Color.hezzniGreen.opacity(0.15))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.hezzniGreen)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.title)
                        .font(Font.custom("Poppins", size: 13).weight(.medium))
                        .foregroundColor(.black)
                    Text(chat.lastMessage)
                        .font(Font.custom("Poppins", size: 11))
                        .foregroundColor(.black.opacity(0.7))
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 6) {
                    Text(chat.timeAgo)
                        .font(Font.custom("Poppins", size: 10))
                        .foregroundColor(.black.opacity(0.6))
                    
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(Font.custom("Poppins", size: 10).weight(.semibold))
                            .foregroundColor(.hezzniGreen)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.hezzniGreen.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(14)
            .padding(.leading, 6)
            .background(Color.white.opacity(0.50))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.07), radius: 10)
            .overlay(
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 4)
                , alignment: .leading
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct HelpChatHeader: View {
    let title: String
    let subtitle: String
    let isBot: Bool
    var onBack: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: { onBack?() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)
            }
            
            ZStack {
                
                
                if isBot {
                    Image("hezzni_bot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        
                } else {
                    Image("profile_placeholder")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        
                }
            }
            .clipShape(.circle)
            .overlay(
                RoundedRectangle(cornerRadius: 73.37)
                .inset(by: -0.50)
                .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
            )
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(.black)
                    
                    if isBot {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                    }
                }
                
                Text(subtitle)
                    .font(Font.custom("Poppins", size: 11))
                    .foregroundColor(.black.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}
#Preview {
    HelpChatHeader(
        title: "Hezzni Assistant",
        subtitle: "Automated Support",
        isBot: false,
        onBack: { }
    )
}
struct MessageInputBar: View {
    @Binding var text: String
    var onSend: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 10) {
                Image(systemName: "paperclip")
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            .padding(EdgeInsets(top: 13, leading: 15, bottom: 13, trailing: 15))
            .frame(width: 50, height: 50)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(50)
            HStack(spacing: 8) {
                
                
                TextField("Type your message", text: $text)
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(.black)
                Image(systemName: "face.smiling")
                    .font(.system(size: 20))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(height: 50)
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .cornerRadius(24)
            
            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(Color.hezzniGreen)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "paperplane")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(45))
                }
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isDisabled)
            .opacity(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

#Preview{
    MessageInputBar(text: .constant("I am typing..."), onSend: {})
}

struct ConversationResolvedBanner: View {
    var body: some View {
        HStack {
            Spacer()
            Text("This conversation has been resolved")
                .font(Font.custom("Poppins", size: 12))
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
            Spacer()
        }
        .padding(.vertical, 12)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
    }
}
