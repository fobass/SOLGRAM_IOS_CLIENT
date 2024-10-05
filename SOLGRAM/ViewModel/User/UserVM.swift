//
//  UserVM.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 8/30/24.
//

import Foundation
import Combine


func isTokenValid1(_ token: String) -> Bool {
    guard let payload = decodeJWT(token),
          let exp = payload["exp"] as? TimeInterval else {
        return false
    }
    
    let expirationDate = Date(timeIntervalSince1970: exp) // Get expiration date
    
    // Debug print to check formatted date for logs
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Ensure using UTC
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let formattedDate = dateFormatter.string(from: expirationDate)
    print("Formatted expiration date: \(formattedDate)")

    // Compare expiration date with current date
    return expirationDate > Date()
}

func saveToken(token: String) {
    DispatchQueue.global(qos: .background).async {
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "accessToken"
        ]
        
        let tokenData = token.data(using: .utf8)!
        
        // Check if the token already exists, if so update it
        if SecItemCopyMatching(keychainQuery as CFDictionary, nil) == errSecSuccess {
            let updateAttributes: [String: Any] = [
                kSecValueData as String: tokenData
            ]
            
            let status = SecItemUpdate(keychainQuery as CFDictionary, updateAttributes as CFDictionary)
            
            DispatchQueue.main.async {
                if status == errSecSuccess {
                    print("Token successfully updated.")
                } else {
                    print("Failed to update token with status: \(status)")
                }
            }
        } else {
            // If the token does not exist, add it to the Keychain
            var newKeychainQuery = keychainQuery
            newKeychainQuery[kSecValueData as String] = tokenData
            
            let status = SecItemAdd(newKeychainQuery as CFDictionary, nil)
            
            DispatchQueue.main.async {
                if status == errSecSuccess {
                    print("Token successfully saved.")
                } else {
                    print("Failed to save token with status: \(status)")
                }
            }
        }
    }
}


// Example function to retrieve token from Keychain
func getToken() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "accessToken",
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    
    var item: CFTypeRef?
    if SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess {
        if let data = item as? Data, let token = String(data: data, encoding: .utf8) {
            return token
        }
    }
    return nil
}

func clearToken() {
    let keychainQuery: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "accessToken"
    ]
    
    // Delete the token from Keychain
    let status = SecItemDelete(keychainQuery as CFDictionary)
    
    if status == errSecSuccess {
        print("Token successfully deleted from Keychain.")
    } else {
        print("Failed to delete token from Keychain with status: \(status)")
    }
}

func decodeJWT(_ jwt: String) -> [String: Any]? {
    let segments = jwt.split(separator: ".")
    guard segments.count == 3,
          let payloadData = base64UrlDecode(String(segments[1])) else {
        return nil
    }

    let json = try? JSONSerialization.jsonObject(with: payloadData, options: [])
    return json as? [String: Any]
}

func base64UrlDecode(_ value: String) -> Data? {
    var base64 = value
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")
    
    let length = Double(base64.lengthOfBytes(using: .utf8))
    let requiredLength = 4 * ceil(length / 4.0)
    let paddingLength = requiredLength - length
    if paddingLength > 0 {
        base64 += String(repeating: "=", count: Int(paddingLength))
    }
    
    return Data(base64Encoded: base64)
}


final class UserStore: ObservableObject {
    @Published var userId : Int = 0
    @Published var userBalance: UserBalance = UserBalance.init(user_id: 0, cash_balance: 0, reserved_balance: 0, total_balance: 0, updated_at: "-")
    @Published var isAuthenticated: Bool = false
    @Published var userInfo : UserInfo
    @Published var accessToken: String? {
           didSet {
               if let token = accessToken {
                   DispatchQueue.global(qos: .background).async {
                       saveToken(token: token)
                   }
               } else {
                   DispatchQueue.global(qos: .background).async {
                       clearToken()
                   }
               }
           }
       }
    
    init() {
        self.userInfo = .init(user_id: 0, username: "", email: "", first_name: "", last_name: "")
        checkAuthentication()
    }
    
    func logout() {
        self.accessToken = nil
        self.isAuthenticated = false
        clearToken()
    }
    
//    struct TimeInterval {
//        let value: Double
//        
//        init(_ value: Double) {
//            self.value = value
//        }
//        
//        // Add a computed property to get the Double value
//        var asDouble: Double {
//            return value
//        }
//    }

    // Then your function can be:
    func isTokenValid(_ token: String) -> Bool {
        guard let payload = decodeJWT(token),
              let exp = payload["exp"] as? TimeInterval else {
            return false
        }
        
        let expirationDate = Date(timeIntervalSince1970: exp) // Get expiration date
        
        // Debug print to check formatted date for logs
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Ensure using UTC
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: expirationDate)
        print("Formatted expiration date: \(formattedDate)")

        // Compare expiration date with current date
        return expirationDate > Date()
    }


    
    func checkAuthentication() {
        DispatchQueue.global(qos: .background).async {
            if let token = getToken() {
                // Assuming token validation logic here
                if self.isTokenValid(token) {
                    DispatchQueue.main.async {
                        self.accessToken = token
                        
                        self.isAuthenticated = true
                        let user_id = UserDefaults.standard.object(forKey: "user_id") as? Int
                        self.getUserProfile(with: user_id!)
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        self.isAuthenticated = false
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.isAuthenticated = false
                }
            }
        }
    }
    
    func register(registerInfo: RegisterInfo) {
        guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":7777/api/register") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(registerInfo)
            request.httpBody = jsonData
        } catch {
            print("Error encoding register info: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let data = data else {
                print("No data received.")
                return
            }

            // Check HTTP response status code
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }

            do {
                
                let decodedData = try JSONDecoder().decode(UserInfo.self, from: data)
                self.userInfo = decodedData
//                UserDefaults.standard.set(self.userInfo.access_token, forKey: "authToken")
                UserDefaults.standard.set(self.userInfo.username, forKey: "username")
                UserDefaults.standard.set(self.userInfo.email, forKey: "email")
                UserDefaults.standard.set(self.userInfo.first_name, forKey: "firstName")
                UserDefaults.standard.set(self.userInfo.last_name, forKey: "lastName")
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    
    func login(username: String, password: String) {
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":7777/api/login") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let credentials = ["username": username, "password": password]
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: credentials) else { return }
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                do {
                    let auth = try JSONDecoder().decode(AccessToken.self, from: data)
                    DispatchQueue.main.async {
                        self.accessToken = auth.access_token
//                        self.isTokenValid(self.accessToken ?? "")
                        UserDefaults.standard.set(auth.user_id, forKey: "user_id")
                        self.getUserProfile(with: auth.user_id, token: auth.access_token)
                        self.isAuthenticated = true
                    }
                    print("Access token \(auth)")
                } catch {
                    print("Failed to decode token: \(error)")
                }
            }.resume()
        }
    }
    
    func getUserBalance(with userId: Int) {
        if let accessToken = getToken() {
            guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":7777/api/user_balance/" + String(userId)) else {
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

          

            let authHeader = "Bearer \(accessToken)"
            request.addValue(authHeader, forHTTPHeaderField: "Authorization")

            // No need for HTTP body in GET request.
            request.httpBody = nil

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error making request: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        print("Failed with status code: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode(UserBalance.self, from: data)
                    DispatchQueue.main.async {
                        self.userBalance = decodedData
                    }
                } catch {
                    print("Failed to decode response: \(error)")
                }
            }.resume()

        }
    }
    func getUserProfile(with userId: Int, token: String? = nil) {
        let accessToken: String
        
        if let token = token {
            accessToken = token
        } else {
            accessToken = getToken()!
        }
        
        if !accessToken.isEmpty {
            guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":7777/api/user_profile/" + String(userId)) else {
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

          

            let authHeader = "Bearer \(accessToken)"
            request.addValue(authHeader, forHTTPHeaderField: "Authorization")

            // No need for HTTP body in GET request.
            request.httpBody = nil

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error making request: \(error)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                    if httpResponse.statusCode != 200 {
                        print("Failed with status code: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    let decodedData = try JSONDecoder().decode(UserInfo.self, from: data)
                    DispatchQueue.main.async {
                        self.userInfo = decodedData
                    }
                } catch {
                    print("Failed to decode response: \(error)")
                }
            }.resume()

        }
    }
    func deposite(userId: Int, amount: Double) {

        guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":7777/api/deposit") else {
            print("Invalid URL")
            return
        }

        let registerInfo = DepositUser(user_id: userId, amount: amount)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(registerInfo)
            request.httpBody = jsonData
        } catch {
            print("Error encoding register info: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
          if let error = error {
              print("Error: \(error)")
              return
          }

          guard let data = data else {
              print("No data received.")
              return
          }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("HTTP Error: \(httpResponse.statusCode)")
                return
            }

          do {
              let decodedData = try JSONDecoder().decode(UserBalance.self, from: data)
              DispatchQueue.main.async {
                  self.userBalance = decodedData
              }
          } catch {
              print("Error decoding JSON: \(error)")
          }
        }.resume()
    }

    
}
