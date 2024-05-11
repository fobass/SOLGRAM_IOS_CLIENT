//
//  MarketDepth.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 2/2/24.
//

import SwiftUI

struct DepthView: View {
    @ObservedObject var store: OrderStore
    var instrument_id: Int
    var body: some View {
        VStack {
            HStack{
                Text("Price(USDT)")
                Spacer()
                Text("Amount(SOL)")
            }
            .font(Font.system(size: 10))
            
            VStack {
                ForEach(store.depths.filter { $0.buy_depth > 0 }) { depth in
                    DepthRow(depth: depth, side: Side.BUY)
                }
            }
            Divider()
            VStack {
                ForEach(store.depths.filter { $0.sell_depth > 0 }) { depth in
                    DepthRow(depth: depth, side: Side.SELL)
                }
            }
        }
        .padding()
        .onAppear(){
            store.subscribeDepth(depth: MarketDepthPayload(_type: .MarketDepth, payload: self.instrument_id))
        }
    }
}

struct DepthRow: View {
    let depth: Depth
    let side: Side
    var body: some View {
        HStack {
            Text(String(format: "%.2f", depth.price))
                .foregroundColor(side == .BUY ? .green : .red )
            Spacer()
            Text(String(format: "%.2f", depth.depth))
//                .foregroundColor(depth.depth > 0 ? .green : .red)
        }
        
    }
}


#Preview {
    DepthView(store: OrderStore(), instrument_id: 495).environmentObject(OrderStore())
}
