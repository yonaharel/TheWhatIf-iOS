//
//  NSNumber + Extensions.swift
//  The What If
//
//  Created by Yona Harel on 04/06/2022.
//

import Foundation

extension NSNumber {
    func getPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0 // You can set what you want
        return formatter.string(from: self)!
    }
}

extension Float {
    func getPercentage() -> String{
        NSNumber(value: self).getPercentage()
    }
}

