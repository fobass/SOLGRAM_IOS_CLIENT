//
//  Extensions.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 9/27/24.
//

import Foundation


extension Formatter {
    static let abbreviated: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        formatter.positiveSuffix = "K"
        return formatter
    }()
}

extension Int {
    func abbreviated() -> String {
        let num = Int(self)
        switch num {
        case 1_000_000...:
            let formatted = Formatter.abbreviated.string(from: NSNumber(value: num / 1_000_000)) ?? ""
            return "\(formatted)"
        case 1_000...:
            let formatted = Formatter.abbreviated.string(from: NSNumber(value: num / 1_000)) ?? ""
            return "\(formatted)"
        default:
            return "\(self)"
        }
    }
}
