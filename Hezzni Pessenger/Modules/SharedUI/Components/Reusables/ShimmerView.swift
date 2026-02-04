//
//  ShimmerView.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 2/3/26.
//

import SwiftUI

// MARK: - Shimmer Effect Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.clear,
                            Color.white.opacity(0.5),
                            Color.clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Service Card Shimmer Placeholder
struct ServiceCardShimmer: View {
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 70, height: 70)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 12)
        }
        .frame(width: 112, height: 120)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.white)
                .shadow(color: Color(hex: "#04060F").opacity(0.06), radius: 10, x: 0, y: 2)
        )
        .shimmer()
    }
}

// MARK: - Services Shimmer Loading View
struct ServicesShimmerView: View {
    let itemCount: Int
    
    init(itemCount: Int = 5) {
        self.itemCount = itemCount
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<itemCount, id: \.self) { _ in
                    ServiceCardShimmer()
                }
            }
            .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .background(.white)
    }
}

#Preview {
    VStack {
        ServicesShimmerView()
        ServiceCardShimmer()
    }
}
