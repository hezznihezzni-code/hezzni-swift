//
//  View.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/10/25.
//

// Extension for rounded corners on specific sides

import SwiftUI
internal import Combine


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}
