//
//  ChartView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import SwiftUI
import Charts

var candle_btc: [Candle] = [
    Candle.init(name: "BTC", day: 1, lowPrice: 3000, highPrice: 7000, openPrice: 4000, closePrice: 4500),
    Candle.init(name: "BTC", day: 2, lowPrice: 6000, highPrice: 3000, openPrice: 3000, closePrice: 3500),
    Candle.init(name: "BTC", day: 3, lowPrice: 4000, highPrice: 5000, openPrice: 2000, closePrice: 2500),
    Candle.init(name: "BTC", day: 4, lowPrice: 3000, highPrice: 6000, openPrice: 5000, closePrice: 5500),
    Candle.init(name: "BTC", day: 5, lowPrice: 5000, highPrice: 7000, openPrice: 7000, closePrice: 6500),
    Candle.init(name: "BTC", day: 6, lowPrice: 6000, highPrice: 8000, openPrice: 8000, closePrice: 7500),
    Candle.init(name: "BTC", day: 7, lowPrice: 7000, highPrice: 9000, openPrice: 6000, closePrice: 6500),
]

struct ChartView: View {
    var body: some View {
//        NavigationStack{
//            VStack{
                Chart {
                    ForEach(candle_btc) { item in
                        RectangleMark(x: .value("Day", item.day),
                                      yStart: .value("Low Price", item.lowPrice),
                                      yEnd: .value("High Price", item.highPrice),
                                      width: 1
                        )
                        
                        
                        RectangleMark(x: .value("Day", item.day),
                                      yStart: .value("Open Price", item.openPrice),
                                      yEnd: .value("Close Price", item.closePrice),
                                      width: 12
                        )
                    }
                }
                
//            }
            
//            .background(.green)
//            Spacer()
//        }
    }
}

#Preview {
    ChartView()
}
