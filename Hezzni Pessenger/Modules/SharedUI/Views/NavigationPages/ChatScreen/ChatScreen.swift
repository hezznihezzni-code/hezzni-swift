//
//  ChatScreen.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/12/25.
//

import SwiftUI
import Foundation

struct Chat: Identifiable {
    let id: UUID
    let title: String
    let lastMessage: String
    let timeAgo: String
    let unreadCount: Int
    let imageName: String
    
    init(title: String, lastMessage: String, timeAgo: String, unreadCount: Int, imageName: String) {
        self.id = UUID()
        self.title = title
        self.lastMessage = lastMessage
        self.timeAgo = timeAgo
        self.unreadCount = unreadCount
        self.imageName = imageName
    }
}

struct ChatScreen: View {
    @EnvironmentObject private var navigationState: NavigationStateManager
    typealias Tab = ChatTabBar.Tab
    @State private var selectedTab: Tab = .all
    // Selection state
    @State private var selectionMode: Bool = false
    @State private var selectedChats: Set<UUID> = []
    @State private var showChatDetail: Bool = false
    
    // Sample data
    let chats: [Chat] = (0..<8).map { _ in
        Chat(title: "Atlas Car Rental", lastMessage: "Perfect! I can confirm availability and make..", timeAgo: "3 hour ago", unreadCount: 2, imageName: "car_placeholder")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if selectionMode {
                // Selection bar
                HStack {
                    Button(action: {
                        // Exit selection mode
                        selectionMode = false
                        selectedChats.removeAll()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.black)
                    }
                    Text("\(selectedChats.count) Selected")
                        .font(Font.custom("Poppins", size: 20).weight(.medium))
                        .foregroundColor(.black)
                        .padding(.leading, 8)
                    Spacer()
                    Image(systemName: "pin")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.trailing, 16)
                    Image(systemName: "trash")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 20)
            } else {
                // Title
                Text("Chats")
                    .font(Font.custom("Poppins", size: 22).weight(.medium))
                    .padding(.horizontal, 20)
            }
            // Figma-accurate ChatTabBar
            ChatTabBar(selectedTab: $selectedTab)
                .padding(.top, 8)
                .padding(.bottom, 8)
            Divider()
            // Chat list
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(chats) { chat in
                        ChatRow(
                            chat: chat,
                            isSelected: selectedChats.contains(chat.id),
                            selectionMode: selectionMode
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectionMode {
                                if selectedChats.contains(chat.id) {
                                    selectedChats.remove(chat.id)
                                } else {
                                    selectedChats.insert(chat.id)
                                }
                                if selectedChats.isEmpty {
                                    selectionMode = false
                                }
                            } else {
                                showChatDetail = true
                            }
                        }
                        .onLongPressGesture(minimumDuration: 0.3) {
                            if !selectionMode {
                                selectionMode = true
                                selectedChats = [chat.id] // Only select the long-pressed item
                            }
                        }
                        Divider()
                    }
                }
                .background(Color.white)
            }
        }
        .background(.white)
        .fullScreenCover(isPresented: $showChatDetail) {
            ChatDetailedScreen()
        }
        .onAppear{
                navigationState.showBottomBar()
        }
        
    }
}

struct ChatRow: View {
    let chat: Chat
    let isSelected: Bool
    let selectionMode: Bool
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                Image("car_placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                if selectionMode && isSelected {
                    Circle()
                        .fill(Color(.hezzniGreen))
                        .stroke(.white, lineWidth: 2)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 4, y: 4)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(chat.title)
                    .font(.poppins(.semiBold, size: 18))
                    .foregroundColor(.black)
                Text(chat.lastMessage)
                    .font(.poppins(.regular, size: 15))
                    .foregroundColor(Color(.systemGray))
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 8) {
                Text(chat.timeAgo)
                    .font(.poppins(.regular, size: 13))
                    .foregroundColor(Color(.systemGray2))
                if chat.unreadCount > 0 {
                    Text("\(chat.unreadCount)")
                        .font(Font.custom("Poppins", size: 10).weight(.semibold))
                        .foregroundColor(.hezzniGreen)
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color(red: 0.85, green: 0.97, blue: 0.90)))
                        .overlay(
                            Circle().stroke(Color.clear, lineWidth: 0)
                        )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(isSelected ? Color(red: 0.91, green: 0.97, blue: 0.92) : Color.white)
    }
}

#Preview{
    ChatScreen()
}



struct ChatTabBar: View {
    enum Tab: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
        case archived = "Archived"
    }
    
    @Binding var selectedTab: Tab
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    Text(tab.rawValue)
                        .font(Font.custom("Poppins", size: 14).weight(.medium))
                        .foregroundColor(.blackwhite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    Color.white
                                        .cornerRadius(8)
                                        .shadow(color: Color.black.opacity(0.05), radius: 19, x: 0, y: 0)
                                } else {
                                    Color.clear
                                }
                            }
                        )
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(6)
        .background(Color(red: 0.97, green: 0.97, blue: 0.97))
        .cornerRadius(8)
        .padding(.horizontal, 20)
    }
}

// Example usage in a parent view:
// @State private var selectedTab: ChatTabBar.ChatTab = .all
// ChatTabBar(selectedTab: $selectedTab)



struct ChatItem: Identifiable, Codable {
    let id: String
    let title: String
    let lastMessage: String
    let timestamp: String
    let unreadCount: Int
    let archived: Bool
}



struct ChatListItem: View {
    let chat: ChatItem
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .foregroundColor(.clear)
                .padding(17)
                .frame(width: 55, height: 55)
                .background(Color(red: 0.50, green: 0.23, blue: 0.27).opacity(0.50))
                .cornerRadius(68.91)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 10) {
                    Text(chat.title)
                        .font(Font.custom("Poppins", size: 16).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09))
                    Text(chat.timestamp)
                        .font(Font.custom("Poppins", size: 8).weight(.medium))
                        .foregroundColor(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.60))
                }
                HStack(spacing: 10) {
                    Text(chat.lastMessage)
                        .font(Font.custom("Poppins", size: 12).weight(.medium))
                        .foregroundColor(Color(red: 0, green: 0, blue: 0).opacity(0.80))
                        .lineLimit(1)
                    if chat.unreadCount > 0 {
                        VStack(spacing: 10) {
                            Text("\(chat.unreadCount)")
                                .font(Font.custom("Poppins", size: 10).weight(.semibold))
                                .foregroundColor(Color(red: 0.22, green: 0.65, blue: 0.33))
                        }
                        .padding(EdgeInsets(top: 6, leading: 9, bottom: 6, trailing: 9))
                        .frame(width: 20, height: 20)
                        .background(Color(red: 0.22, green: 0.65, blue: 0.33).opacity(0.15))
                        .cornerRadius(11.27)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 13, bottom: 10, trailing: 13))
        .frame(height: 80)
        .background(Color.white)
        .overlay(
            Rectangle()
                .inset(by: 0.50)
                .stroke(Color(red: 0, green: 0, blue: 0).opacity(0.05), lineWidth: 0.50)
        )
    }
}

// Example usage:
// ChatListItem(chat: chatItem)
