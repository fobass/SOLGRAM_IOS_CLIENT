//
//  HomeView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 9/6/24.
//

import SwiftUI

struct HomeView: View {
    @State var selection: Int = 0
    @State var currentTab: Int = 0
    @State private var showDetailView = false
    @StateObject private var webSocketManager = WebSocketManager()
    @EnvironmentObject var orderStore: OrderStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var instrumentStore: InstrumentStore
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
//    @State private var searchText = ""
    var body: some View {
        NavigationView{
            TabView(selection: $selection) {
                ScrollView {
                    VStack{
                        HStack{
                            Image(systemName: "person.circle")
                                .font(Font.system(size: 28))
                            Text("Hello, \(userStore.userInfo.username)")
                                .accentColor(Color.black.opacity(0.7))
                                .font(.custom("TrebuchetMS-Bold", size: 16))
                            Spacer()
                            Image(systemName: "bell.circle")
                                .font(Font.system(size: 24))
                            Button(action: {
                                self.userStore.logout()
                            }, label: {
                                Text("logout")
//                                            .frame(width: 270)
                                    .foregroundColor(.blue)
                                    .font(.custom("TrebuchetMS-Bold", fixedSize: 18))
                            })
                        }
                        .padding([.top, .bottom], 15)
                        
                        QuoteView(selection: $selection).environmentObject(appData).environmentObject(instrumentStore)
                            
                    }
                    .padding([.trailing, .leading], 15)
                }
                .scrollIndicators(.never)
                .tabItem {
                    Label("Market", systemImage: "bitcoinsign.circle")
                }.tag(0)
                
                VStack {
                    TradeView2().environmentObject(appData).environmentObject(orderStore).environmentObject(userStore)
                        .padding([.trailing, .leading], 15)
                        .onReceive(orderStore.webSocketManager.receivedMessagePublisher) { message in
                            self.orderStore.updateStore(with: message)
                        }
                }
                .scrollIndicators(.never)
                .tabItem {
                    Label("Trade", systemImage: "chart.line.uptrend.xyaxis")
                }
//                        .badge(7)
                .tag(1)
                
                ScrollView{
                    PortfolioView().environmentObject(instrumentStore)
                        .padding([.trailing, .leading], 10)
                }
                .scrollIndicators(.never)
                .tabItem {
                    Label("Portfolio", systemImage: "bag.circle")
                }
                .tag(2)
                
                ScrollView{
                    TradeView().environmentObject(appData).environmentObject(orderStore).environmentObject(userStore)
                        .padding([.trailing, .leading], 15)
                        .onReceive(orderStore.webSocketManager.receivedMessagePublisher) { message in
                            self.orderStore.updateStore(with: message)
                        }
                }
                .scrollIndicators(.never)
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }.tag(3)
            }
            
            .onAppear {
                let appearance = UITabBarAppearance()
                appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
                appearance.backgroundColor = UIColor(Color.orange.opacity(0.1))
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
                
            }
            .onAppear {
                webSocketManager.connect()
                userStore.getUserBalance(with: userStore.userInfo.user_id)
            }
            .onDisappear {
                webSocketManager.close()
            }
        }
        
    }
}

#Preview {
    HomeView().environmentObject(AppData()).environmentObject(UserStore()).environmentObject(OrderStore()).environmentObject(InstrumentStore())
}



struct KeyboardView: View {
    @State private var input1: String = ""
    @State private var input2: String = ""
    @State private var input3: String = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case input1, input2, input3
    }

    var body: some View {
        VStack(spacing: 20) {
            TextField("Input 1", text: $input1)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .input1)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Input 2", text: $input2)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .input2)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("Input 3", text: $input3)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .input3)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Button(action: {
                        if focusedField == .input2 {
                            focusedField = .input1
                        } else
                        if focusedField == .input3 {
                            focusedField = .input2
                        }
                    }) {
                        Image(systemName: "chevron.up")
                    }
                    .disabled(focusedField != .input3 && focusedField != .input2)

                    Button(action: {
                        if focusedField == .input1 {
                            focusedField = .input2
                        } else
                        if focusedField == .input2 {
                            focusedField = .input3
                        } else {
                            focusedField = .input1
                        }
                    }) {
                        Image(systemName: "chevron.down")
                    }
                    .disabled(focusedField == .input3)

                    Spacer()
                    if focusedField == .input1 {
                        Text("Limit")
                    } else
                    if focusedField == .input2 {
                        Text("Qty")
                    } else {
                        Text("Total")
                    }
                    Spacer()
                    
                    Button(action: {
                        focusedField = nil
                    }) {
                        Text("Done")
                    }
                }
                .padding(0)
            }
        }
        .padding()
    }
}
