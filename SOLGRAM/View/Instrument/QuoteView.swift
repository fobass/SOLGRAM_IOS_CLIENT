//
//  QuoteView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/23/24.
//

import SwiftUI

struct QuoteView: View {
    @Binding var selectTradeTab: Int
    @EnvironmentObject var instrumentStore: InstrumentStore
    @State private var numberOfItemsToShow = 5
    let rows = [GridItem(.adaptive(minimum: 10, maximum: 100))]
    @ObservedObject var appData: AppData
    var body: some View {
        VStack {
            LazyVStack(alignment: .leading) {
                HStack {
                        Text("Code")
                            .padding([.leading], 10)
                        Spacer()
                        Text("Price(USDT)")
                            .padding([.trailing], 20)
                        Text("24h Change")
                            .frame(width: 80)
                    }
                    .font(Font.system(size: 9))
                    .padding(.vertical, 5)
                ForEach($instrumentStore.items, id: \.id) { $item in
                    NavigationLink(destination: QuoteDetailView(selectTradeTab: $selectTradeTab, instrument: item, appData: appData).environmentObject(instrumentStore)) {
                        HStack{
                            HStack{
                                Image(systemName: "person.circle")
                                    .font(Font.system(size: 18))
                                Text(item.code)
                                    .font(.callout)
//                                    .foregroundColor(.blue)
                            }
                            .padding([.leading], 10)
                            .font(Font.system(size: 12))
                                
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(item.last_price)")
                                    .font(.subheadline)
                                    .foregroundColor(item.last_price > item.prev_price ? Color.green : Color.red)
                                Text("$\(item.last_price)")
                                    .font(Font.system(size: 9))
                            }
                            VStack {
                                Text(String(format: "%.2f%%", item.change))
                                    .padding(5)
                            }
                            .frame(width: 90)
                            .background(item.last_price > item.prev_price ? Color.green : Color.red)
                            .cornerRadius(5)
                            .padding([.leading, .trailing], 5)
                            .font(Font.system(size: 13))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                }
                HStack{
                    Spacer()
                    if numberOfItemsToShow < instrumentStore.items.count {
                        Button("Show More") {
                            withAnimation {
                                numberOfItemsToShow += 5
                            }
                        }
                        .foregroundColor(.blue)
                        .padding(.vertical, 10)
//                        .background(.red)
                    }
                    Spacer()
                }
            }
//            .onAppear(){
//                if (store.items.count == 0) {
//                    store.fetch()
//                }
//            }
            Spacer()
        }
        .padding(.top, 5)
//        Spacer()
    }
}

#Preview {
    QuoteView(selectTradeTab: .constant(0), appData: AppData()).environmentObject(InstrumentStore())
}


//struct QuoteDetailView: View {
//    @ObservedObject var store: InstrumentStore
//    @State private var selection: Int = 0
//    var instrument: Instrument
//    var body: some View {
//        NavigationView {
//            VStack(alignment: .leading) {
//                TabView(selection: $selection) {
//                    VStack{
//                        ChartView()
//                            .frame(width: 380, height: 400, alignment: .top)
//                        MarketDepthView()
//                    }
//                    .tag(0)
//                    
//                    HStack {
//                        QuoteView()
//                    }
//                    .tag(1)
//                }
//                .tabViewStyle(.page(indexDisplayMode: .never))
//                .animation(.default, value: selection)
//            }
//            
//            .toolbar {
//                ToolbarItem(placement: .bottomBar) {
//                    HStack{
//                        // SELL
//                        Button(action: { print("Pressed") }) {
//                           Image(systemName: "shuffle.circle")
//                        }
//                        .background(.gray.opacity(0.3))
//                        .cornerRadius(5)
//                        // BUY
//                        Button(action: { print("Pressed") }) {
//                            Image(systemName: "wallet.pass")
//                        }
//                        .background(.gray.opacity(0.3))
//                        .cornerRadius(5)
//                    }
//                }
//            }
//
//        }
//        .navigationTitle("\(instrument.code)")
//        .navigationBarItems(trailing:
//                Button(action: {
//                    print("Navigation bar item action")
//                }) {
//                    Image(systemName: "bell.circle.fill")
//                        .font(Font.system(.title))
//                }
//            )
//    }
//}
//
//
//
//struct QuoteView: View {
//    @ObservedObject var store = InstrumentStore()
//    let rows = [GridItem(.adaptive(minimum: 10, maximum: 100))]
//    var body: some View {
//        VStack {
//            ForEach($store.items, id: \.id) { $item in
//                NavigationLink(destination: QuoteDetailView(store: store, instrument: item)) {
//                    HStack{
//                        VStack(alignment: .trailing) {
//                            Text("\(item.last_price)")
//                                .font(.subheadline)
//                                .foregroundColor(item.last_price > item.prev_price ? Color.green : Color.red)
//                            Text("$\(item.last_price)")
//                                .font(Font.system(size: 9))
//                        }
//                    }
//                }
//                .buttonStyle(PlainButtonStyle())
//                
//            }
//        }
//    }
//}
//
//
//struct ContentView: View {
//    @State var selection: Int = 0
//    var body: some View {
//        NavigationView{
//            TabView(selection: $selection) {
//                QuoteView()
//                    .tabItem {
//                        Label("Home", systemImage: "house")
//                    }.tag(0)
//
//                Text("Future")
//                    .tabItem {
//                        Label("Future", systemImage: "shuffle.circle")
//                    }
//                    .tag(2)
//                
//                Text("Wallet")
//                    .tabItem {
//                        Label("Wallet", systemImage: "wallet.pass")
//                    }
//                    .tag(3)
//                
//            }
//        }
//        
//                  
//    }
//}
