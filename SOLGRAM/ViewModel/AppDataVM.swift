//
//  AppData.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 9/6/24.
//

import Foundation
import Security // For Keychain
import Dispatch // Needed for main thread dispatch




class AppData: ObservableObject {
    @Published var dataForTrade: OrderPad = .init(side: Side.BUY, instrumnet: Instrument.init(instrument_id: 495, code: "STON", symbol: "", last_price: 0, prev_price: 0, change: 0, volume: 0, spark: []))
    static let shared = AppData()
    var ipAddress: String = "192.168.0.104"
    init() {

    }
    
    
    
    
    
    
    
    
//    func verify_token(){
////        let token = getTokenFromUserDefaults() ?? ""
////        if (token != "") {
//            guard let url = URL(string: "http://192.168.0.107:7777/api/verify_token") else { return }
//            
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//            let authHeader = "Bearer \(String(describing: accessToken))"
//            request.addValue(authHeader, forHTTPHeaderField: "Authorization")
//            
//            // Add request body
//               do {
//                   let jsonData = try JSONSerialization.data(withJSONObject: ["key": "value"], options: [])
//                   request.httpBody = jsonData
//               } catch {
//                   print("Error encoding payload: \(error)")
//                   return
//               }
//            
//            URLSession.shared.dataTask(with: request) { data, response, error in
//                guard let data = data else { return }
//                
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                    if let user_id = json?["user_id"] as? Int {
//                        // Save the token securely (e.g., in memory or Keychain)
//                        print("verify_token \(user_id)")
////                        self.userInfo.user_id = user_id
//////                        self.userInfo.access_token = token
////                        self.userInfo.username = UserDefaults.standard.string(forKey: "username") ?? ""
////                        self.userInfo.email =  UserDefaults.standard.string(forKey: "email") ?? ""
////                        self.userInfo.first_name = UserDefaults.standard.string(forKey: "firstName") ?? ""
////                        self.userInfo.last_name = UserDefaults.standard.string(forKey: "lastName") ?? ""
//                    } else {
//                        //error need to implimnet
//                    }
//                } catch {
//                    print("Failed to decode token: \(error)")
//                }
//            }.resume()
//        }
//    }
    
}
