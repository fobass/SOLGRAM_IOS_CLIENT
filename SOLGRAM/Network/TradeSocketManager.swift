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
    let clientIdKey = "client_id"
    init() {
        let url = URL(string: "ws://" + AppData.shared.ipAddress + ":57762")!
        
        let urlSession = URLSession(configuration: .default)
        self.webSocketTask = urlSession.webSocketTask(with: url)
        self.connect()
    }
    
    func connect() {
        if (!isConnectd) {
            self.webSocketTask.resume()
            self.sendClientId()
            self.receiveMessages()
            self.isConnectd = true
        }
    }
    private func generateClientId() -> UInt64 {
           return UInt64.random(in: 100000...999999) // Example of generating random 6-digit client_id
       }
    
    // Function to send client_id after connection
      private func sendClientId() {
          // Retrieve client_id from UserDefaults, or generate if not available
          var clientId: UInt64
          
          if let storedId = UserDefaults.standard.object(forKey: clientIdKey) as? UInt64 {
              clientId = storedId
          } else {
              clientId = generateClientId()
              UserDefaults.standard.set(clientId, forKey: clientIdKey) // Save the client_id for future use
          }

          // Create a JSON message with the client_id
          let clientData: [String: UInt64] = ["client_id": clientId]
          
          // Convert the dictionary to JSON data
          if let jsonData = try? JSONSerialization.data(withJSONObject: clientData) {
              let message = URLSessionWebSocketTask.Message.data(jsonData)
              
              // Send the client_id message
              webSocketTask.send(message) { error in
                  if let error = error {
                      print("Error sending client_id: \(error)")
                  } else {
                      print("client_id \(clientId) sent to server")
                  }
              }
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
//                        print("Received message: \(receivedMessage)")
                        self.receivedMessagePublisher.send(receivedMessage)
                    }
                case .string(let text):
//                    print("Received message: \(text)")
                    DispatchQueue.main.async {
                        self.receivedMessagePublisher.send(text)
                    }
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
    
    func submitOrder(orderTicket: MessagePayload<Order>) {
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
    
    func cancelOrder(orderTicket: MessagePayload<CancelTicket>){
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

    func subscribeDepth(depth: MessagePayload<DepthPayload>) {
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
    
    func unsubscribeDepth(depth:  MessagePayload<DepthPayload>) {
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
    
    func loadOrders(userId: MessagePayload<Int>) {
        do {
            let jsonData = try JSONEncoder().encode(userId)

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
