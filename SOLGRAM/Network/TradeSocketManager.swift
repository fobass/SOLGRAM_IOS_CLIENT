//
//  TradeSocketManager.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/28/24.
//

import Foundation
import Combine

class TradeSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask!
    let receivedMessagePublisher = PassthroughSubject<String, Never>()
    var isConnectd: Bool = false
    init() {
        let url = URL(string: "ws://127.0.0.1:57762")!
        let urlSession = URLSession(configuration: .default)
        self.webSocketTask = urlSession.webSocketTask(with: url)
        self.connect()
    }
    
    func connect() {
        if (!isConnectd) {
            self.webSocketTask.resume()
            
            self.receiveMessages()
            self.isConnectd = true
        }
    }
    
    func receiveMessages() {
        self.webSocketTask.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    if let receivedMessage = String(data: data, encoding: .utf8) {
                        print("Received message: \(receivedMessage)")
                        self.receivedMessagePublisher.send(receivedMessage)
                    }
                case .string(let text):
                    print("Received message: \(text)")
                    self.receivedMessagePublisher.send(text)
                @unknown default:
                    fatalError()
                }
                self.receiveMessages()
                
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
            
            
        }
        
    }
    
    func sendMessage(_ message: String) {
        let messageData = URLSessionWebSocketTask.Message.string(message)
        
        self.webSocketTask.send(messageData) { error in
            if let error = error {
                print("WebSocket couldn't send message: \(error)")
            } else {
                print("Message sent successfully: \(message)")
            }
        }
    }
    
    func submitOrder(orderTicket: OrderTicketPayload) {
        do {
            let jsonData = try JSONEncoder().encode(orderTicket)

            let message = URLSessionWebSocketTask.Message.data(jsonData)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("WebSocket couldn't send message: \(error)")
                }
            }
        } catch {
            print("Error encoding order to JSON: \(error)")
        }
    }

    func subscribeDepth(depth: MarketDepthPayload) {
        do {
            let jsonData = try JSONEncoder().encode(depth)

            let message = URLSessionWebSocketTask.Message.data(jsonData)
            webSocketTask?.send(message) { error in
                if let error = error {
                    print("WebSocket couldn't send message: \(error)")
                }
            }
        } catch {
            print("Error encoding order to JSON: \(error)")
        }
    }

    func close() {
        self.webSocketTask.cancel(with: .goingAway, reason: nil)
        self.isConnectd = false
    }
}
