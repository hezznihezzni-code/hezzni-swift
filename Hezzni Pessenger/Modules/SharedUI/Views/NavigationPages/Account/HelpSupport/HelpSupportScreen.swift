//
//  HelpSupportScreen.swift
//  Hezzni Driver
//

import SwiftUI

struct HelpSupportScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var showChatScreen = false
    @State private var selectedChat: SupportChat? = nil
    var onBack: (() -> Void)?
    private let recentChats: [SupportChat] = [
        SupportChat(title: "Payment Issue", lastMessage: "Sara: We've processed your refund", timeAgo: "3 hour ago", unreadCount: 2, isResolved: true),
        SupportChat(title: "Driver Rating Issue", lastMessage: "Karla: We've updated your review successfully", timeAgo: "Last Week", unreadCount: 0, isResolved: true),
        SupportChat(title: "Driver Rating Issue", lastMessage: "Karla: We've updated your review successfully", timeAgo: "Last Week", unreadCount: 0, isResolved: true),
        SupportChat(title: "Driver Rating Issue", lastMessage: "Karla: We've updated your review successfully", timeAgo: "Last Week", unreadCount: 0, isResolved: true)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Image("help_support_background")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 300)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .ignoresSafeArea(edges: .top)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        
                        StartConversationCard {
                            showChatScreen = true
                        }
                        .padding(.horizontal, 16)
                        .offset(y: -8)
                        
                        recentChatsSection
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0.98), Color(red: 0.93, green: 0.98, blue: 0.94)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showChatScreen) {
                ChatBotScreen()
            }
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer().frame(height: 60)
            
            Text("Help & Support")
                .font(Font.custom("Poppins", size: 26).weight(.semibold))
                .foregroundColor(.white)
            
            Text("We're here to help. Reach out if you're having any issues with your rides, payments, or deliveries.")
                .font(Font.custom("Poppins", size: 14))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .topLeading) {
            Button(action: { onBack}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
            .padding(.top, 8)
            .padding(.leading, 16)
        }
    }
    
    private var recentChatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent chats")
                .font(Font.custom("Poppins", size: 16).weight(.medium))
                .foregroundColor(.black)
                .padding(.top, 24)
                .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                ForEach(recentChats) { chat in
                    RecentChatRow(chat: chat) {
                        selectedChat = chat
                        showChatScreen = true
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    HelpSupportScreen()
}


////
////  HelpSupportScreen.swift
////  Hezzni Pessenger
////
////  Created by Zohaib Ahmed on 11/5/25.
////
//
//import SwiftUI
//
//enum _home{
//    case main
//    case conversation
//}
//
//struct HelpSupportScreen: View {
//    @EnvironmentObject private var navigationState: NavigationStateManager
//    @Environment(\.dismiss) private var dismiss
//    var onBack: (() -> Void)?
//
//    var currentScreen: _home = .main
//
//    // Mock recent chats
//    private let recentChats: [SupportChat] = [
//        .init(title: "Payment Issue", lastMessage: "Sara: We've processed your refund", timeAgo: "3 hour ago", unreadCount: 2),
//        .init(title: "Driver Rating Issue", lastMessage: "Karla: We've updated your review successfully", timeAgo: "Last Week", unreadCount: 0),
//        .init(title: "Driver Rating Issue", lastMessage: "Karla: We've updated your review successfully", timeAgo: "Last Week", unreadCount: 0),
//        .init(title: "Driver Rating Issue", lastMessage: "Karla: We've updated your review successfully", timeAgo: "Last Week", unreadCount: 0)
//    ]
//
//    var body: some View {
//        ZStack{
//            switch currentScreen {
//            case .main:
//                mainScreen
//                    .transition(.move(edge: .trailing))
//            case .conversation:
//                ChatDetailedScreen1()
//                    .transition(.move(edge: .leading))
//            }
//        }
//        .background(
//            LinearGradient(colors: [Color.white, Color.white.opacity(0.98), Color(red: 0.93, green: 0.98, blue: 0.94)], startPoint: .top, endPoint: .bottom)
//        )
//        .onAppear { navigationState.hideBottomBar() }
//        .navigationBarBackButtonHidden(true)
//    }
//
//    private var header: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Spacer().frame(height: 60) // space under status bar within the image area
//            Text("Help & Support")
//                .font(.poppins(.semiBold, size: 26))
//                .foregroundColor(.white)
//            Text("We're here to help. Reach out if you're having any issues with your rides, payments, or deliveries.")
//                .font(.poppins(size: 14))
//                .foregroundColor(.white.opacity(0.9))
//                .fixedSize(horizontal: false, vertical: true)
//        }
//    }
//
//    private var mainScreen: some View{
//        ZStack(alignment: .top) {
//            // Top background image
//            Image("help_support_background")
//                .resizable()
//                .scaledToFill()
//                .frame(height: 300)
//                .frame(maxWidth: .infinity)
//                .clipped()
//                .ignoresSafeArea(edges: .top)
//
//            // Content
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 0) {
//                    header
//                        .padding(.horizontal, 20)
//
//                        .padding(.bottom, 16)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .background(Color.clear)
//                        .overlay(alignment: .topLeading) {
//                            // Back button
//                            Button(action: {
//                                onBack?()
//                                dismiss()
//                            }) {
//                                Image(systemName: "chevron.left")
//                                    .font(.system(size: 18, weight: .semibold))
//                                    .foregroundColor(.white)
//                                    .frame(width: 36, height: 36)
//                                    .background(Color.white.opacity(0.15))
//                                    .clipShape(Circle())
//                            }
//                            .padding(.top, 8)
//                            .padding(.leading, 16)
//                        }
//
//                    // Conversation card
//                    StartConversationCard(startAction: {
//                        // Hook to open support chat screen later
//                    })
//                    .padding(.horizontal, 16)
//                    .offset(y: -8)
//
//                    // Recent chats section
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Recent chats")
//                            .font(.poppins(.medium, size: 16))
//                            .foregroundColor(.black)
//                            .padding(.top, 24)
//                            .padding(.horizontal, 16)
//
//                        VStack(spacing: 8) {
//                            ForEach(recentChats) { chat in
//                                RecentChatRow(chat: chat)
//                                    .padding(.horizontal, 16)
//                            }
//                        }
//                        .padding(.bottom, 32)
//                    }
//
//                    // Chat view (always scroll to bottom)
//                    ChatConversationView()
//                        .padding(.horizontal, 16)
//                        .padding(.bottom, 32)
//                }
//
//            }
//        }
//    }
//}
//
//
//
//// MARK: - Subviews & Models
//
//private struct StartConversationCard: View {
//    var startAction: () -> Void
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Start a conversation")
//                .font(.poppins(size: 13))
//                .foregroundColor(.black.opacity(0.6))
//
//            HStack(alignment: .center, spacing: 12) {
//                OverlappedAvatars()
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Chat with our support team")
//                        .font(.poppins(.medium, size: 16))
//                        .foregroundColor(.black)
//                    Text("Replies within a few minutes")
//                        .font(.poppins(size: 12))
//                        .foregroundColor(.black.opacity(0.6))
//                }
//                Spacer()
//            }
//
//            PrimaryButton(text: "Start a Conversation", buttonColor: .hezzniGreen, action: startAction)
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 18)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.06), radius: 25, y: 8)
//        )
//    }
//}
//
//private struct OverlappedAvatars: View {
//    var body: some View {
//        HStack(spacing: -10) {
//            ForEach(0..<4) { idx in
//                Image("profile_placeholder")
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 35, height: 35)
//                    .clipShape(RoundedRectangle(cornerRadius: 90))
//                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
//            }
//        }
//    }
//    private func avatarColor(for idx: Int) -> Color {
//        switch idx {
//        case 0: return Color(red: 0.18, green: 0.35, blue: 0.89)
//        case 1: return Color(red: 0.91, green: 0.39, blue: 0.14)
//        case 2: return Color(red: 0.54, green: 0.35, blue: 0.86)
//        default: return Color(red: 0.10, green: 0.65, blue: 0.42)
//        }
//    }
//}
//
//private struct SupportChat: Identifiable {
//    let id = UUID()
//    let title: String
//    let lastMessage: String
//    let timeAgo: String
//    let unreadCount: Int
//}
//
//private struct RecentChatRow: View {
//    let chat: SupportChat
//    var body: some View {
//        HStack(alignment: .center, spacing: 12) {
//            // Avatar placeholder
//            Image("profile_placeholder")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 35, height: 35)
//                .clipShape(RoundedRectangle(cornerRadius: 90))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 90).stroke(Color.black.opacity(0.05), lineWidth: 0.5)
//                )
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(chat.title)
//                    .font(Font.custom("Poppins", size: 13).weight(.medium))
//                    .foregroundColor(.black)
//                Text(chat.lastMessage)
//                    .font(Font.custom("Poppins", size: 11).weight(.medium))
//                    .foregroundColor(.black.opacity(0.7))
//                    .lineLimit(1)
//            }
//            Spacer()
//            VStack(alignment: .trailing, spacing: 6) {
//                Text(chat.timeAgo)
//                    .font(.poppins(size: 10))
//                    .foregroundColor(.black.opacity(0.6))
//                if chat.unreadCount > 0 {
//                    Text("\(chat.unreadCount)")
//                        .font(.poppins(.semiBold, size: 10))
//                        .foregroundColor(.hezzniGreen)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 4)
//                        .background(Color.hezzniGreen.opacity(0.15))
//                        .clipShape(Capsule())
//                }
//            }
//        }
//        .padding(14)
//        .padding(.leading, 6)
//        .background(Color(red: 1, green: 1, blue: 1).opacity(0.50))
//        .cornerRadius(8)
//        .overlay(
//        RoundedRectangle(cornerRadius: 8)
//        .inset(by: 0.50)
//        .stroke(Color(red: 0.89, green: 0.89, blue: 0.89), lineWidth: 0.50)
//        )
//        .shadow(
//        color: Color(red: 0, green: 0, blue: 0, opacity: 0.07), radius: 10
//        )
//        .overlay(
//            Rectangle()
//                .frame(width:8)
//            ,alignment: .leading
//        )
//        .clipShape(RoundedRectangle(cornerRadius: 8))
//    }
//}
//
//// MARK: - Chat Conversation View
//
//private struct ChatConversationView: View {
//    @State private var messages: [String] = [
//        "Hello! How can I help you today?",
//        "I have an issue with my payment.",
//        "Sure, can you provide more details?"
//    ]
//    @State private var inputText: String = ""
//
//    var body: some View {
//        VStack(spacing: 0) {
//            ScrollViewReader { proxy in
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 12) {
//                        ForEach(messages.indices, id: \.self) { idx in
//                            HStack {
//                                if idx % 2 == 0 {
//                                    Text(messages[idx])
//                                        .padding(10)
//                                        .background(Color.gray.opacity(0.2))
//                                        .cornerRadius(10)
//                                        .frame(maxWidth: 250, alignment: .leading)
//                                    Spacer()
//                                } else {
//                                    Spacer()
//                                    Text(messages[idx])
//                                        .padding(10)
//                                        .background(Color.green.opacity(0.2))
//                                        .cornerRadius(10)
//                                        .frame(maxWidth: 250, alignment: .trailing)
//                                }
//                            }
//                            .id(idx)
//                        }
//                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 12)
//                }
//                .onAppear {
//                    scrollToBottom(proxy: proxy)
//                }
//                .onChange(of: messages.count) { _, _ in
//                    scrollToBottom(proxy: proxy)
//                }
//                .onChange(of: inputText) { _, _ in
//                    scrollToBottom(proxy: proxy)
//                }
//            }
//            Divider()
//            HStack {
//                TextField("Type a message...", text: $inputText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .frame(minHeight: 36)
//                Button(action: sendMessage) {
//                    Image(systemName: "paperplane.fill")
//                        .foregroundColor(.blue)
//                }
//                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 8)
//        }
//        .background(Color.white)
//        .cornerRadius(16)
//        .shadow(color: Color.black.opacity(0.04), radius: 8, y: 2)
//        .padding()
//    }
//
//    private func sendMessage() {
//        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//        messages.append(trimmed)
//        inputText = ""
//    }
//
//    private func scrollToBottom(proxy: ScrollViewProxy) {
//        if !messages.isEmpty {
//            withAnimation {
//                proxy.scrollTo(messages.count - 1, anchor: .bottom)
//            }
//        }
//    }
//}
//
//// MARK: - Main Chat Detail Screen
//
//struct ChatDetailedScreen1: View {
//    @EnvironmentObject private var navigationState: NavigationStateManager
//    @Environment(\.dismiss) private var dismiss // Add this line
//
//    let user = ChatUser(name: "Ahmed Hassan", rating: 4.8, trips: 2847, isVerified: true)
//    @State private var messages: [ChatMessage] = [
//        ChatMessage(type: .text("Hello! I’m on my way to pick you up. I’ll be there in 3 minutes."), time: "10:03 PM", isOutgoing: false),
//        ChatMessage(type: .text("Great, thanks! I’ll be waiting outside."), time: "10:03 PM", isOutgoing: true),
//        ChatMessage(type: .text("I’m in a white Toyota Camry, license plate ABC-1234"), time: "10:03 PM", isOutgoing: false),
//        ChatMessage(type: .text("On my way"), time: "10:03 PM", isOutgoing: true),
//        ChatMessage(type: .audio(duration: "1:30", isOutgoing: false), time: "10:03 PM", isOutgoing: false),
//        ChatMessage(type: .audio(duration: "1:30", isOutgoing: true), time: "10:03 PM", isOutgoing: true),
//        ChatMessage(type: .text("Waiting for you"), time: "10:03 PM", isOutgoing: false),
//        ChatMessage(type: .text("ok"), time: "10:03 PM", isOutgoing: true)
//    ]
//    let quickReplies = ["I’m here", "Running 2 min late", "Can you wait?"]
//    @State private var messageText: String = ""
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//                ChatHeader(user: user, onBack: { dismiss() }) // Pass dismiss to onBack
//                // Messages
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 10) {
//                        HStack {
//                            Spacer()
//                            Text("Today")
//                                .font(Font.custom("Poppins", size: 11))
//                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
//                            Spacer()
//                        }
//                        ForEach(messages) { message in
//                            HStack {
//                                if message.isOutgoing { Spacer() }
//                                ChatBubble(message: message)
//                                if !message.isOutgoing { Spacer() }
//                            }
//                        }
//                    }
//                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
//                }
//                // Quick replies
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 10) {
//                        ForEach(quickReplies, id: \ .self) { reply in
//                            QuickReplyButton(text: reply)
//                        }
//                    }
//                    .padding(.leading, 15)
//                }
//                .frame(height: 54)
//                // Input bar
//                ChatInputBar(message: $messageText, onSend: addMessage)
//            }
//            .padding(.bottom, 10)
//            .background(Color.white)
//        }
//        .cornerRadius(24)
//        .ignoresSafeArea(edges: .bottom)
//        .background(Color.white)
//        .onAppear{
//            navigationState.hideBottomBar()
//        }
//    }
//    private func addMessage() {
//        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//        let formatter = DateFormatter()
//        formatter.dateFormat = "h:mm a"
//        let time = formatter.string(from: Date())
//        messages.append(ChatMessage(type: .text(trimmed), time: time, isOutgoing: true))
//        messageText = ""
//    }
//}
//
//// MARK: - Preview
//
//struct ChatDetailedScreen_Previews1: PreviewProvider {
//    static var previews: some View {
//        ChatDetailedScreen()
//    }
//}
