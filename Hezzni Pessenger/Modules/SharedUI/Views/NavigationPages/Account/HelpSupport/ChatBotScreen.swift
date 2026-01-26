//
//  ChatBotScreen.swift
//  Hezzni Driver
//

import SwiftUI

struct ChatBotScreen: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText: String = ""
    @State private var hasSelectedOption: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HelpChatHeader(
                title: viewModel.showAgent ? (viewModel.currentAgent ?? "Support") : "Hezzni Assistant",
                subtitle: viewModel.showAgent ? "Support Agent" : "Automated Support",
                isBot: !viewModel.showAgent,
                onBack: { dismiss() }
            )
            Divider()
            
            if viewModel.showAgent {
                HStack {
                    Text("Today")
                        .font(Font.custom("Poppins", size: 11))
                        .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.98, green: 0.98, blue: 0.98))
            }
            
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            messageView(for: message)
                                .id(message.id)
                        }
                        
                        if viewModel.isTyping {
                            TypingIndicator()
                        }
                    }
                    .padding(.vertical, 16)
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: viewModel.isTyping) { _, _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            if viewModel.isResolved {
                ConversationResolvedBanner()
            } else {
                MessageInputBar(
                    text: $inputText,
                    onSend: sendMessage,
                    isDisabled: !hasSelectedOption && !viewModel.showAgent
                )
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func messageView(for message: HelpChatMessage) -> some View {
        switch message.sender {
        case .bot:
            if message.type == .transferNotice {
                VStack{
                    Divider()
                    TransferNoticeBubble()
                }
                
            } else {
                BotMessageBubble(message: message) { option in
                    hasSelectedOption = true
                    viewModel.selectOption(option)
                }
            }
        case .user:
            UserMessageBubble(message: message)
        case .agent:
            AgentMessageBubble(message: message)
        }
    }
    
    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        viewModel.sendMessage(trimmed)
        inputText = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = viewModel.messages.last {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct ChatBotScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatBotScreen()
    }
}
