//
//  WebSocketManager.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/26/24.
//

import Foundation
import Combine

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask!
    
    // Publisher for received messages
    let receivedMessagePublisher = PassthroughSubject<String, Never>()
    
    init() {
        let url = URL(string: "ws://127.0.0.1:1092")!
        let urlSession = URLSession(configuration: .default)
        self.webSocketTask = urlSession.webSocketTask(with: url)
        
        self.connect()
    }
    
    func connect() {
        self.webSocketTask.resume()
        
        self.receiveMessages()
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
                        
                        // Publish the received message
                        self.receivedMessagePublisher.send(receivedMessage)
                        
                        // Handle the received message (e.g., append to messages array)
                    }
                case .string(let text):
                    print("Received message: \(text)")
                    
                    // Publish the received message
                    self.receivedMessagePublisher.send(text)
                    
                    // Handle the received message (e.g., append to messages array)
                @unknown default:
                    fatalError()
                }
                
                // Continue to receive messages
                self.receiveMessages()
                
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
    
    func close() {
        self.webSocketTask.cancel(with: .goingAway, reason: nil)
    }
}
