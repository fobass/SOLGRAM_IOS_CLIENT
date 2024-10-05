//
//  OrderVM.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/26/24.
//

import Foundation
import Combine

final class OrderStore: ObservableObject {
    
    @Published var orders: [Order] = []
    private var cancellables: Set<AnyCancellable> = []
    @Published var depths: Depths = Depths.init()
    @Published var webSocketManager = TradeSocketManager()
    private var instrument_id: Int = -1
    init() {
        webSocketManager.receivedMessagePublisher
            .sink { [weak self] message in
                self?.updateStore(with: message)
            }
            .store(in: &cancellables)
        
//        self.orders = [ 
//            
//            Order.init(order_type: "Limit", instrument_id: 1, code: "SOL", price: 2.0, quantity: 2.0, side: "Sell", status_text: "ack.", status_code: 0, expiry_date: "20-20-203 22:09:00", pair: "USDT"),
//            Order(order_type: "Stop Lost", instrument_id: 2, code: "ADA", price: 2.0, quantity: 2.0, side: "Buy", status_text: "ack.", status_code: 0, expiry_date: "20-20-203 22:09:00", pair: "USDT")
//        ]
//        self.depths = [
//            Depth.init(level: 1, buy_depth: 1.0, instrument_id: 495, price: 1.0, sell_depth: 2.0),
//            Depth.init(level: 2, buy_depth: 4.0, instrument_id: 495, price: 2.0, sell_depth: 3.0),
//            Depth.init(level: 3, buy_depth: 5.0, instrument_id: 495, price: 3.0, sell_depth: 5.0),
//            Depth.init(level: 4, buy_depth: 6.0, instrument_id: 495, price: 4.0, sell_depth: 8.0),
//            Depth.init(level: 5, buy_depth: 7.0, instrument_id: 495, price: 5.0, sell_depth: 345.0),
//            Depth.init(level: 6, buy_depth: 8.0, instrument_id: 495, price: 6.0, sell_depth: 23.0),
//            Depth.init(level: 7, buy_depth: 9.0, instrument_id: 495, price: 7.0, sell_depth: 1.0),
//            Depth.init(level: 8, buy_depth: 8.0, instrument_id: 495, price: 8.0, sell_depth: 4.0),
//            Depth.init(level: 9, buy_depth: 0.0, instrument_id: 495, price: 9.0, sell_depth: 6.0),
//            Depth.init(level: 10, buy_depth: 0.0, instrument_id: 495, price: 10.0, sell_depth: 7.0)
//        ]
    }
    
    func updateStore(with message: String) {
        if let jsonData = message.data(using: .utf8) {
            do {
                let decoder = JSONDecoder()
                if let depthValue = try? decoder.decode(MarketDepthResponse.self, from: jsonData) {
                    updateDepth(depth: depthValue.payload)
                } else if let orderValue = try? decoder.decode(MessagePayload<Order>.self, from: jsonData) {
                    updateOrderById(orderValue.payload)
                } else if let ordersValue = try? decoder.decode(OrdersPayload.self, from: jsonData) {
                    updateOrdersById(ordersValue.payload)
                }

            }
        } else {
            print("Invalid JSON string")
        }
//        print(message)
    }
    func updateOrdersById(_ updatedOrders: [Order]) {
        DispatchQueue.main.async {
            for order in updatedOrders {
                if let index = self.orders.firstIndex(where: { $0.ticket_no == order.ticket_no }) {
                   if (order.status_code == 1) {
                       self.orders.remove(at: index)
                   } else {
                       self.orders[index] = order
                   }
               } else {
                   self.orders.append(order)
               }
            }
        }
    }
    
    func updateOrderById(_ updatedOrder: Order) {
        DispatchQueue.main.async {
            if let index = self.orders.firstIndex(where: { $0.ticket_no == updatedOrder.ticket_no }) {
                if (updatedOrder.status_code == 1) {
                    self.orders.remove(at: index)
                } else {
                    self.orders[index] = updatedOrder
                }
            } else {
                self.orders.append(updatedOrder)
            }
        }
    }
    
    func submitOrder(order: Order){
        let orderPayload = MessagePayload<Order>(_type: .NewOrder, payload: order)
        self.updateOrderById(order)
        webSocketManager.submitOrder(orderTicket: orderPayload)
    }
    
    func cancelOrder(cancelTicket: CancelTicket) {
        let cancelPayload = MessagePayload<CancelTicket>(_type: .CancelOrder, payload: cancelTicket)
        webSocketManager.cancelOrder(orderTicket: cancelPayload)
    }
    
    func updateDepth(depth: [DepthEntry]) {
        DispatchQueue.main.async {
            for newDepth in depth {
                let side = Side.fromInt(newDepth.side)
                let depthSide = DepthSide(level: newDepth.level, price: newDepth.price, quantity: newDepth.quantity, side: newDepth.side, order_id: newDepth.order_id)
                
                // Check the action type and update depth accordingly
                switch newDepth.action {
                case "insert":
                    if side == .BUY {
                        self.depths.buy_depth[newDepth.order_id] = depthSide
                    } else if side == .SELL {
                        self.depths.sell_depth[newDepth.order_id] = depthSide
                    }
                case "update":
                    if side == .BUY {
                        if let _ = self.depths.buy_depth[newDepth.order_id] {
                            self.depths.buy_depth[newDepth.order_id] = depthSide
                        } else {
//                            print("Level \(newDepth.order_id) not found for update in BUY depth.")
                        }
                    } else if side == .SELL {
                        if let _ = self.depths.sell_depth[newDepth.order_id] {
                            self.depths.sell_depth[newDepth.order_id] = depthSide
                        } else {
//                            print("Level \(newDepth.level) not found for update in SELL depth.")
                        }
                    }
                case "delete":
                    if side == .BUY {
                        
                        if let existingLevel = self.depths.buy_depth.first(where: { $0.value.order_id == newDepth.order_id }) {
                            // If the new quantity is smaller than the existing quantity, subtract it from the existing quantity
                            if newDepth.quantity < existingLevel.value.quantity {
                                self.depths.buy_depth[existingLevel.key]?.quantity -= newDepth.quantity
//                                print("Updated buy depth at price \(newDepth.price) with new quantity \(self.depths.buy_depth[existingLevel.key]?.quantity ?? 0.0)")
                            } else {
                                // If the new quantity is equal or greater, remove the depth entry
                                self.depths.buy_depth.removeValue(forKey: existingLevel.key)
//                                print("Deleted buy depth at price \(newDepth.price) and quantity \(newDepth.quantity)")
                            }
                        }

                        
                    } else if side == .SELL {
                        if let existingLevel = self.depths.sell_depth.first(where: { $0.value.order_id == newDepth.order_id }) {
                            // If the new quantity is smaller than the existing quantity, subtract it from the existing quantity
                            if newDepth.quantity < existingLevel.value.quantity {
                                self.depths.sell_depth[existingLevel.key]?.quantity -= newDepth.quantity
//                                print("Updated buy depth at price \(newDepth.price) with new quantity \(self.depths.sell_depth[existingLevel.key]?.quantity ?? 0.0)")
                            } else {
                                // If the new quantity is equal or greater, remove the depth entry
                                self.depths.sell_depth.removeValue(forKey: existingLevel.key)
//                                print("Deleted buy depth at price \(newDepth.price) and quantity \(newDepth.quantity)")
                            }
                        }
                    }
                default:
                    print("Unknown action: \(newDepth.action)")
                }
            }
//            {"_type":"MarketDepth","payload":[{"action":"insert","level":1,"price":43.0,"quantity":40.0,"side":1}]}
//            {"_type":"MarketDepth","payload":{"action":"delete","level":0,"price":43.0,"quantity":0.0,"side":1}}
        }
    }

    
    func subscribeDepth(instrument_id: Int){
        self.instrument_id = instrument_id
//        self.depths.instrument_id = instrument_id
        let depthPayload = DepthPayload(subscribe: true, instrument_id: instrument_id)
        let messagePayload = MessagePayload<DepthPayload>(_type: .MarketDepth, payload: depthPayload)
        webSocketManager.subscribeDepth(depth: messagePayload)
    }
    
    func unsubscribeDepth(instrument_id: Int){
        self.instrument_id = -1
        let depthPayload = DepthPayload(subscribe: false, instrument_id: instrument_id)
        let messagePayload = MessagePayload<DepthPayload>(_type: .MarketDepth, payload: depthPayload)
        webSocketManager.subscribeDepth(depth: messagePayload)
    }
    
    func loadOrders(userId: Int){
        print("userId \(userId)")
        let ordersPayload = MessagePayload<Int>(_type: .Orders, payload: userId)
        webSocketManager.loadOrders(userId: ordersPayload)
    }
}
