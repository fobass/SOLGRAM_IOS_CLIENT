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
struct SparkPoint: Decodable, Identifiable {
    var id: Int {
           Int(x)
       }
    var x: Double
    var y: Double
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
    var volume: Int
    var spark: [SparkPoint]

    enum CodingKeys: String, CodingKey {
        case instrument_id
        case code
        case symbol
        case last_price
        case prev_price
        case change
        case volume
        case spark
    }
    
    mutating func addNewSparkPoint(newY: Double) {
           guard let lastSpark = spark.last else {
               print("No data in spark array")
               return
           }

           // Increment the last SparkPoint's x value
           let newX = lastSpark.x + 1

           // Create a new SparkPoint
           let newSpark = SparkPoint(x: newX, y: newY)

           // Append the new SparkPoint to the end of the array
           spark.append(newSpark)

           // Remove the first SparkPoint to maintain array size (if needed)
           if spark.count > 20 { // Adjust the limit as per your needs
               spark.removeFirst()
           }
       }
}

struct Instrument_Detail: Decodable {

    var instrument_id: Int
//    var code: String
//    var symbol: String
//    var last_price: Double
//    var prev_price: Double
//    var change: Double
//    var today_change: Double
//    var day_7_change: Double
//    var day_30_change: Double
//    var day_90_change: Double
//    var day_180_change: Double
//    var year_1_change: Double
//    var market_cap: Double
    var vol_24 : Double
    var high_24: Double
    var low_24: Double
//    var total_vol: Double
}
