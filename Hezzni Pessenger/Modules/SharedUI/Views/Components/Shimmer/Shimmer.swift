//
//  Shimmer.swift
//  Hezzni Pessenger
//
//  Created by Copilot on 2/1/26.
//

import SwiftUI

private struct ShimmerModifier1: ViewModifier {
    var isActive: Bool
    var speed: Double

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { proxy in
                        let size = proxy.size

                        // A moving highlight that sweeps across the view.
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.35),
                                Color.white.opacity(0.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(width: size.width * 0.6, height: size.height)
                        .rotationEffect(.degrees(20))
                        .offset(x: phase * (size.width * 2))
                        .blendMode(.plusLighter)
                        .clipped()
                        .onAppear {
                            phase = -1
                        }
                        .animation(
                            .linear(duration: speed)
                                .repeatForever(autoreverses: false),
                            value: phase
                        )
                        .onAppear {
                            phase = 1
                        }
                    }
                }
            }
            .mask(content)
    }
}

extension View {
    /// Adds a lightweight shimmer effect. Best used on placeholder/skeleton views.
    func shimmer(isActive: Bool = true, speed: Double = 1.2) -> some View {
        modifier(ShimmerModifier1(isActive: isActive, speed: speed))
    }
}
