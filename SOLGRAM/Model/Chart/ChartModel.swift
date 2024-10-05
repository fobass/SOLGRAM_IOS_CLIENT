//
//  ChartModel.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import Foundation


//struct Candle: Identifiable {
//    var id = UUID().uuidString
//    var name: String
//    var day: Int
//    var lowPrice: Double
//    var highPrice: Double
//    var openPrice: Double
//    var closePrice: Double
//}

struct Candle: Codable, Identifiable, Equatable {
    var id: Int {
        chart_data_id
    }
    var chart_data_id: Int
    var instrument_id: Int
    var open_price: Double
    var close_price: Double
    var high_price: Double
    var low_price: Double
    var volume: Double
    var timestamp: Date
    
    static func == (lhs: Candle, rhs: Candle) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.timestamp == rhs.timestamp &&
                   lhs.open_price == rhs.open_price &&
                   lhs.close_price == rhs.close_price &&
                   lhs.high_price == rhs.high_price &&
                   lhs.low_price == rhs.low_price &&
                   lhs.volume == rhs.volume
        }
}
