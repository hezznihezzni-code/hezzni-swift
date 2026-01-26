//
//  MatchedGeometry.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/12/25.
//

import SwiftUI

struct MatchedGeometryEffect: ViewModifier {
    let namespace: Namespace.ID
    let id: String
    let size: CGSize
    let position: CGPoint
    
    func body(content: Content) -> some View {
        content
            .matchedGeometryEffect(id: id, in: namespace)
            .frame(width: size.width, height: size.height)
            .position(position)
    }
}
