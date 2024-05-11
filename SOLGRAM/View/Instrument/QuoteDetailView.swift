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
    @ObservedObject var appData: AppData
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                ScrollSlidingTabBar(selection: $selection, tabs: ["Chat", "Info", "Recommendations"])
                TabView(selection: $selection) {
                    ScrollView {
                        VStack{
                            HStack{
                                VStack{
                                    HStack{
                                        Text(String(format: "%.3f", instrument.last_price))
                                            .foregroundColor(.green)
                                            .font(Font.system(size: 24))
                                        Spacer()
                                    }
                                    HStack{
                                        Text("=$\(String(format: "%.3f", instrument.last_price))")
                                            .foregroundColor(.orange)
                                        Text("\(String(format: "%.3f", instrument.change))%")
                                            .foregroundColor(.green)
                                        Spacer()
                                    }
                                }
                                Spacer()
                                
                                VStack(alignment: .leading){
                                    Text("24h High")
                                        .foregroundColor(.orange)
                                    Text("24h Low")
                                        .foregroundColor(.orange)
                                    Text("24h Vol(SOL)")
                                        .foregroundColor(.orange)
                                    Text("24h Vol(USDT")
                                        .foregroundColor(.orange)
                                }
                                
                                VStack(alignment: .leading){
                                    Text("\(String(format: "%.3f", instrumentStore.detail.high_24 as CVarArg))%")
                                        .foregroundColor(.green)
                                    Text("\(String(format: "%.3f", instrumentStore.detail.low_24 as CVarArg))%")
                                        .foregroundColor(.red)
                                    Text("12")
                                        .foregroundColor(.red)
                                    Text("0.55")
                                        .foregroundColor(.green)
                                }
                                
                            }
                            .font(Font.system(size: 10))
                            .padding(2)
                            
                            ChartView()
                                .frame(width: 380, height: 400, alignment: .top)
                            
                            HStack(spacing: 30){
                                VStack{
                                    Text("Today")
                                        .foregroundColor(.orange)
                                    Text("\(String(format: "%.3f", instrumentStore.detail.today_change.abbreviated()))%")
                                        .foregroundColor(.green)
                                }
                                VStack{
                                    Text("7 Days")
                                        .foregroundColor(.orange)
                                    Text(instrumentStore.detail.day_7_change.abbreviated())
                                        .foregroundColor(.green)
                                }
                                VStack{
                                    Text("30 Days")
                                        .foregroundColor(.orange)
                                    Text(String(format: "%.2f", instrumentStore.detail.day_30_change))

                                    
                                        .foregroundColor(.green)
                                }
                                VStack{
                                    Text("90 Days")
                                        .foregroundColor(.orange)
                                    Text("\(String(format: "%.3f", instrumentStore.detail.day_90_change as CVarArg))%")
                                        .foregroundColor(.green)
                                }
                                VStack{
                                    Text("180 Days")
                                        .foregroundColor(.orange)
                                    Text("\(String(format: "%.3f", instrumentStore.detail.day_180_change as CVarArg))%")
                                        .foregroundColor(.green)
                                }
                                VStack{
                                    Text("1 Year")
                                        .foregroundColor(.orange)
                                    Text("\(String(format: "%.3f", instrumentStore.detail.year_1_change as CVarArg))%")
                                        .foregroundColor(.green)
                                }
                            }
                            .font(Font.system(size: 10))
                            .padding(2)
                            
                            MarketDepthView()
                        }
                        .padding([.trailing, .leading], 10)
                    }
                    .tag(0)
                    
//                    HStack {
//                        QuoteView()
//                    }
//                    .tag(1)
//                    
//                    HStack {
//                        QuoteView()
//                    }
//                    .tag(2)
//                    
//                    HStack {
//                        QuoteView()
//                    }
//                    .tag(3)
//                    
//                    HStack {
//                        QuoteView()
//                    }
//                    .tag(4)
                    
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.default, value: selection)
            }
            
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack{
                        Button(action: { print("Pressed") }) {
                           Image(systemName: "shuffle.circle")
                        }
                        .background(.gray.opacity(0.3))
                        .cornerRadius(5)
                        
                        Button(action: { print("Pressed") }) {
                            Image(systemName: "wallet.pass")
                        }
                        .background(.gray.opacity(0.3))
                        .cornerRadius(5)
                        
                        Button(action: { print("Pressed") }) {
                           Image(systemName: "shuffle.circle")
                        }
                        .background(.gray.opacity(0.3))
                        .cornerRadius(5)
                        
                        Button(action: { print("Pressed") }) {
                            Image(systemName: "wallet.pass")
                        }
                        .background(.gray.opacity(0.3))
                        .cornerRadius(5)
                    }
                    Spacer()
                }

                ToolbarItem(placement: .bottomBar) {
                    HStack{
                        Button(action: {
                            selectTradeTab = 1
                            let orderPad = OrderPad(side: Side.SELL, instrumnet: instrument)
                            appData.dataForTrade = orderPad
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Spacer()
                            Text("SELL")
                                .font(.custom("", fixedSize: 15))
                                .padding(5)
                            Spacer()
                        }
                        .background(.red)
                        .cornerRadius(5)
                        
                        Button(action: {
                            selectTradeTab = 1
                            let orderPad = OrderPad(side: Side.BUY, instrumnet: instrument)
                            appData.dataForTrade = orderPad
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Spacer()
                            Text("BUY")
                                .font(.headline)
                                .padding(5)
                            Spacer()
                        }
                        .background(.green)
                        .cornerRadius(5)
                    }

                }

            }

        }
        .onAppear(){
            instrumentStore.getInstrumentById(id: instrument.id)
        }
        .navigationTitle("\(instrument.code)")
        .navigationBarItems(trailing:
                Button(action: {
                    print("Navigation bar item action")
                }) {
                    Image(systemName: "bell.circle.fill")
                        .font(Font.system(.title))
                }
            )
    }
}


#Preview {
    QuoteDetailView(selectTradeTab: .constant(0), instrument: Instrument.init(instrument_id: 8, code: "ADA", symbol: "Cordana", last_price: 50, prev_price: 45, change: 1.2), appData: AppData()).environmentObject(InstrumentStore())
}
