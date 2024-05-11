//
//  ContentView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/23/24.
//

import SwiftUI
import Charts

//let webSocketManager = WebSocketManager()

// Connect to the WebSocket server
class AppData: ObservableObject {
    @Published var dataForTrade: OrderPad
    init() {
        self.dataForTrade = .init(side: Side.BUY, instrumnet: Instrument.init(instrument_id: 495, code: "STON", symbol: "", last_price: 0, prev_price: 0, change: 0))
    }
}

struct ContentView: View {
    @State var selection: Int = 0
    @State var currentTab: Int = 0
    @State private var showDetailView = false
    @StateObject private var webSocketManager = WebSocketManager()
    @ObservedObject var instrumentStore = InstrumentStore()
    @ObservedObject var tradeStore = OrderStore()
    @ObservedObject var appData = AppData()
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    var body: some View {
        ZStack{
            NavigationView{
                    TabView(selection: $selection) {
                        ScrollView {
                            VStack{
                                HeaderView()
                                Divider()
                                NewsTickerView()
                                Divider()
                                HStack{
                                    CardView()
                                    CardView()
                                    CardView()
                                }
                                HStack {
                                    Image("_card")
                                        .resizable()
                                        .frame(height: 200)
                                        .padding(1)
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5).stroke(Color.orange.opacity(0.7), lineWidth: 2)
                                )
                                //                        Divider()
                                LazyHStack(spacing: 15, content: {
                                    Image(systemName: "rotate.3d.circle")
                                    Spacer()
                                    Image(systemName: "cpu")
                                    Spacer()
                                    Image(systemName: "server.rack")
                                    Spacer()
                                    Image(systemName: "creditcard.circle")
                                    Spacer()
                                    Image(systemName: "command.square")
                                })
                                .font(Font.system(size: 32))
                                Divider()
                                
                                
                                QuoteTabsView(selectTradeTab: $selection, appData: appData).environmentObject(instrumentStore)
                                    .frame(width: 380, height: 600, alignment: .center)
                            }
                            .padding([.trailing, .leading], 10)
                        }
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }.tag(0)
                        ScrollView {
                            TradeView(appData: appData, store: tradeStore, presentSideMenu: $presentSideMenu)
                                .padding([.trailing, .leading], 10)
                                .onReceive(tradeStore.webSocketManager.receivedMessagePublisher) { message in
                                    self.tradeStore.updateStore(with: message)
                                }
                        }
                        .tabItem {
                            Label("Trade", systemImage: "bag.circle")
                        }
                        .badge(7)
                        .tag(1)
                        
                        Text("Future")
                            .tabItem {
                                Label("Future", systemImage: "shuffle.circle")
                            }
                            .tag(2)
                        
                        Text("Wallet")
                            .tabItem {
                                Label("Wallet", systemImage: "wallet.pass")
                            }
                            .tag(3)
                        
                    }
                    .onAppear {
                        let appearance = UITabBarAppearance()
                        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                        appearance.backgroundColor = UIColor(Color.orange.opacity(0.1))
                        UITabBar.appearance().standardAppearance = appearance
                        UITabBar.appearance().scrollEdgeAppearance = appearance
                        self.instrumentStore.fetch()
                    }
                    .onReceive(webSocketManager.receivedMessagePublisher) { message in
                        self.instrumentStore.updateStore(with: message)
                    }
                    .onAppear {
                        webSocketManager.connect()
                    }
                    .onDisappear {
                        webSocketManager.close()
                    }
            }
            
            SideMenu(isShowing: $presentSideMenu, content: AnyView(SideMenuView(selectedSideMenuTab: $selectedSideMenuTab, presentSideMenu: $presentSideMenu).environmentObject(instrumentStore)))
        }
        
    }
}

struct HeaderView: View {
    @State var searachVal: String = ""
    var body: some View {
        HStack{
            Image(systemName: "person.circle")
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(Font.system(size: 16))
                        .padding(3)
                    TextField("Search", text: $searachVal)
                        .font(Font.system(size: 16))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.7), lineWidth: 1)
                )
            }
//            .padding([.trailing,.leading], 0)
//            .padding([.bottom, .top], 5)
            
            
            Image(systemName: "person.fill.questionmark")
            Image(systemName: "bell.badge.circle")
        }
        .font(Font.system(size: 26))
//        .padding([.trailing,.leading], 0)
//        .padding([.bottom], 5)
    }
}



//#Preview {
//   ContentView()
//}
