//
//  QuoteDetailView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import SwiftUI

struct MarketDepthView: View {
    var body: some View {
        VStack {
//            Text("Market Depth Chart")
//                .font(.title)
//                .padding()

            Spacer()
            HStack{
                Text("Bid")
                Spacer()
                Text("Price(USDT)")
                Spacer()
                Text("Ask")
            }
            .font(Font.system(size: 10))
            HStack {
                // Buy Orders
                VStack{
                    ForEach(1...10, id: \.self) { _ in
                        HStack{
                            Text("ddd")
                            
                            Spacer()
                            Rectangle()
                                .fill(Color.green)
                                .frame(height: 20)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                            
                        }
                    }
                }
                Spacer()
                // Sell Orders
                VStack {
                    ForEach(1...10, id: \.self) { _ in
                        HStack{
                            Rectangle()
                                .fill(Color.red)
                                .frame(height: 20)
                                .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                            Spacer()
                            Text("ddd")
                        }
                    }
                }
//                .frame(width: 50)
            }

            Spacer()
        }
//        .padding()
    }
}

//struct MarketDepthView_Previews: PreviewProvider {
//    static var previews: some View {
//        MarketDepthView()
//    }
//}



struct QuoteDetailView: View {
    @Binding var selectTradeTab: Int
    @EnvironmentObject var instrumentStore: InstrumentStore
    @State private var selection: Int = 0
    var instrument: Instrument
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appData: AppData
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
//                Spacer()
                        HStack {
                            HStack(spacing: 15){
                                HStack{
                                    Text("24h High")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color.secondary)
                                    Text("\(String(format: "%.2f", instrumentStore.detail.high_24 as CVarArg))")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                HStack{
                                    Text("23h Low")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color.secondary)
                                    Text("\(String(format: "%.2f", instrumentStore.detail.low_24 as CVarArg))")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                HStack{
                                    Text("Volume")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(Color.secondary)
                                    Text("\(String(format: "%.2f", instrumentStore.detail.vol_24 as CVarArg))")
                                        .foregroundColor(.red)
                                        .font(.system(size: 12, weight: .bold))
                                }
                                Spacer()
                                
                            }
                            .padding(10)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                            .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
                            
                           
                            
                            Button(action: {
                                
                            }) {
                                Image(systemName: "star")
                                    .font(Font.system(size: 12))
                            }
                            .padding(10)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                            .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
                            
                        }
                        VStack{
                            ChartView(instrumnet_id: instrument.instrument_id).environmentObject(instrumentStore)
                            
                        }
                        .padding(10)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                        .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
                            
//                        VStack{
//                            Spacer()
//                            HStack{
//                                
//                                VStack(alignment: .leading, spacing: 5){
//                                    Text("24h High")
//                                        .foregroundColor(.orange)
//                                    Text("24h Low")
//                                        .foregroundColor(.orange)
//                                    Text("24h Vol(SOL)")
//                                        .foregroundColor(.orange)
//                                    Text("24h Vol(USDT")
//                                        .foregroundColor(.orange)
//                                }
//                                .padding(5)
//                                Spacer()
//                                VStack(alignment: .leading, spacing: 5){
//                                    Text("\(String(format: "%.2f", instrumentStore.detail.high_24 as CVarArg))")
//                                        .foregroundColor(.green)
//                                    Text("\(String(format: "%.2f", instrumentStore.detail.low_24 as CVarArg))")
//                                        .foregroundColor(.red)
//                                    Text("\(String(format: "%.2f", instrumentStore.detail.vol_24 as CVarArg))")
//                                        .foregroundColor(.red)
//                                    Text("0.55")
//                                        .foregroundColor(.green)
//                                }
//                                .padding(5)
//                            }
//                            .padding(20)
//                            .font(Font.system(size: 11))
//                        }
//                        .frame(maxWidth: .infinity, maxHeight: 70)
//                        Spacer()
                    
            }

            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack{
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "bell")
                                .font(Font.system(size: 12))
                        }
                        .padding(10)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                        .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
                        
                        Button(action: {
                            selectTradeTab = 1
                            let orderPad = OrderPad(side: Side.BUY, instrumnet: instrument)
                            appData.dataForTrade = orderPad
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Spacer()
                            Text("BUY")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.primary)
                                .padding(10)
                            Spacer()
                        }
                        .background(.green)
                        .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
                        
                        Button(action: {
                            selectTradeTab = 1
                            let orderPad = OrderPad(side: Side.SELL, instrumnet: instrument)
                            appData.dataForTrade = orderPad
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Spacer()
                            Text("SELL")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Color.primary)
                                .padding(10)
                            Spacer()
                        }
                       
                        .background(.red)
                        .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
                      
                    }
                    .padding(.top, 10)
                }
                
            }
    }
        .onAppear(){
            instrumentStore.getInstrumentById(id: instrument.id)
        }
        .padding([.trailing, .leading], 10)
        .navigationBarBackButtonHidden()
        .navigationBarItems(leading:
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }

                
                HStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle")
                        .font(.system(size: 24, weight: .bold))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(String(instrument.code))")
                            .font(.system(size: 12, weight: .bold))
                        
                        Text("Vol \(String(instrument.volume))")
                            .font(.system(size: 9, weight: .medium))
                    }
                }
                
                Spacer()
            }
        )


        .navigationBarItems(trailing:
                VStack(alignment: .trailing){
                    Text("\(String(format: "%.3f", instrument.last_price))")
                        .font(.system(size: 12, weight: .bold))
                    Text("\(String(instrument.change))")
                       .font(.system(size: 10, weight: .medium))
                }
            )
    }
    
}


#Preview {
    QuoteDetailView(selectTradeTab: .constant(0), instrument: Instrument.init(instrument_id: 8, code: "ADA", symbol: "Cordana", last_price: 50, prev_price: 45, change: 1.2, volume: 0, spark: [])).environmentObject(InstrumentStore()).environmentObject(AppData())
}
