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
                    .foregroundColor(Color.primary)
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
    @Environment(\.colorScheme) var colorScheme
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
        .background(colorScheme == .dark ? Color.gray.opacity(0.25) : Color.gray.opacity(0.05))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
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
    enum Field {
        case input1, input2, input3
    }
    
    @State var price: Double = 0
    @State var qty: Double = 0
    @State var total: Double = 0
    @State private var sliderValue: Double = .zero
//    @State private var isEditing = false
//    @State private var isOn = false
    @State private var localSide: Side = Side.SELL
    @State private var selection: Int = 0
    @State private var isPostOnly: Bool = false
    @State var selectedOrderType: DropdownOption = DropdownOption(key: uniqueKey, value: OrderType.LIMIT.rawValue)
    @State private var selectedView: String = "Chart"
    @FocusState private var focusedField: Field?
    
//    @Binding var orderPad: OrderPad
    
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var orderStore: OrderStore
    @EnvironmentObject var appData: AppData
    @Environment(\.colorScheme) var colorScheme
    
   
//    @State private var keyboardHeight: CGFloat = 0
    
    static var uniqueKey: String {
        UUID().uuidString
    }
    
    static let options: [DropdownOption] = [
        DropdownOption(key: uniqueKey, value: OrderType.LIMIT.rawValue),
        DropdownOption(key: uniqueKey, value: OrderType.MARKET.rawValue),
        DropdownOption(key: uniqueKey, value: OrderType.STOP_LIMIT.rawValue)
    ]
    
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
    
    var bindingTotal: Binding<String> {
        .init(get: {
            "\(self.total)"
        }, set: {
            self.total = Double(Int($0) ?? Int(self.total))
        })
    }
    
    var body: some View {
        ScrollView{
            HStack{
                Button(action: {
                    //                    presentSideMenu.toggle()
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
//            TradeChartView()
            
            Spacer(minLength: 10)
            
            HStack{
                
                VStack(alignment: .leading) {
                    DepthView(instrument_id: appData.dataForTrade.instrumnet.instrument_id).environmentObject(orderStore)
                        .frame(maxHeight: .infinity)
                        .frame(width: 130)
                }
                .padding(10)
                .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
                
                
                
                
                VStack{
                    DropdownSelector2(
                        placeholder: "Limit",
                        options: TradeView2.options,
                        onOptionSelected: { option in
                            self.selectedOrderType = option
                        })
                    .zIndex(1.0)
                    
                    SideButtons(localSide: $localSide).environmentObject(appData)
                    
                    VStack(spacing: 20) {
                        VStack(spacing: 1){
                            VStack(alignment: .leading, spacing: 3){
                                HStack{
                                    VStack(alignment: .leading, spacing: 3){
                                        Text("Limit price")
                                            .foregroundColor(Color.secondary)
                                        TextField("Price", text: bindingPrice)
                                            .multilineTextAlignment(.leading)
                                            .keyboardType(.numberPad)
                                            .font(.system(size: 16))
                                            .focused($focusedField, equals: .input1)
                                            .onAppear(){
                                                self.price = appData.dataForTrade.instrumnet.last_price
                                            }
                                    }
                                    VStack{
                                        HStack{
                                            Button(action: {
                                            }) {
                                                HStack {
                                                    Text("Best bid")
                                                        .foregroundColor(Color.secondary)
                                                        .padding(5)
                                                        .font(.system(size: 10))
                                                }
                                                .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                                                .cornerRadius(5)
                                            }
                                            Button(action: {
                                            }) {
                                                HStack {
                                                    Text("Best ask")
                                                        .foregroundColor(Color.secondary)
                                                        .padding(5)
                                                        .font(.system(size: 10))
                                                }
                                                .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                                                .cornerRadius(5)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                                
                                
                            }
                            .padding(10)
                            .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                            .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))  // Only top corners rounded
                            .onTapGesture {
                                focusedField = .input1
                            }
                            
                            VStack(spacing: 1){
                                VStack(alignment: .leading, spacing: 3){
                                    Text("Quantity BTC")
                                        .foregroundColor(Color.secondary)
                                    TextField("Qty", text: bindingQty)
                                        .multilineTextAlignment(.leading)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 16))
                                        .focused($focusedField, equals: .input2)
                                        .onAppear(){
                                            //self.price = orderPad.instrumnet.last_price
                                        }
                                }
                                .padding(10)
                                .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
//                                .clipShape(RoundedCorner(radius: 10, corners: [.bottomLeft]))
                                .onTapGesture {
                                    focusedField = .input2
                                }
                                
                                VStack(alignment: .leading, spacing: 3){
                                    Text("Total USDT")
                                        .foregroundColor(Color.secondary)
                                    TextField("Usdt", text: bindingTotal)
                                        .multilineTextAlignment(.leading)
                                        .keyboardType(.numberPad)
                                        .font(.system(size: 16))
                                        .focused($focusedField, equals: .input3)
                                        .onAppear(){
                                            //self.price = orderPad.instrumnet.last_price
                                        }
                                }
                                .padding(10)
                                .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                                .clipShape(RoundedCorner(radius: 10, corners: [.bottomRight,.bottomLeft]))
                                .onTapGesture {
                                    focusedField = .input3
                                }
                            }
                            
                            CustomSlider(value: $sliderValue, range: 0...userStore.userBalance.cash_balance, step: 10, thumbSize: 18, trackHeight: 7)
                                    .padding([.top], 4)
                                    .onChange(of: sliderValue) {
                                        updateQuantityAndCost()
                                    }
                            
                            
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
                                        Text("Limit price(USDT)")
                                            .foregroundColor(Color.secondary)
                                    } else
                                    if focusedField == .input2 {
                                        Text("Quantity(\(appData.dataForTrade.instrumnet.code)")
                                            .foregroundColor(Color.secondary)
                                    } else {
                                        Text("Total(USDT)")
                                            .foregroundColor(Color.secondary)
                                    }
                                    Spacer()
                                    
                                    Button(action: {
                                        focusedField = nil
                                    }) {
                                        Text("Done")
                                    }
                                }
                            }
                        }
                        
                        
                        
                    }
                }
                .font(.system(size: 12, weight: .bold))
                .onTapGesture {
                    focusedField = nil
                }
            
            }
            Spacer(minLength: 20)
            VStack(spacing: 15){
               
//                HStack{
//                    Text("Post only")
//                        .foregroundColor(Color.secondary)
//                    Spacer()
//                    CustomToggle(isOn: $isPostOnly, width: 45, height: 25)
//                    
//                }
                
                HStack{
                    Text("Available")
                        .foregroundColor(Color.secondary)
                    Spacer()
                    Button(action: { print("Pressed") }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 12))
                    }
                    Text("\(userStore.userBalance.cash_balance)")
                    
                }
                HStack{
                    Text("Max. Buy")
                        .foregroundColor(Color.secondary)
                    Spacer()
                    Text("\(userStore.userBalance.cash_balance)")
                    
                }
                HStack{
                    Text("Estimate fees")
                        .foregroundColor(Color.secondary)
                    Spacer()
                    Text("12.00")
                    
                }
            }
            .font(.system(size: 12, weight: .bold))
            //                    .padding([.trailing, .leading], 10)
            
            Button(action: {
                self.submit()
            }) {
                Text("Submit")
                    .foregroundColor(Color.primary)
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(10)
            }
            .background(localSide == .BUY ? .green : .red)
            .cornerRadius(10)
            .padding([.top,.bottom], 10)
//            .padding([.trailing, .leading], 10)
            
            
            VStack{
                ScrollSlidingTabBar(selection: $selection, tabs: ["Open Orders", "Order History", "Funds"])
                TabView(selection: $selection) {
                    ScrollView{
                        VStack{
                            Divider()
                            ForEach(orderStore.orders.filter { $0.status_code == selection }, id: \.ticket_no) { order in

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
                                                self.cancel(ticket_no: order.ticket_no)
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
                    .onAppear(){
                        orderStore.loadOrders(userId: userStore.userInfo.user_id)
                    }
                    .tag(0)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.default, value: selection)
                Spacer()
            }
            .frame(height: 320)
            Spacer()
        }
        .onTapGesture {
            focusedField = nil
        }
        .onAppear(){
            orderStore.webSocketManager.connect()
        }
        .animation(.easeInOut, value: focusedField)
//        Spacer()
        
    }
    
    
    private func cancel(ticket_no: String){
        orderStore.cancelOrder(cancelTicket: CancelTicket(from: ticket_no))
    }
    
    private func submit(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Customize the format based on your requirements

        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)

        let new_order = Order.init(client_id: 0, user_id: userStore.userInfo.user_id, order_id: 0, order_type: selectedOrderType.value.uppercased(), instrument_id: appData.dataForTrade.instrumnet.instrument_id, code: appData.dataForTrade.instrumnet.code, price: price, quantity: qty, side: Side.fromRawValue(localSide.rawValue), pair: "USDT", status_text: "ack.", status_code: 0, expiry_date: dateString, created_at: dateString)
        
        orderStore.submitOrder(order: new_order)
     }
    
    private func updateQuantityAndCost() {
        let percentage = sliderValue / 100 // Convert slider value to percentage
        let availableFunds = userStore.userBalance.cash_balance * percentage // Calculate how much of the balance is available
        self.qty = availableFunds / price // Calculate how many units can be bought
        self.total = self.qty * self.price // Calculate total cost for the selected quantity
    }
}


struct TradeSideButtons: View {
    @State var side: Side
    @Binding var localSide: Side
    var body: some View {
        HStack(spacing: 5) {
            Button(action: {
                localSide = .SELL
            }) {
                Spacer()
                Text("SELL")
                    .font(.headline)
                    .padding(5)
                Spacer()
            }
            .background(localSide == .SELL ? .red : .gray)
            .cornerRadius(5)

            Button(action: {
                localSide = .BUY
            }) {
                Spacer()
                Text("BUY")
                    .font(.headline)
                    .padding(5)
                Spacer()
            }
            .background(localSide == .BUY ? .green : .gray)
            .cornerRadius(5)
        }
    }
}

struct SideButtons: View {
    @Binding var localSide: Side
    private let toggleHeight: CGFloat = 35
    @EnvironmentObject var appData: AppData
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geometry in
            let totalWidth = geometry.size.width
            let halfWidth = totalWidth / 2

            ZStack {
                Rectangle()
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                    .frame(width: totalWidth, height: toggleHeight)
                    .cornerRadius(10)

                ZStack {
                    Rectangle()
                        .fill(localSide == .BUY ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                        .frame(width: halfWidth, height: toggleHeight)
                        .cornerRadius(10)
                        .offset(x: localSide == .BUY ? -halfWidth / 2 : halfWidth / 2)
                        .animation(.easeOut(duration: 0.2), value: localSide)

                    HStack(spacing: 0) {
                        Text("BUY")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(localSide == .BUY ? Color.white : Color.green)
                            .font(.system(size: 12, weight: .bold))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                localSide = .BUY
                            }

                        Text("SELL")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(localSide == .SELL ? Color.white : Color.red)
                            .font(.system(size: 12, weight: .bold))
                            .contentShape(Rectangle())
                            .onTapGesture {
                                localSide = .SELL
                            }
                    }
                }
            }
        }
        .frame(height: toggleHeight)
        .onAppear {
            self.localSide = appData.dataForTrade.side
        }
        .onTapGesture {
            if localSide == .BUY {
                localSide = .SELL
            } else {
                localSide = .BUY
            }
        }
    }
}

struct BuyView: View {
    @State private var sliderValue: Double = 0 // Slider controlling the percentage (0 to 100)
    @State private var price: Double = 50.0 // Price of one unit
    @State private var userBalance: Double = 13.55 // User's available balance
    @State private var quantity: Double = 0 // Quantity the user can buy based on slider
    @State private var totalCost: Double = 0 // Total cost for the selected quantity
    
    var body: some View {
        VStack(spacing: 20) {
            // Display the price
            Text("Price: $\(price, specifier: "%.2f")")
                .font(.headline)
            
            // Display the slider to select percentage (25%, 50%, 75%, 100%)
            CustomSlider(value: $sliderValue, range: 0...100, step: 25, thumbSize: 18, trackHeight: 7)
                .onChange(of: sliderValue) {
                    updateQuantityAndCost()
                }
            
            // Display the percentage selected
            Text("Selected: \(Int(sliderValue))% of your balance")
            
            // Display the quantity user can buy
            Text("Quantity: \(quantity, specifier: "%.4f")")
            
            // Display the total cost based on quantity
            Text("Total Cost: $\(totalCost, specifier: "%.2f")")
            
            // Check if user has enough balance to buy
            if totalCost > userBalance {
                Text("Insufficient balance")
                    .foregroundColor(.red)
            } else {
                Text("You can buy \(Int(quantity)) items for $\(totalCost, specifier: "%.2f")")
            }
        }
        .padding()
    }
    
    // Function to update quantity and cost based on the selected percentage
    private func updateQuantityAndCost() {
        let percentage = sliderValue / 100 // Convert slider value to percentage
        let availableFunds = userBalance * percentage // Calculate how much of the balance is available
        quantity = availableFunds / price // Calculate how many units can be bought
        totalCost = quantity * price // Calculate total cost for the selected quantity
    }
}



struct test: View {
    @State private var localSide: Side = Side.SELL
    var body: some View {
        HStack(spacing: 5) {
//            TradeChartView()
            
            
            SideButtons(localSide: $localSide).environmentObject(AppData())
        }
    }
}



#Preview {
//    BuyView()
//    test()
    TradeView().environmentObject(UserStore()).environmentObject(OrderStore()).environmentObject(AppData())
}

