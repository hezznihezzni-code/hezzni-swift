//
//  ChatDetailedScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/12/25.
//

import SwiftUI

// MARK: - Models

struct ChatUser {
    let name: String
    let rating: Double
    let trips: Int
    let isVerified: Bool
}

enum MessageType {
    case text(String)
    case audio(duration: String, isOutgoing: Bool)
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let type: MessageType
    let time: String
    let isOutgoing: Bool
}

// MARK: - Chat Bubble View

struct ChatBubble: View {
    let message: ChatMessage
    var body: some View {
        switch message.type {
        case .text(let text):
            VStack(alignment: message.isOutgoing ? .trailing : .leading, spacing: 4) {
                Text(text)
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(message.isOutgoing ? .white : Color(red: 0.09, green: 0.09, blue: 0.09))
                    .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                    .frame(alignment: message.isOutgoing ? .trailing : .leading)
                    .background(message.isOutgoing ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.93, green: 0.93, blue: 0.93))
                    .cornerRadius(10)
                HStack(spacing: 8) {
                    Text(message.time)
                        .font(Font.custom("Poppins", size: 11))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                    if message.isOutgoing {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                    }
                }
                .frame(maxWidth: 270, alignment: message.isOutgoing ? .trailing : .leading)
            }
        case .audio(let duration, let isOutgoing):
            VStack(alignment: isOutgoing ? .trailing : .leading, spacing: 4) {
                HStack(spacing: 10) {
                    AudioWaveform(isOutgoing: isOutgoing)
                    
                    Text(duration)
                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                        .foregroundColor(isOutgoing ? .white : Color(red: 0.22, green: 0.65, blue: 0.33))
                }
                .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                .frame(alignment: isOutgoing ? .trailing : .leading)
                .background(isOutgoing ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color(red: 0.93, green: 0.93, blue: 0.93))
                .cornerRadius(10)
                HStack(spacing: 8) {
                    Text(message.time)
                        .font(Font.custom("Poppins", size: 11))
                        .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                    if isOutgoing {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 12, height: 12)
                            .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                    }
                }
                .frame(maxWidth: 270, alignment: isOutgoing ? .trailing : .leading)
            }
        }
    }
}

// MARK: - Audio Waveform Placeholder

struct AudioWaveform: View {
    let isOutgoing: Bool
    var body: some View {
        HStack(spacing: 10) {
            ZStack(alignment: .center) {
                Circle()
                    .fill(!isOutgoing ? Color(red: 0.22, green: 0.65, blue: 0.33) : Color.white)
                    .frame(width: 38, height: 38)
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 15, height: 15)
                    .foregroundColor(!isOutgoing ? .white : Color(red: 0.22, green: 0.65, blue: 0.33))
            }

            HStack(spacing: 3) {
                ForEach(0..<24) { i in
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 2.9, height: CGFloat([2,11,20,6,22,20,14,14,14,20,14,22,14,6,20,14,14,14,20,14,22,14,6,2][i]))
                        .background(isOutgoing ? Color.white : Color(red: 0.22, green: 0.65, blue: 0.33))
                        .cornerRadius(1.37)
                }
            }
        }
    }
}

// MARK: - Quick Reply Button

struct QuickReplyButton: View {
    let text: String
    var body: some View {
        Text(text)
            .font(Font.custom("Poppins", size: 14))
            .foregroundColor(Color.black.opacity(0.75))
            .padding(EdgeInsets(top: 5, leading: 18, bottom: 5, trailing: 18))
            .background(Color.white)
            .cornerRadius(100)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color.black.opacity(0.5), lineWidth: 0.6)
            )
    }
}

// MARK: - Chat Header

struct ChatHeader: View {
    let user: ChatUser
    var onBack: (() -> Void)? = nil
    var body: some View {
        HStack(spacing: 7) {
            HStack(spacing: 10) {
                Button(action: {
                    onBack?()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.black)
                }
                Circle()
                    .fill(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.5))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image("profile_placeholder")
                            .resizable()
                            .clipShape(Circle())
                    )
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(user.name)
                            .font(Font.custom("Poppins", size: 16).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        if user.isVerified {
                            Image("verified_badge")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(Color(red: 1.00, green: 0.76, blue: 0.03))
                        Text(String(format: "%.1f", user.rating))
                            .font(Font.custom("Poppins", size: 11).weight(.medium))
                            .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                        
                        Text("(\(user.trips) trips)")
                            .font(Font.custom("Poppins", size: 10).weight(.medium))
                            .foregroundColor(.black.opacity(0.60))
                    }
                }
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "phone")
                    .foregroundColor(.white)
                    .frame(width: 22.5, height: 22.5)
                    .padding(15.75)
                    .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                    .cornerRadius(900)
                    .overlay(
                        RoundedRectangle(cornerRadius: 900)
                            .stroke(Color(red: 0.90, green: 0.92, blue: 0.98), lineWidth: 0.45)
                    )
            }
        }
        .padding(EdgeInsets(top: 6, leading: 16, bottom: 12, trailing: 16))
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 2)
    }
}

// MARK: - Chat Input Bar

struct ChatInputBar: View {
    @Binding var message: String
    var onSend: () -> Void
    var body: some View {
        HStack(spacing: 7) {
            HStack(spacing: 10) {
                TextField("Type your message", text: $message)
                    .font(Font.custom("Poppins", size: 14))
                    .overlay(
                        Image(systemName: "face.smiling")
                            .frame(width: 20.83, height: 20.83)
                    , alignment: .trailing)
                    .foregroundColor(Color(red: 0.58, green: 0.58, blue: 0.58))
                    .padding(EdgeInsets(top: 2, leading: 15, bottom: 2, trailing: 15))
                    .frame(height: 50)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(50)
                
            }
            Button(action: {
                if !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSend()
                }
            }) {
                if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Image(systemName: "mic.fill")
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .padding(13)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .cornerRadius(50)
                } else {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .padding(13)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33))
                        .cornerRadius(50)
                }
            }
        }
        .padding(EdgeInsets(top: 20, leading: 12, bottom: 15, trailing: 12))
        .background(Color.white)
        .overlay(
            Rectangle()
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 10)
    }
}

// MARK: - Main Chat Detail Screen

struct ChatDetailedScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    @Environment(\.dismiss) private var dismiss // Add this line

    let user = ChatUser(name: "Ahmed Hassan", rating: 4.8, trips: 2847, isVerified: true)
    @State private var messages: [ChatMessage] = [
        ChatMessage(type: .text("Hello! I’m on my way to pick you up. I’ll be there in 3 minutes."), time: "10:03 PM", isOutgoing: false),
        ChatMessage(type: .text("Great, thanks! I’ll be waiting outside."), time: "10:03 PM", isOutgoing: true),
        ChatMessage(type: .text("I’m in a white Toyota Camry, license plate ABC-1234"), time: "10:03 PM", isOutgoing: false),
        ChatMessage(type: .text("On my way"), time: "10:03 PM", isOutgoing: true),
        ChatMessage(type: .audio(duration: "1:30", isOutgoing: false), time: "10:03 PM", isOutgoing: false),
        ChatMessage(type: .audio(duration: "1:30", isOutgoing: true), time: "10:03 PM", isOutgoing: true),
        ChatMessage(type: .text("Waiting for you"), time: "10:03 PM", isOutgoing: false),
        ChatMessage(type: .text("ok"), time: "10:03 PM", isOutgoing: true)
    ]
    let quickReplies = ["I’m here", "Running 2 min late", "Can you wait?"]
    @State private var messageText: String = ""
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ChatHeader(user: user, onBack: {
                    navigationState.showBottomBar()
                    dismiss()
                }) // Pass dismiss to onBack
                // Messages
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Spacer()
                            Text("Today")
                                .font(Font.custom("Poppins", size: 11))
                                .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                            Spacer()
                        }
                        ForEach(messages) { message in
                            HStack {
                                if message.isOutgoing { Spacer() }
                                ChatBubble(message: message)
                                if !message.isOutgoing { Spacer() }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                }
                // Quick replies
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(quickReplies, id: \ .self) { reply in
                            QuickReplyButton(text: reply)
                        }
                    }
                    .padding(.leading, 15)
                }
                .frame(height: 54)
                // Input bar
                ChatInputBar(message: $messageText, onSend: addMessage)
            }
            .background(Color.white)
        }
        .cornerRadius(24)
        .frame(maxWidth: 402, maxHeight: 1021)
        .background(Color.white)
        .onAppear{
            navigationState.hideBottomBar()
        }
    }
    private func addMessage() {
        let trimmed = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let time = formatter.string(from: Date())
        messages.append(ChatMessage(type: .text(trimmed), time: time, isOutgoing: true))
        messageText = ""
    }
}

// MARK: - Preview

struct ChatDetailedScreen_Previews: PreviewProvider {
    static var previews: some View {
        ChatDetailedScreen()
    }
}
