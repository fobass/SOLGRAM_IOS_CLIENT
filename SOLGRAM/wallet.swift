//
//  ContentView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 27/04/2023.
//

import SwiftUI
//let endpoint = "https://api.mainnet-beta.solana.com"
//let url = URL(string: "\(endpoint)/")!
//
//struct RpcRequest<T: Codable>: Codable {
//    let jsonrpc = "2.0"
//    let id = 1
//    let method: String
//    let params: [String]?
//
//    enum CodingKeys: CodingKey {
//            case jsonrpc
//            case id
//            case method   // this one was missing
//            case params
//       }
//    init(method: String, params: [String]?) throws {
//        self.method = method
//        self.params = params
//    }
//
//    init(from decoder: Decoder) throws {
//          let values = try decoder.container(keyedBy: CodingKeys.self)
//          self.method = try values.decode(String.self, forKey: .method)
//          let eventDataAsJSONString = try values.decode(String.self, forKey: .params)
//          if let eventDataAsData = eventDataAsJSONString.data(using: .utf8) {
//              self.params = try? JSONSerialization.jsonObject(with: eventDataAsData, options: []) as? [String]
//          } else {
//              self.params = nil
//          }
//      }
//
//      func encode(from encoder: Encoder) throws {
//          var container = encoder.container(keyedBy: CodingKeys.self)
//          try container.encode(self.method, forKey: .method)
//          if let data = self.params {
//              let eventDataAsData = try! JSONSerialization.data(withJSONObject: data, options: [])
//              let eventDataAsJSONString = String(data: eventDataAsData, encoding: .utf8)
//              try container.encode(eventDataAsJSONString, forKey: .params)
//          } else {
//              try container.encodeNil(forKey: .params)
//          }
//      }
//}
//
//func callRpc<T: Codable>(method: String, params: [String], completion: @escaping (Result<T, Error>) -> Void) {
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//    let body = try! RpcRequest<String>(method: method, params: params)
//    let jsonData = try! JSONEncoder().encode(body)
//    request.httpBody = jsonData
//
//    let task = URLSession.shared.dataTask(with: request) { data, response, error in
//        if let error = error {
//            completion(.failure(error))
//            return
//        }
//
//        guard let data = data else {
//            completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
//            return
//        }
//
//        do {
//            let result = try JSONDecoder().decode(RpcResponse<T>.self, from: data)
//            if let error = result.error {
//                completion(.failure(error))
//            } else if let value = result.result {
//                completion(.success(value))
//            } else {
//                completion(.failure(NSError(domain: "Invalid RPC response", code: 0, userInfo: nil)))
//            }
//        } catch {
//            completion(.failure(error))
//        }
//    }
//    task.resume()
//}
//
//struct RpcResponse<T: Codable>: Codable {
//    let jsonrpc: String
//    let id: Int
//    let result: T?
//    let error: RpcError?
//}
//
//struct RpcError: Codable, Error {
//    let code: Int
//    let message: String
//}

let endpoint = "https://api.mainnet-beta.solana.com"
let url = URL(string: "\(endpoint)/")!

struct RpcRequest<T: Codable>: Codable {
    var jsonrpc = "2.0"
    var id = 1
    let method: String
    let params: [T]
}

func callRpc<T: Codable>(method: String, params: [String], completion: @escaping (Result<T, Error>) -> Void) {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    let body = RpcRequest(method: method, params: params)
    let jsonData = try! JSONEncoder().encode(body)
    request.httpBody = jsonData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let data = data else {
            completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
            return
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            
            for (key, value) in jsonObject {
                    if let stringValue = value as? String {
                        print("\(key): \(stringValue)")
                    } else if let intValue = value as? Int {
                        print("\(key): \(intValue)")
                    } else if let dictValue = value as? [String: Any] {
                        // Handle nested dictionaries
                        print("\(key): \(dictValue)")
                    } else if let arrayValue = value as? [Any] {
                        // Handle arrays
                        print("\(key): \(arrayValue)")
                    } else {
                        // Handle other types of values
                        print("\(key): \(value)")
                    }
                }
                
        } catch {
            completion(.failure(error))
        }

//        do {
//            let result = try JSONDecoder().decode(RpcResponse<T>.self, from: data)
//            if let error = result.error {
//                completion(.failure(error))
//            } else if let value = result.result {
//                completion(.success(value))
//            } else {
//                completion(.failure(NSError(domain: "Invalid RPC response", code: 0, userInfo: nil)))
//            }
//        } catch {
//            completion(.failure(error))
//        }
    }
    task.resume()
}

struct RpcResponse<T: Codable>: Codable {
    let jsonrpc: String
    let id: Int
    let result: T?
    let error: RpcError?
}

struct RpcError: Codable, Error {
    let code: Int
    let message: String
}



struct ContentView: View {
    var body: some View {
        Button(action: {
            callRPC()
        }, label: {
            Text("Hello, SOLANA!")
                .padding()
        })
        
    }
    
    func callRPC()  {
        callRpc(method: "getBalance", params: ["4xdL9hQRC3o7YgceQdmrAqNSyKuvXqrqehu3app1jdSw"]) { (result: Result<[String], Error>) in
            switch result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
