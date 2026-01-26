//
//  MessageBubbles.swift
//  Hezzni Driver
//

import SwiftUI

struct BotMessageBubble: View {
    let message: HelpChatMessage
    var onSelectOption: ((ChatOption) -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack {
                    Image("hezzni_bot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
            }
            .clipShape(.circle)
            .overlay(
                RoundedRectangle(cornerRadius: 73.37)
                .inset(by: -0.50)
                .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
            )
            
            VStack(alignment: .leading, spacing: 8) {
                if message.type == .text {
                    Text(message.text)
                        .font(Font.custom("Poppins", size: 14))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                        .cornerRadius(16)
                        .cornerRadius(4, corners: [.topLeft])
                }
                
                else if message.type == .options, let options = message.options {
                   
                    VStack(alignment: .leading, spacing: 8) {
                        Text(message.text)
                            .font(Font.custom("Poppins", size: 14))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                            .cornerRadius(16)
                            .cornerRadius(4, corners: [.topLeft])
                        VStack(spacing: 0){
                            ForEach(options) { option in
                                OptionButton(option: option) {
                                    onSelectOption?(option)
                                }
                            }
                            
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.hezzniGreen, lineWidth: 1)
                        )
                    }
                }
                
                Text(formatTime(message.timestamp))
                    .font(Font.custom("Poppins", size: 10))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
#Preview{
    BotMessageBubble(message: ChatViewModel().messages.first!) { option in
//        hasSelectedOption = true
//        viewModel.selectOption(option)
    }
}
struct UserMessageBubble: View {
    let message: HelpChatMessage
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(message.text)
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.hezzniGreen)
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.topRight])
                
                Text(formatTime(message.timestamp))
                    .font(Font.custom("Poppins", size: 10))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct AgentMessageBubble: View {
    let message: HelpChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.hezzniGreen)
                    .frame(width: 32, height: 32)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .font(Font.custom("Poppins", size: 14))
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                    .cornerRadius(16)
                    .cornerRadius(4, corners: [.topLeft])
                
                Text(formatTime(message.timestamp))
                    .font(Font.custom("Poppins", size: 10))
                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

struct TransferNoticeBubble: View {
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 8) {
                
                Text("Transferred to Agent")
                    .font(Font.custom("Poppins", size: 12))
                    .lineSpacing(11)
                    .foregroundColor(Color(red: 0.56, green: 0.56, blue: 0.56))
                Image("profile_placeholder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .cornerRadius(73.37)
                    
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview{
    TransferNoticeBubble()
}

struct OptionButton: View {
    let option: ChatOption
    var onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                Image(systemName: option.icon)
                    .font(.system(size: 14))
                    .foregroundColor(.hezzniGreen)
                
                Text(option.title)
                    .font(Font.custom("Poppins", size: 13).weight(.medium))
                    .foregroundColor(.black)
                
                Spacer()
                
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(width: 210)
            .background(Color.white)
            
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(.hezzniGreen, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct SelectedOptionChip: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(Font.custom("Poppins", size: 13).weight(.medium))
            .foregroundColor(.hezzniGreen)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.hezzniGreen.opacity(0.1))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.hezzniGreen, lineWidth: 1)
            )
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            ZStack {
                    Image("hezzni_bot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
            }
            .clipShape(.circle)
            .overlay(
                RoundedRectangle(cornerRadius: 73.37)
                .inset(by: -0.50)
                .stroke(Color(red: 0.93, green: 0.93, blue: 0.93), lineWidth: 0.50)
            )
            
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color(red: 0.6, green: 0.6, blue: 0.6))
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset(for: index))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .cornerRadius(16)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.6).repeatForever()) {
                    animationOffset = -5
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private func animationOffset(for index: Int) -> CGFloat {
        let delay = Double(index) * 0.2
        return animationOffset * sin(.pi * (delay + 1))
    }
}


