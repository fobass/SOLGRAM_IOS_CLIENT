//
//  Extentions.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/26/24.
//

import Foundation


extension Double {
    func abbreviated() -> String {
        let abbreviations = ["", "K", "M", "B", "T"]
        var index = 0
        var number = self

        while number >= 1000.0 && index < abbreviations.count - 1 {
            number /= 1000.0
            index += 1
        }

        return String(format: "%.1f%@", number, abbreviations[index])
    }
}

extension String {
    var capitalizedFirstChar: String {
        return prefix(1).uppercased() + dropFirst().lowercased()
    }
}
