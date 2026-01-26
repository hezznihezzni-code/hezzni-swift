//
//  SearchableDropDown.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/3/25.
//

import SwiftUI

struct SearchableDropdown<T: Identifiable & Hashable>: View where T: CustomStringConvertible {
    let title: String
    @Binding var selection: T?
    let options: [T]
    let placeholder: String
    @State private var isExpanded = false
    @State private var searchText = ""
    
    var filteredOptions: [T] {
        if searchText.isEmpty {
            return options
        }
        return options.filter { $0.description.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(Font.custom("Poppins", size: 14).weight(.medium))
                .foregroundColor(Color(red: 0.03, green: 0.03, blue: 0.03))
            
            ZStack(alignment: .leading) {
                // Display selected item or placeholder
                HStack {
                    Text(selection?.description ?? placeholder)
                        .font(Font.custom("Poppins", size: 14).weight(.light))
                        .foregroundColor(selection == nil ? Color(red: 0.09, green: 0.09, blue: 0.09) : .black)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.horizontal, 16)
                .frame(height: 46)
                .background(Color.white)
                .cornerRadius(7.51)
                .overlay(
                    RoundedRectangle(cornerRadius: 7.51)
                        .inset(by: 0.47)
                        .stroke(Color(red: 0.86, green: 0.86, blue: 0.86), lineWidth: 0.47)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }
            }
            
            if isExpanded {
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search \(title)...", text: $searchText)
                            .font(Font.custom("Poppins", size: 14))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Options list
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredOptions) { option in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        selection = option
                                        isExpanded = false
                                        searchText = ""
                                    }
                                }) {
                                    HStack {
                                        Text(option.description)
                                            .font(Font.custom("Poppins", size: 14))
                                            .foregroundColor(.black)
                                        
                                        Spacer()
                                        
                                        if selection?.id == option.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 16)
                                }
                                .background(Color.white)
                                
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 200)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }
}

// Extend Country and City to be CustomStringConvertible
extension Country: CustomStringConvertible {
    var description: String {
        return "\(flag) \(name)"
    }
}

