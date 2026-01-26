//
//  ChatModels.swift
//  Hezzni Driver
//

import SwiftUI
internal import Combine

struct SupportChat: Identifiable {
    let id = UUID()
    let title: String
    let lastMessage: String
    let timeAgo: String
    let unreadCount: Int
    var isResolved: Bool = false
}

enum MessageSender {
    case bot
    case user
    case agent
}

enum HelpMessageType {
    case text
    case options
    case transferNotice
}

struct HelpChatMessage: Identifiable {
    let id = UUID()
    let sender: MessageSender
    let type: HelpMessageType
    let text: String
    var options: [ChatOption]? = nil
    var timestamp: Date = Date()
    var agentName: String? = nil
    var agentAvatar: String? = nil
}

struct ChatOption: Identifiable, Hashable {
    let id = UUID()
    let icon: String
    let title: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChatOption, rhs: ChatOption) -> Bool {
        lhs.id == rhs.id
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [HelpChatMessage] = []
    @Published var isTyping: Bool = false
    @Published var isResolved: Bool = false
    @Published var currentAgent: String? = nil
    @Published var showAgent: Bool = false
    
    let supportOptions: [ChatOption] = [
        ChatOption(icon: "car.fill", title: "Ride or Driver"),
        ChatOption(icon: "shippingbox.fill", title: "Delivery"),
        ChatOption(icon: "creditcard.fill", title: "Payment or Refund"),
        ChatOption(icon: "key.fill", title: "Rental"),
        ChatOption(icon: "person.fill", title: "Account or Profile"),
        ChatOption(icon: "app.fill", title: "App Issue"),
        ChatOption(icon: "ellipsis.circle.fill", title: "Other")
    ]
    
    init() {
        sendInitialBotMessage()
    }
    
    func sendInitialBotMessage() {
        let welcomeMessage = HelpChatMessage(
            sender: .bot,
            type: .options,
            text: "Hi there! 👋\n\nWelcome to Hezzni Support.\nLet's get you to the right team.\nWhat would you like help with today?\n\nSelect one of the options below:",
            options: supportOptions
        )
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.messages.append(welcomeMessage)
//        }
    }
    
    func selectOption(_ option: ChatOption) {
        let userMessage = HelpChatMessage(
            sender: .user,
            type: .text,
            text: option.title
        )
        messages.append(userMessage)
        
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isTyping = false
            
            let botResponse = HelpChatMessage(
                sender: .bot,
                type: .text,
                text: "Got it!\n\nPlease describe your issue with \(option.title.lowercased()) in a few words."
            )
            self.messages.append(botResponse)
        }
    }
    
    func sendMessage(_ text: String) {
        let userMessage = HelpChatMessage(
            sender: .user,
            type: .text,
            text: text
        )
        messages.append(userMessage)
        
        if !showAgent {
            isTyping = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isTyping = false
                
                let botResponse = HelpChatMessage(
                    sender: .bot,
                    type: .text,
                    text: "Thanks for the details!\n\nWe're connecting you with one of our support agents now. Please hold on for a moment 🙏"
                )
                self.messages.append(botResponse)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.transferToAgent()
                }
            }
        } else {
            simulateAgentResponse()
        }
    }
    
    func transferToAgent() {
        let transferMessage = HelpChatMessage(
            sender: .bot,
            type: .transferNotice,
            text: "Transferred to Agent"
        )
        messages.append(transferMessage)
        
        showAgent = true
        currentAgent = "Sara from Support"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let agentMessage = HelpChatMessage(
                sender: .agent,
                type: .text,
                text: "Hi! This is Sara from Hezzni Support.\nI see you're having an issue with your payment — could you please share the transaction ID or date?",
                agentName: "Sara",
                agentAvatar: "agent_sara"
            )
            self.messages.append(agentMessage)
        }
    }
    
    func simulateAgentResponse() {
        isTyping = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isTyping = false
            
            let responses = [
                "Thanks! I've checked it — looks like one charge is pending and will be refunded automatically within 24 hours.\n\nYou'll receive a confirmation once it's processed.",
                "I understand your concern. Let me look into this for you.",
                "Is there anything else I can help you with?"
            ]
            
            let agentMessage = HelpChatMessage(
                sender: .agent,
                type: .text,
                text: responses.randomElement() ?? responses[0],
                agentName: "Sara",
                agentAvatar: "agent_sara"
            )
            self.messages.append(agentMessage)
        }
    }
    
    func resolveConversation() {
        isResolved = true
    }
}
