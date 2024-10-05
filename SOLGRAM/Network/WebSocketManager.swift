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
    let receivedMessagePublisher = PassthroughSubject<String, Never>()
    var isConnectd: Bool = false
    init() {
        let url = URL(string: "ws://" + AppData.shared.ipAddress + ":1092")!
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
    
    func close() {
        self.webSocketTask.cancel(with: .goingAway, reason: nil)
    }
}
