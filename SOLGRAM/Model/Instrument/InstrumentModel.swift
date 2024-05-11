//
//  Instrument.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/23/24.
//

import Foundation

struct FeedDataPayload: Identifiable, Decodable {
    var id: Int {
        instrument_id
    }
    var instrument_id: Int
    var last_price: Double
    var prev_price: Double
    var change: Double
    
    enum CodingKeys: String, CodingKey {
        case instrument_id
        case last_price
        case prev_price
        case change
    }
}

struct Instrument: Identifiable, Decodable {
    var id: Int {
        instrument_id
    }

    var instrument_id: Int
    var code: String
    var symbol: String
    var last_price: Double
    var prev_price: Double;
    var change: Double;

    enum CodingKeys: String, CodingKey {
        case instrument_id
        case code
        case symbol
        case last_price
        case prev_price
        case change
    }
}

struct Instrument_Detail: Identifiable, Decodable {
    var id: Int {
        instrument_id
    }

    var instrument_id: Int
    var code: String
    var symbol: String
    var last_price: Double
    var prev_price: Double
    var change: Double
    var today_change: Double
    var day_7_change: Double
    var day_30_change: Double
    var day_90_change: Double
    var day_180_change: Double
    var year_1_change: Double
    var market_cap: Double
    var vol_24 : Double
    var high_24: Double
    var low_24: Double
    var total_vol: Double
}
