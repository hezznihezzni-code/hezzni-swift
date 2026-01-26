//
//  BottomNavigationBar.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/10/25.
//

import SwiftUI
struct BottomNavigationBar: View {
    @Binding var selectedTab: Tab
    @State private var tabFrames: [Tab: CGRect] = [:]
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case services = "Services"
        case history = "History"
        case chat = "Chat"
        case account = "Account"
        
        var iconName: String {
            switch self {
            case .home: return "home-icon"
            case .services: return "services-icon"
            case .history: return "history-icon"
            case .chat: return "chat-icon"
            case .account: return "account-icon"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    NavigationIcon(
                        icon: tab.iconName,
                        title: tab.rawValue,
                        selected: selectedTab == tab,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        }
                    )
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: TabFramePreferenceKey.self, value: [tab: geometry.frame(in: .named("NavigationBar"))])
                        }
                    )
                    
                    if tab != .account {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
            .padding(.top, 10) // remove this to get old
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
            )
            .edgesIgnoringSafeArea(.all)
            .onPreferenceChange(TabFramePreferenceKey.self) { value in
                self.tabFrames = value
            }
            //remove this
//            // Pill indicator that hovers above the background
//            if let selectedFrame = tabFrames[selectedTab] {
//                Capsule()
//                    .fill(Color.hezzniGreen)
//                    .frame(width: 42, height: 5)
//                    .position(x: selectedFrame.midX, y: selectedFrame.minY) // Position above the tab content
//                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
//            }
        }
        .coordinateSpace(name: "NavigationBar")
        .frame(height: 90) // Fixed height for the navigation bar
        .edgesIgnoringSafeArea(.all)
    }
}

struct RentalBottomNavigationBar: View {
    @Binding var selectedTab: Tab
    @State private var tabFrames: [Tab: CGRect] = [:]
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case myVehicles = "My Vehicles"
        case chat = "Chat"
        case account = "Account"
        
        var iconName: String {
            switch self {
            case .home: return "home-icon"
            case .myVehicles: return "my-vehicles"
            case .chat: return "chat-icon"
            case .account: return "account-icon"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    NavigationIcon(
                        icon: tab.iconName,
                        title: tab.rawValue,
                        selected: selectedTab == tab,
                        onTap: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = tab
                            }
                        }
                    )
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: RentalTabFramePreferenceKey.self, value: [tab: geometry.frame(in: .named("NavigationBar"))])
                        }
                    )
                    
                    if tab != .account {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
            .padding(.top, 10) // remove this to get old
            .background(
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -2)
            )
            .edgesIgnoringSafeArea(.all)
            .onPreferenceChange(RentalTabFramePreferenceKey.self) { value in
                self.tabFrames = value
            }
            //remove this
//            // Pill indicator that hovers above the background
//            if let selectedFrame = tabFrames[selectedTab] {
//                Capsule()
//                    .fill(Color.hezzniGreen)
//                    .frame(width: 42, height: 5)
//                    .position(x: selectedFrame.midX, y: selectedFrame.minY) // Position above the tab content
//                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
//            }
        }
        .coordinateSpace(name: "NavigationBar")
        .frame(height: 90) // Fixed height for the navigation bar
        .edgesIgnoringSafeArea(.all)
    }
}

struct NavigationIcon: View {
    let icon: String
    let title: String
    var selected: Bool = false
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(icon)
                    .frame(width: 24, height: 24)
                    .foregroundColor(selected ? .hezzniGreen : .blackwhite.opacity(0.5))
                
                Text(title)
                    .font(.poppins(.medium, size: 10))
                    .foregroundColor(selected ? .hezzniGreen : .blackwhite.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .padding(.horizontal, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selected ? Color.hezzniGreen.opacity(0.1) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Preference key to track tab frames
struct TabFramePreferenceKey: PreferenceKey {
    static var defaultValue: [BottomNavigationBar.Tab: CGRect] = [:]
    
    static func reduce(value: inout [BottomNavigationBar.Tab: CGRect], nextValue: () -> [BottomNavigationBar.Tab: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

// Preference key to track tab frames
struct RentalTabFramePreferenceKey: PreferenceKey {
    static var defaultValue: [RentalBottomNavigationBar.Tab: CGRect] = [:]
    
    static func reduce(value: inout [RentalBottomNavigationBar.Tab: CGRect], nextValue: () -> [RentalBottomNavigationBar.Tab: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}


#Preview {
    struct BottomNavigationBarPreview: View {
        @State private var selectedTab: BottomNavigationBar.Tab = .home
        
        var body: some View {
            VStack {
                Spacer()
                
                Text("Selected Tab: \(selectedTab.rawValue)")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                BottomNavigationBar(selectedTab: $selectedTab)
            }
            .background(Color.gray.opacity(0.1))
        }
    }
    
    return BottomNavigationBarPreview()
}


#Preview {
    struct RentalBottomNavigationBarPreview: View {
        @State private var selectedTab: RentalBottomNavigationBar.Tab = .home
        
        var body: some View {
            VStack {
                Spacer()
                
                Text("Selected Tab: \(selectedTab.rawValue)")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                RentalBottomNavigationBar(selectedTab: $selectedTab)
            }
            .background(Color.gray.opacity(0.1))
        }
    }
    
    return RentalBottomNavigationBarPreview()
}
