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
    @Published var depths: [Depth] = []
    @Published var webSocketManager = TradeSocketManager()
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
                if let depthValue = try? decoder.decode(MarketDepthUpdatePayload.self, from: jsonData) {
                    updateDepth(depth: depthValue.payload)
                } else if let orderUpdateValue = try? decoder.decode(OrderUpdatePayload.self, from: jsonData) {
                    updateOrderById(orderUpdateValue.payload)
                }
                print(jsonData)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("Invalid JSON string")
        }
        print(message)
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
    
    func submitOrder(orderTicket: OrderTicketPayload){
        webSocketManager.submitOrder(orderTicket: orderTicket)
    }
    
    func updateDepth(depth: [Depth]) {
        DispatchQueue.main.async {
            self.depths.append(contentsOf: depth)
//            for newDepth in depth {
//                if let existingDepthIndex = self.depths.firstIndex(where: { $0.level == newDepth.level }) {
//                    // Update existing depth
//                    self.depths[existingDepthIndex] = newDepth
//                } else {
//                    // Append new depth
//                    self.depths.append(newDepth)
//                }
//            }
        }
    }

    
    func subscribeDepth(depth: MarketDepthPayload){
//        webSocketManager.subscribeDepth(depth: depth)
    }
}
