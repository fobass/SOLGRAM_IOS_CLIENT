//
//  TradeView2.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 9/28/24.
//

import SwiftUI
import Combine

struct SideToggleButtons: View {
//    @State var side: Side
    @Binding var localSide: Side
    private let toggleHeight: CGFloat = 35
    @EnvironmentObject var appData: AppData
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                .frame(width: 140, height: toggleHeight)
                .cornerRadius(10)

            HStack {
                ZStack {
                    Rectangle()
                        .fill(localSide == .BUY ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                        .frame(width: 70, height: toggleHeight)
                        .cornerRadius(10)
                        .offset(x: localSide == .BUY ? 0 : 70)
                        .animation(.easeOut(duration: 0.2), value: localSide.stringValue)
                        .onTapGesture {
                            if localSide == .BUY {
                                localSide = .BUY
                            } else {
                                localSide = .SELL
                            }
                        }
                    Text("BUY")
                        .foregroundColor(localSide == .BUY ? Color.white : Color.green)
                        .font(.system(size: 12, weight: .bold))
                }
                
                ZStack {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 60, height: toggleHeight)
                        .cornerRadius(10)
                    Text("SELL")
                        .foregroundColor(localSide == .BUY ? Color.red : Color.white)
                        .font(.system(size: 12, weight: .bold))
                }
            }
            .onAppear(){
                self.localSide = appData.dataForTrade.side
            }
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

struct DropdownSelector2: View {
    @State private var shouldShowDropdown = false
    @State private var selectedOption: DropdownOption? = nil
    var placeholder: String = "Limit "
    var options: [DropdownOption]
    var onOptionSelected: ((_ option: DropdownOption) -> Void)?
    private let buttonHeight: CGFloat = 35
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: {
            self.shouldShowDropdown.toggle()
        }) {
            HStack {
                Text(selectedOption == nil ? placeholder : selectedOption!.value)
                    .foregroundColor(selectedOption == nil ? Color.gray: Color.primary)
                    .font(.system(size: 12, weight: .bold))
                Spacer()

                Image(systemName: self.shouldShowDropdown ? "arrowtriangle.up.fill" : "arrowtriangle.down.fill")
                    .resizable()
                    .frame(width: 9, height: 5)
                    .font(Font.system(size: 9, weight: .medium))
                    .foregroundColor(Color.gray)
            }
            
        }
        .padding(.horizontal, 10)
        .frame(width: .infinity, height: self.buttonHeight)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 0)
        )
        
        .cornerRadius(10)
        .overlay(
            VStack {
                if self.shouldShowDropdown {
                    Spacer(minLength: buttonHeight + 3)
                    Dropdown(options: self.options, onOptionSelected: { option in
                        shouldShowDropdown = false
                        selectedOption = option
                        self.onOptionSelected?(option)
                    })
                    .cornerRadius(10)
                }
            }, alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: 10).fill(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 10
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

struct TradeView2: View {
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
            TradeChartView()
            
            Spacer(minLength: 10)
  
            VStack{
                HStack{
                    HStack {
                        DropdownSelector2(
                            placeholder: "Spot",
                            options: TradeView2.options,
                            onOptionSelected: { option in
                                //                        self.selectedOrderType = option
                            })
                        .zIndex(1.0)
                        .frame(width: 90)
                        Spacer()
                        DropdownSelector2(
                            placeholder: "Limit",
                            options: TradeView2.options,
                            onOptionSelected: { option in
                                self.selectedOrderType = option
                            })
                        .zIndex(1.0)
                    }
                    SideButtons(localSide: $localSide).environmentObject(appData)
                }
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
                                
                                Button(action: {
                                }) {
                                    HStack {
                                        Text("Best bid")
                                            .foregroundColor(Color.secondary)
                                            .padding(7)
                                    }
                                    .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                                    .cornerRadius(5)
                                }
                                Button(action: {
                                }) {
                                    HStack {
                                        Text("Best ask")
                                            .foregroundColor(Color.secondary)
                                            .padding(7)
                                    }
                                    .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                                    .cornerRadius(5)
                                }
                            }
                            
                            
                        }
                        .padding(10)
                        .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
                        .clipShape(RoundedCorner(radius: 10, corners: [.topLeft, .topRight]))  // Only top corners rounded
                        .onTapGesture {
                            focusedField = .input1
                        }
                        
                        HStack(spacing: 1){
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
                            .clipShape(RoundedCorner(radius: 10, corners: [.bottomLeft]))
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
                            .clipShape(RoundedCorner(radius: 10, corners: [.bottomRight]))
                            .onTapGesture {
                                focusedField = .input3
                            }
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
                    
//                    .padding(.bottom, keyboardHeight)
                    
                    VStack(spacing: 15){
                        CustomSlider(value: $sliderValue, range: 0...100, step: 10, thumbSize: 18, trackHeight: 7)
                            .onChange(of: sliderValue) { newValue in
                                print(newValue)  // This will print the new slider value whenever it changes
                            }
//                            .padding([.trailing, .leading], 2)
                        Text("\(sliderValue, specifier: "%.0f")%")
//                            .foregroundColor(isEditing ? .red : .blue)
                        
//                        HStack{
//                            Text("TP/SL")
//                                .foregroundColor(Color.secondary)
//                            Spacer()
//                            
//                            Text("-")
//                            
//                        }
//                        HStack{
//                            Text("Post only")
//                                .foregroundColor(Color.secondary)
//                            Spacer()
//                            CustomToggle(isOn: $isPostOnly, width: 45, height: 25)
//                            
//                        }
                        
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
//                    .padding([.trailing, .leading], 10)
                }
            }
            .font(.system(size: 12, weight: .bold))
            .onTapGesture {
                focusedField = nil
            }
            
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
    
    
    func cancel(ticket_no: String){
        orderStore.cancelOrder(cancelTicket: CancelTicket(from: ticket_no))
    }
    
    func submit(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Customize the format based on your requirements

        let currentDate = Date()
        let dateString = dateFormatter.string(from: currentDate)

        let new_order = Order.init(client_id: 0, user_id: userStore.userInfo.user_id, order_id: 0, order_type: selectedOrderType.value.uppercased(), instrument_id: appData.dataForTrade.instrumnet.instrument_id, code: appData.dataForTrade.instrumnet.code, price: price, quantity: qty, side: Side.fromRawValue(localSide.rawValue), pair: "USDT", status_text: "ack.", status_code: 0, expiry_date: dateString, created_at: dateString)
        
        orderStore.submitOrder(order: new_order)
     }
}


struct CustomToggle: View {
    @Binding var isOn: Bool
    var width: CGFloat = 50
    var height: CGFloat = 25

    var body: some View {
        Button(action: {
            withAnimation {
                isOn.toggle()
            }
        }) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: width, height: height)

                Circle()
                    .fill(Color.white)
                    .frame(width: height - 4, height: height - 4)
                    .shadow(radius: 1)
                    .padding(2)
            }
        }
    }
}


struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var thumbSize: CGFloat
    var trackHeight: CGFloat

    let percentagePoints: [Double] = [0, 25, 50, 75, 100] // Snap points for 0%, 25%, 50%, 75%, 100%

    var body: some View {
        GeometryReader { geometry in
            let sliderWidth = geometry.size.width - thumbSize

            ZStack(alignment: .leading) {
                // Track background
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trackHeight)
                    .cornerRadius(10)

                // Active track (the portion up to the slider thumb)
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * sliderWidth, height: trackHeight)
                    .clipShape(RoundedCorner(radius: 10, corners: [.bottomLeft, .topLeft]))

                // Percentage markers (0%, 25%, 50%, 75%, 100%)
                ForEach(percentagePoints, id: \.self) { percent in
                    let markerPosition = CGFloat(percent / 100) * sliderWidth
                    
                    // Visual marker (e.g., small circles or lines)
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 5, height: 5)
                        .offset(x: markerPosition)
                }

                // Thumb
                Circle()
                    .fill(Color.white)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay(
                        Circle().stroke(Color.blue, lineWidth: 2)
                    )
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * sliderWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { gestureValue in
                                let rawValue = min(max(0, gestureValue.location.x / sliderWidth), 1) * (range.upperBound - range.lowerBound) + range.lowerBound
                                value = (rawValue / step).rounded() * step

                                // Snap to nearest percentage point
                                value = snapToClosest(value, in: percentagePoints)
                            }
                    )
            }
        }
        .frame(height: thumbSize) // Ensure the frame accommodates the thumb size
    }

    // Function to snap to the nearest point in the percentagePoints array
    private func snapToClosest(_ value: Double, in points: [Double]) -> Double {
        guard let closest = points.min(by: { abs($0 - value) < abs($1 - value) }) else {
            return value
        }
        return closest
    }
}



#Preview {
    TradeView2().environmentObject(UserStore()).environmentObject(OrderStore()).environmentObject(AppData())
}


struct TradeChartView: View {
    @State private var selectedView: String = "Chart"
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack{
                Button(action: {
                    selectedView = "Chart"
                }, label: {
                    Text("Chart")
                        .font(.system(size: 12, weight: .regular))
                        .padding(5)
                        .foregroundColor(selectedView == "Chart" ? Color.white : Color.secondary)
                        .background(selectedView == "Chart" ? Color.blue : Color.gray.opacity(0.1))
                })
                .cornerRadius(5)
                
                Button(action: {
                    selectedView = "Depth"
                }, label: {
                    Text("Depth")
                        .font(.system(size: 12, weight: .regular))
                        .padding(5)
                        .foregroundColor(selectedView == "Depth" ? Color.white : Color.secondary)
                        .background(selectedView == "Depth" ? Color.blue : Color.gray.opacity(0.1))
                })
                .cornerRadius(5)
                
                Button(action: {
                    selectedView = "Market trades"
                }, label: {
                    Text("Market trades")
                        .font(.system(size: 12, weight: .regular))
                        .padding(5)
                        .foregroundColor(selectedView == "Market trades" ? Color.white : Color.secondary)
                        .background(selectedView == "Market trades" ? Color.blue : Color.gray.opacity(0.1))
                })
                .cornerRadius(5)
            }
            if (selectedView == "Chart") {
                ChartView(instrumnet_id: 1)
                    .frame(height: 150)
                    .padding(10)
            } else if (selectedView == "Depth") {
                VStack{
                    HStack{
                        Spacer()
                        Text("Depth ")
                            .frame(height: 150)
                            .frame(width: .infinity)
                            .padding(10)
                        Spacer()
                    }
                }
            }  else if (selectedView == "Market trades") {
                VStack{
                    HStack{
                        Spacer()
                        Text("Market trades ")
                            .frame(height: 150)
                            .frame(width: .infinity)
                            .padding(10)
                        Spacer()
                    }
                }
                
            }
        }
        .padding(10)
        .background(colorScheme == .dark ? Color.gray.opacity(0.5) : Color.gray.opacity(0.05))
        .clipShape(RoundedCorner(radius: 10, corners: [.allCorners]))
    }
}
