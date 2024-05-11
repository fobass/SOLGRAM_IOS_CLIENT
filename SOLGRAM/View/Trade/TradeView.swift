//
//  SwiftUIView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import SwiftUI
import InputStepper
import Foundation
import Combine

struct DropdownOption: Hashable {
    let key: String
    let value: String
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }
}

struct DropdownRow: View {
    var option: DropdownOption
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        Button(action: {
            if let onOptionSelected = self.onOptionSelected {
                onOptionSelected(self.option)
            }
        }) {
            HStack {
                Text(self.option.value)
                    .font(.system(size: 14))
                    .foregroundColor(Color.black)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

struct Dropdown: View {
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.options, id: \.self) { option in
                    DropdownRow(option: option, onOptionSelected: self.onOptionSelected)
                }
            }
        }
        .frame(minHeight: CGFloat(options.count) * 30, maxHeight: 250)
        .padding(.vertical, 5)
        .background(Color.white)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct DropdownSelector: View {
    @State private var shouldShowDropdown = false
    @State private var selectedOption: DropdownOption? = nil
    var placeholder: String
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    private let buttonHeight: CGFloat = 25

    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            HStack {
                Text(selectedOption == nil ? placeholder : selectedOption!.value)
                    .font(.system(size: 14))
                    .foregroundColor(selectedOption == nil ? Color.gray: Color.black)

                Spacer()

                Image(systemName: self.shouldShowDropdown ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 9, height: 5)
                    .font(Font.system(size: 9, weight: .medium))
                    .foregroundColor(Color.black)
            }
        }
        .padding(.horizontal, 10)
        .cornerRadius(5)
        .frame(width: .infinity, height: self.buttonHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.gray, lineWidth: 1)
        )
        .overlay(
            VStack {
                if self.shouldShowDropdown {
                    Spacer(minLength: buttonHeight + 5)
                    Dropdown(options: self.options, onOptionSelected: { option in
                        shouldShowDropdown = false
                        selectedOption = option
                        self.onOptionSelected?(option)
                    })
                }
            }, alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: 5).fill(Color.white)
        )
    }
}

struct SideMenu: View {
    @Binding var isShowing: Bool
    var content: AnyView
    var edgeTransition: AnyTransition = .move(edge: .leading)
    var body: some View {
        ZStack(alignment: .bottom) {
            if (isShowing) {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                content
                    .transition(edgeTransition)
                    .background(
                        Color.clear
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}

struct TradeView: View {
    static var uniqueKey: String {
        UUID().uuidString
    }

    static let options: [DropdownOption] = [
        DropdownOption(key: uniqueKey, value: OrderType.LIMIT.rawValue),
        DropdownOption(key: uniqueKey, value: OrderType.MARKET.rawValue),
        DropdownOption(key: uniqueKey, value: OrderType.STOP_LIMIT.rawValue)
    ]
    @ObservedObject var appData: AppData
    @State var price: Double = 0
    @State var qty: Double = 0
    @State var balance: Double = 0
    static let formatter = NumberFormatter()
    
    @State var selectedOrderType: DropdownOption = DropdownOption(key: uniqueKey, value: OrderType.LIMIT.rawValue)
    var bindingPrice: Binding<String> {
        .init(get: {
            "\(self.price)"
        }, set: {
            self.price = Double(Int($0) ?? Int(self.price))
        })
    }
    
    var bindingQty: Binding<String> {
        .init(get: {
            "\(self.qty)"
        }, set: {
            self.qty = Double(Int($0) ?? Int(self.qty))
        })
    }
    
    var bindingBalance: Binding<String> {
        .init(get: {
            "\(self.balance)"
        }, set: {
            self.balance = Double(Int($0) ?? Int(self.balance))
        })
    }
    
//    @StateObject private var webSocketManager = TradeSocketManager()

    @ObservedObject var store: OrderStore
    @State var value:Float = 0
    @State private var selection: Int = 0
    @State var tabSelectedValue = 0
    @Binding var presentSideMenu: Bool
    
    var body: some View {
        VStack{
            VStack {
                Picker("", selection: $tabSelectedValue) {
                    Text("Spot")
                        .tag(0)
                    Text("Margin")
                        .tag(1)
                    Text("Fiat")
                        .tag(2)
                    Text("P2P")
                        .tag(3)
                }
                .frame(height: 30)
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden() // Hide labels
                .scaleEffect(0.9)
                
                
                HStack{
                    Button(action: {
                        presentSideMenu.toggle()
                    }) {
                        Image(systemName: "arrowshape.left.arrowshape.right")
                            .imageScale(.large)
                    }
                    
                    Text("\(appData.dataForTrade.instrumnet.code)")
                        .foregroundColor(.green)
                        .font(Font.system(size: 22))
                    Text("\(appData.dataForTrade.instrumnet.change)")
                        .foregroundColor(.green)
                        .font(Font.system(size: 14))
                    Spacer()
                    Button(action: {
                        print("Pressed")
                    }) {
                        Image(systemName: "chart.xyaxis.line")
                    }
                    
                }
                TabView(selection: $tabSelectedValue) {
                    
                    HStack(spacing: 10) {
                        
                        DepthView(store: store, instrument_id: appData.dataForTrade.instrumnet.instrument_id)
                            .font(Font.system(size: 10))
                            .frame(width: 170)
                        VStack{
                            HStack(spacing: 5){
                                Button(action: {
                                    print("Pressed")
                                    appData.dataForTrade.side = Side.SELL
                                }) {
                                    Spacer()
                                    Text("SELL")
                                        .font(.headline)
                                        .padding(5)
                                    Spacer()
                                }
                                .background(appData.dataForTrade.side == Side.SELL ? .red : .gray)
                                .cornerRadius(5)
                                
                                Button(action: {
                                    appData.dataForTrade.side = Side.BUY
                                }) {
                                    Spacer()
                                    Text("BUY")
                                        .font(.headline)
                                        .padding(5)
                                    Spacer()
                                }
                                .background(appData.dataForTrade.side == Side.BUY ? .green : .gray)
                                .cornerRadius(5)
                            }
                            
                            DropdownSelector(
                                placeholder: "Limit",
                                options: TradeView.options,
                                onOptionSelected: { option in
                                    self.selectedOrderType = option
                                })
                            .zIndex(1.0)
                            
                            HStack {
                                Button(action: {
                                    self.price -= 1
                                }) {
                                    Spacer()
                                    Image(systemName: "minus")
                                    Spacer()
                                }
                                .frame(width: 28, height: 28)
                                .background(.orange.opacity(0.5))
                                TextField("Price", text: bindingPrice)
                                    .multilineTextAlignment(.center)
                                    .onAppear(){
                                        self.price = appData.dataForTrade.instrumnet.last_price
                                    }
                                Button(action: {
                                    self.price += 1
                                }) {
                                    Spacer()
                                    Image(systemName: "plus")
                                    Spacer()
                                }
                                .frame(width: 28, height: 28)
                                .background(.orange.opacity(0.5))
                            }
                            .background(.white)
                            .cornerRadius(5)
                            
                            HStack {
                                Button(action: {
                                    self.qty -= 1
                                }) {
                                    Spacer()
                                    Image(systemName: "minus")
                                    Spacer()
                                }
                                .frame(width: 28, height: 28)
                                .background(.orange.opacity(0.5))
                                TextField("Qty", text: bindingQty, prompt: Text("Required"))
                                    .multilineTextAlignment(.center)
                                Button(action: {
                                    self.qty += 1
                                }) {
                                    Spacer()
                                    Image(systemName: "plus")
                                    Spacer()
                                }
                                .frame(width: 28, height: 28)
                                .background(.orange.opacity(0.5))
                            }
                            .background(.white)
                            .cornerRadius(5)
                            
                            HStack{
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(height: 15)
                                //                            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(height: 15)
                                //                            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(height: 15)
                                //                            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(height: 15)
                                //                            .overlay(Rectangle().stroke(Color.black, lineWidth: 1))
                            }
                            
                            
                            HStack {
                                TextField("Price", text: bindingBalance, prompt: Text("Required"))
                                    .multilineTextAlignment(.center)
                                    .frame(height: 28)
                                
                            }
                            .background(.white)
                            .border(Color.black, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                            .cornerRadius(5)
                            
                            
                            HStack{
                                Text("Available")
                                    .font(Font.system(size: 11))
                                Spacer()
                                Text("550 USDT")
                                    .font(Font.system(size: 11))
                                Button(action: { print("Pressed") }) {
                                    Image(systemName: "plus.circle")
                                }
                                //                        .background(.green)
                                //                        .cornerRadius(5)
                                .font(Font.system(size: 14))
                            }
                            
                            Button(action: {
                                submit()
                            }) {
                                Spacer()
                                Text("\(appData.dataForTrade.side.rawValue)")
                                    .font(.headline)
                                    .padding(10)
                                Spacer()
                            }
                            .background(appData.dataForTrade.side == Side.BUY ? .green : .red)
                            .cornerRadius(5)
                            .onAppear(){
                                store.webSocketManager.connect()
                               
                            }
                            Spacer()
                        }
                        
                        
                    }.tag(0)
                    
                    Text("Content for second tab")
                        .tag(1)
                    
                    
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 270)
                
                
                
                
                VStack{
                    ScrollSlidingTabBar(selection: $selection, tabs: ["Open Orders", "Order History", "Funds"])
                    TabView(selection: $selection) {
                        ScrollView{
                            VStack{
                                Divider()
                                ForEach($store.orders, id: \.ticket_no) { $order in
                                    
                                    HStack{
                                        
                                        VStack{
                                            HStack{
                                                VStack(alignment: .center){
                                                    //                                                Text("\(order.order_type)\\\\\(order.side)")
                                                    Image(systemName: "29.circle")
                                                        .resizable()
                                                        .frame(width: 22, height: 22)
                                                }
                                                .foregroundColor(order.isBuy ? .green : .red)
                                            }
                                            .font(.system(size: 11))
                                            .frame(width: 30)
                                        }
                                        
                                        VStack{
                                            HStack{
                                                VStack(alignment: .leading){
                                                    Text("\(order.code)\\\\\(order.pair)")
                                                        .bold()
                                                    Text("Amount")
                                                    Text("Price")
                                                    Text("\(order.status_text)")
                                                }
                                                Spacer()
                                            }
                                        }
                                        VStack{
                                            HStack{
                                                VStack(alignment: .leading){
                                                    Text("\(order.orderTypeCaption)")
                                                        .foregroundColor(order.isBuy ? .green : .red)
                                                    Text("\(order.quantity)")
                                                    Text("$\(order.price)")
                                                }
                                                Spacer()
                                            }
                                        }
                                        
                                        HStack{
                                            Spacer()
                                            VStack(alignment: .trailing){
                                                Text("\(order.expiry_date)")
                                                    .font(.system(size: 9))
                                                Button(action: {
                                                    self.qty -= 1
                                                }) {
                                                    Text("Cancel")
                                                }
                                                .frame(width: 62, height: 28)
                                                .background(.orange.opacity(0.5))
                                            }
                                        }
                                    }
                                    .font(.system(size: 12))
                                    Divider()
                                }
                                Spacer()
                            }
                        }
                        .tag(0)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.default, value: selection)
                }
                .frame(height: 320)
            }
            
      
            
        }
       
        

    }
    
   
    
    func submit(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Customize the format based on your requirements

        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)
        
        let orderTicket = OrderTicket(order_type: selectedOrderType.value.uppercased(), instrument_id: appData.dataForTrade.instrumnet.instrument_id, code: appData.dataForTrade.instrumnet.code, price: price, quantity: qty, side: appData.dataForTrade.side.rawValue.uppercased(), status_text: "ack.", status_code: 0, expiry_date: dateString, pair: "USDT")
        let order = Order(from: orderTicket)
        
        store.updateOrderById(order)
        
        let orderTicketPayload = OrderTicketPayload(_type: .NewOrder, payload: orderTicket)
        
        store.submitOrder(orderTicket: orderTicketPayload)
        
//        store.subscribeDepth(depth: MarketDepthPayload(_type: .MarketDepth, payload: appData.dataForTrade.instrumnet.instrument_id))
    }
}



#Preview {
    TradeView(appData: AppData(), store: OrderStore(), presentSideMenu: .constant(true))
}

