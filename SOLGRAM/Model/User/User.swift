//
//  User.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 8/30/24.
//

import Foundation


struct RegisterInfo: Codable {
    let username: String
    let email: String
    let password: String
    var first_name: String
    var last_name: String
}

struct DepositUser: Codable {
    var user_id: Int
    var amount: Double
}

struct UserBalance: Codable {
    var user_id: Int
    var cash_balance: Double
    var reserved_balance: Double
    var total_balance: Double
    var updated_at: String
}

struct User: Codable {
    var user_id: String
    var username: String
    var email: String
    var password_hash: String
    var first_name: String
    var last_name: String
    var created_at: Date
    var updated_at: Data
    var last_login: Date
}


struct RegisterResponse: Codable {
    let user_id: Int
}
struct UserInfo: Codable{
//    var access_token: String
    var user_id: Int
    var username: String
    var email: String
    var first_name: String
    var last_name: String
}

struct AccessToken: Codable {
    var access_token: String
    var user_id: Int
}
