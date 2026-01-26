//
//  Person.swift
//  Hezzni Pessenger
//
//  Created by Zohaib Ahmed on 9/26/25.
//

import SwiftUI

struct Person {
    let id: String
    let name: String
    let phoneNumber: String
    let rating: Double
    let tripCount: Int
    let imageUrl: String?
    
    init(id: String, name: String, phoneNumber: String, rating: Double, tripCount: Int, imageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.phoneNumber = phoneNumber
        self.rating = rating
        self.tripCount = tripCount
        self.imageUrl = imageUrl
    }
}
