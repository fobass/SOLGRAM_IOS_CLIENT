//
//  MarketDepth.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 2/2/24.
//

import SwiftUI

struct DepthView: View {
    @EnvironmentObject var store: OrderStore
    var instrument_id: Int
    var body: some View {
        VStack {
            HStack{
                Text("Price(USDT)")
                Spacer()
                Text("Amount(SOL)")
            }
            .font(.system(size: 8))
            .foregroundColor(Color.secondary)
//            Spacer()
            VStack {
                ForEach(store.depths.buy_depth.values.sorted(by: { $0.level < $1.level })) { depth in
                    DepthRow(depth: depth, side: Side.BUY)
                }
            }
            Divider()
            VStack {
                ForEach(store.depths.sell_depth.values.sorted(by: { $0.level < $1.level })) { depth in
                    DepthRow(depth: depth, side: Side.SELL)
                }
            }
            
            Spacer()
          
        }
        
        .onAppear(){
            store.subscribeDepth(instrument_id: self.instrument_id)
        }
        .onDisappear() {
            store.unsubscribeDepth(instrument_id: self.instrument_id)
        }
        
    }
}


struct DepthRow: View {
    let depth: DepthSide
    let side: Side
    var body: some View {
        HStack {
            Text(String(format: "%.2f", depth.price))
                .foregroundColor(side == .BUY ? .green : .red )
            Spacer()
            Text(String(format: "%.2f", depth.quantity))
//                .foregroundColor(depth.depth > 0 ? .green : .red)
        }
        .font(.system(size: 10, weight: .medium))
        
    }
}


#Preview {
    DepthView(instrument_id: 495).environmentObject(OrderStore())
}
