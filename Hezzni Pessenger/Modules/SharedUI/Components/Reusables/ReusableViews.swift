//
//  ReusableViews.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 10/3/25.
//

import SwiftUI

struct SectionTitle : View {
    var title: String
    
    var body : some View{
        Text(title)
            .font(.poppins(.medium, size: 18.89))
    }
}
