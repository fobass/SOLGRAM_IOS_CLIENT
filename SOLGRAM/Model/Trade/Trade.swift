//
//  OrderTicker.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/26/24.
//

import Foundation

enum OrderType: String, Codable {
    case LIMIT = "Limit"
    case MARKET = "Market"
    case STOP_LIMIT = "Stop Limit"
    
    var stringValue: String {
        return rawValue
    }
    
    static func stringRepresentation(fromRawValue rawValue: String) -> String? {
        guard let sideEnum = OrderType(rawValue: rawValue) else {
            return rawValue
        }
        return sideEnum.stringValue
   }
}

enum Side: String, Codable {
    case BUY = "BUY"
    case SELL = "SELL"
    case CANCEL = "Cancel"
    case REVISE = "Revise"
    
    static func fromRawValue(_ rawValue: String) -> Side {
        return Side(rawValue: rawValue) ?? .CANCEL
    }
    
    var stringValue: String {
        return rawValue
    }
    
    static func stringRepresentation(fromRawValue rawValue: String) -> String? {
        guard let sideEnum = Side(rawValue: rawValue) else {
            return rawValue
        }
        return sideEnum.stringValue
   }
    
    static func fromInt(_ int: Int)-> Side {
        return (int == 0) ? .BUY : .SELL
    }
}

struct OrderPad {
    var side: Side
    var instrumnet: Instrument
}

enum MessageType: String, Codable {
    case NewOrder
    case CancelOrder
    case OrderAck
    case NewOrderUpdate
    case MarketUpdate
    case MarketDepth
    case Orders
}

//struct OmsMessage<T>: Codable where T: Codable {
//    var _type: MessageType
//    var payload: T
//    
//    // Implement custom encoding and decoding
//    enum CodingKeys: String, CodingKey {
//        case _type
//        case payload
//    }
//    
//    // Encodable conformance
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(_type.rawValue, forKey: ._type)
//        
//        if let encodablePayload = payload as? Encodable {
//            try container.encode(encodablePayload, forKey: .payload)
//        } else {
//            // Handle the case where payload is not Encodable (e.g., print a warning, omit, etc.)
//            // Note: This may not be necessary if you can guarantee that payload is always Encodable
//        }
//    }
//    
//    // Decodable conformance
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        _type = try container.decode(MessageType.self, forKey: ._type)
//        
//        do {
//            payload = try container.decode(T.self, forKey: .payload)
//        } catch {
//            // Handle the decoding error (e.g., assign a default value or throw a custom error)
//            // Note: This may not be necessary if you can guarantee that payload is always Decodable
//            payload = OrderTicket.self as! T
//        }
//    }
//    
//    init(_type: MessageType, value: T) {
//        self._type = _type
//        self.payload = value
//    }
//}


struct DepthPayload: Codable {
    var subscribe: Bool
    var instrument_id: Int
}
// Define the main struct for the JSON object
struct MarketDepthResponse: Codable {
    let _type: MessageType       // _type maps to "type" in Swift (renaming for better Swift convention)
    let payload: [DepthEntry]
}

struct DepthEntry: Codable {
    let action: String //0 - insert 1 - update 2 - delete
    let level: Int
    let price: Double
    let quantity: Double
    let side: Int
    let order_id: Int
}

struct Depths {
    var buy_depth: [Int: DepthSide] = [:] // Dictionary keyed by level
    var sell_depth: [Int: DepthSide] = [:]
}

struct DepthSide: Identifiable {
    var id: Int { level }
    let level: Int
    let price: Double
    var quantity: Double
    let side: Int
    let order_id: Int
}
//extension DepthEntry {
//    init(from decoder: Decoder) throws {
//        do {
//            var container = try decoder.unkeyedContainer()
//            
//            self.level = try container.decode(Int.self)
//            self.price = try container.decode(Double.self)
//            self.quantity = try container.decode(Double.self)
//            self.side = try container.decode(Int.self)
//        } catch let error {
//            print("Failed to decode DepthEntry: \(error)")
//            throw error // Re-throw the error so it can be handled by higher-level code if needed
//        }
//    }
//}


//struct Depth: Codable {
//    var level: Int = 0
//    var instrument_id: Int = 0
//    var buy_depth: [DepthSide]
//    var sell_depth: [DepthSide]
//
////    private enum CodingKeys: String, CodingKey {
////        case level
////        case instrumentId = "instrument_id"
////        case buyDepth = "buy_depth"
////        case sellDepth = "sell_depth"
////    }
//    init(){
//        self.buy_depth = [DepthSide.init(level: 0, price: 0, quantity: 0, side: 0)]
//        self.sell_depth = [DepthSide.init(level: 0, price: 0, quantity: 0, side: 0)]
//    }
//    init(level: Int, instrument_id: Int) {
//        self.level = level
//        self.instrument_id = instrument_id
//        self.buy_depth = [DepthSide.init(level: 0, price: 0, quantity: 0, side: 0)]
//        self.sell_depth = [DepthSide.init(level: 0, price: 0, quantity: 0, side: 0)]
//    }
//    
//}

struct OrdersPayload: Codable {
    var _type: MessageType
    var payload: [Order]
}

struct MessagePayload<T: Codable>: Codable {
    var _type: MessageType
    var payload: T
}


//struct UpdatePayload: Codable {
//    var _type: MessageType
//    var payload: AnyCodablePayload
//
//    struct AnyCodablePayload: Codable {
//        var value: Any
//
//        init<T: Codable>(_ value: T) {
//            self.value = value
//        }
//
//        func encode(to encoder: Encoder) throws {
//            (value as AnyObject).encode(encoder)
//        }
//
//        init(from decoder: Decoder) throws {
//            let container = try decoder.singleValueContainer()
//            if let depthValue = try? container.decode(MarketDepthPayloadUpdate.self) {
//                value = depthValue
//            } else if let orderTicketValue = try? container.decode(OrderTicketPayload.self) {
//                value = orderTicketValue
//            } else {
//                throw DecodingError.dataCorruptedError(
//                    in: container,
//                    debugDescription: "Unsupported payload type"
//                )
//            }
//        }
//    }
//}
struct CancelTicket: Codable {
    var ticket_no = UUID().uuidString
    
    init(from ticket_no: String) {
        self.ticket_no = ticket_no
    }
}

//{"created_at":"2024-09-09T19:34:06.663550","instrument_id":4,"order_id":122,"order_type":"LIMIT","price":13199.4,"quantity":0.0,"side":1,"status_code":0,"status_text":"ack.","user_id":20}
struct Order: Codable {
    var client_id: Int  // Add this line
    var user_id: Int
    var order_id: Int
    var ticket_no = UUID().uuidString
    var order_type: String
    var instrument_id: Int
    var code: String
    var price: Double
    var quantity: Double
    var side: Side
    var pair: String
    var status_text: String
    var status_code: Int
    var expiry_date: String
    var created_at: String

//    init(order_type: String, instrument_id: Int, code: String, price: Double, quantity: Double, side: Side, status_text: String, status_code: Int, expiry_date: String, pair: String){
//        self.client_id
//        self.order_type = order_type
//        self.instrument_id = instrument_id
//        self.code = code
//        self.price = price
//        self.quantity = quantity
//        self.side = side
//        self.status_text = status_text
//        self.status_code = status_code
//        self.expiry_date = expiry_date
//        self.pair = pair
//    }
    
//    init(from orderTicket: OrderTicket) {
//        self.ticket_no = orderTicket.ticket_no
//        self.order_type = orderTicket.order_type
//        self.instrument_id = orderTicket.instrument_id
//        self.code = orderTicket.code
//        self.price = orderTicket.price
//        self.quantity = orderTicket.quantity
//        self.side = Side.init(rawValue: orderTicket.side) ?? .SELL
//        self.status_text = orderTicket.status_text
//        self.status_code = orderTicket.status_code
//        self.expiry_date = orderTicket.expiry_date
//        self.pair = orderTicket.pair
//    }
    
    var orderTypeCaption: String {
        return (OrderType.stringRepresentation(fromRawValue: self.order_type.capitalizedFirstChar) ?? self.order_type.capitalizedFirstChar) + "\\" + (self.side.rawValue)
    }
    
    var isBuy: Bool {
        return Side.fromRawValue(self.side.rawValue) == Side.BUY
    }
}
