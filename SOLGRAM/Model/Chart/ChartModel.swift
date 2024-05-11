//
//  ChartModel.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import Foundation


struct Candle: Identifiable {
    var id = UUID().uuidString
    var name: String
    var day: Int
    var lowPrice: Double
    var highPrice: Double
    var openPrice: Double
    var closePrice: Double
}
