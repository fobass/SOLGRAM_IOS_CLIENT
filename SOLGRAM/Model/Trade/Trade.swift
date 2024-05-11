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
    case BUY = "Buy"
    case SELL = "Sell"
    case CANCEL = "Cancel"
    case REVISE = "Revise"
    
    static func fromRawValue(_ rawValue: String) -> Side? {
        return Side(rawValue: rawValue)
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
}

struct OmsMessage<T>: Codable where T: Codable {
    var _type: MessageType
    var payload: T
    
    // Implement custom encoding and decoding
    enum CodingKeys: String, CodingKey {
        case _type
        case payload
    }
    
    // Encodable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_type.rawValue, forKey: ._type)
        
        if let encodablePayload = payload as? Encodable {
            try container.encode(encodablePayload, forKey: .payload)
        } else {
            // Handle the case where payload is not Encodable (e.g., print a warning, omit, etc.)
            // Note: This may not be necessary if you can guarantee that payload is always Encodable
        }
    }
    
    // Decodable conformance
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _type = try container.decode(MessageType.self, forKey: ._type)
        
        do {
            payload = try container.decode(T.self, forKey: .payload)
        } catch {
            // Handle the decoding error (e.g., assign a default value or throw a custom error)
            // Note: This may not be necessary if you can guarantee that payload is always Decodable
            payload = OrderTicket.self as! T
        }
    }
    
    init(_type: MessageType, value: T) {
        self._type = _type
        self.payload = value
    }
}


struct OrderTicketPayload: Codable {
    var _type: MessageType
    var payload: OrderTicket
}

struct MarketDepthPayload: Codable {
    var _type: MessageType
    var payload: Int
}

//struct Depth: Codable{
//    var buy_depth: Double
//    var instrument_id: Int
//    var price:Double
//    var sell_depth: Double
//}
struct Depth: Identifiable, Codable {
    var id: Int {
        level
    }
    var level: Int
    var buy_depth: Double
    var instrument_id: Int
    var price: Double
    var sell_depth: Double
    
    var depth: Double {
        return max(buy_depth, sell_depth)
    }
}
struct MarketDepthUpdatePayload: Codable {
    var _type: MessageType
    var payload: [Depth]
}

struct OrderUpdatePayload: Codable {
    var _type: MessageType
    var payload: Order
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


struct OrderTicket: Codable {
    var ticket_no = UUID().uuidString
    var order_type: String
    var instrument_id: Int
    var code: String
    var price: Double
    var quantity: Double
    var side: String
    var status_text: String
    var status_code: Int
    var expiry_date: String
    var pair: String
}

struct Order: Codable {
    var ticket_no = UUID().uuidString
    var order_type: String
    var instrument_id: Int
    var code: String
    var price: Double
    var quantity: Double
    var side: String
    var status_text: String
    var status_code: Int
    var expiry_date: String
    var pair: String
    
    init(order_type: String, instrument_id: Int, code: String, price: Double, quantity: Double, side: String, status_text: String, status_code: Int, expiry_date: String, pair: String){
        self.order_type = order_type
        self.instrument_id = instrument_id
        self.code = code
        self.price = price
        self.quantity = quantity
        self.side = side
        self.status_text = status_text
        self.status_code = status_code
        self.expiry_date = expiry_date
        self.pair = pair
    }
    
    init(from orderTicket: OrderTicket) {
        self.ticket_no = orderTicket.ticket_no
        self.order_type = orderTicket.order_type
        self.instrument_id = orderTicket.instrument_id
        self.code = orderTicket.code
        self.price = orderTicket.price
        self.quantity = orderTicket.quantity
        self.side = orderTicket.side
        self.status_text = orderTicket.status_text
        self.status_code = orderTicket.status_code
        self.expiry_date = orderTicket.expiry_date
        self.pair = orderTicket.pair
    }
    
    var orderTypeCaption: String {
        return (OrderType.stringRepresentation(fromRawValue: self.order_type.capitalizedFirstChar) ?? self.order_type.capitalizedFirstChar) + "\\" +  (Side.stringRepresentation(fromRawValue: self.side.capitalizedFirstChar) ?? self.side.capitalizedFirstChar)
    }
    
    var isBuy: Bool {
        return Side.fromRawValue(self.side.capitalizedFirstChar) == Side.BUY
    }
}
