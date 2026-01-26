//
//  DatatypeExtension.swift
//  Hezzni Driver
//
//  Created by Zohaib Ahmed on 9/8/25.
//
internal import Combine
extension Int {
    var leadingZero: String {
        self < 10 ? "0\(self)" : "\(self)"
    }
}
