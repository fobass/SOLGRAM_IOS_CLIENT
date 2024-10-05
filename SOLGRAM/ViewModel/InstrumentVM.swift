//
//  InstrumentStore.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/23/24.
//

import Foundation
import Combine
import DGCharts

final class InstrumentStore: ObservableObject {
    @Published var items: [Instrument] = []
    @Published var detail: Instrument_Detail
    private var cancellables: Set<AnyCancellable> = []
    @Published var searchResults: [Instrument] = []
    @Published var candle: [CandleChartDataEntry] = []
    @Published var webSocketManager = WebSocketManager()
//    [CandleChartDataEntry] = [
//            CandleChartDataEntry(x: 1, shadowH: 22.0, shadowL: 10.1, open: 15, close: 12),
//            CandleChartDataEntry(x: 2, shadowH: 14.0, shadowL: 12.1, open: 13, close: 12),
//            CandleChartDataEntry(x: 3, shadowH: 2.0, shadowL: 0.1, open: 5, close: 1),
//            CandleChartDataEntry(x: 4, shadowH: 4.0, shadowL: 2.1, open: 3, close: 2)
//        ]
    @Published var searchText: String = "" {
            didSet {
                if searchText.isEmpty {
                    // When search text is cleared, reset search results
                    searchResults = items
                } else {
                    // Perform server search when search text is updated
                    fetchSearchResults(query: searchText)
                }
            }
        }
    init() {
//        self.items = [
//            Instrument.init(instrument_id: 1, code: "N2N", symbol: "N2N Connect", last_price: 445, prev_price: 443, change: 1.0),
//            Instrument.init(instrument_id: 2, code: "GOGG", symbol: "GOOGLE INC", last_price: 523, prev_price: 540, change: 0.5),
//            Instrument.init(instrument_id: 3, code: "APPL", symbol: "APPLE INC", last_price: 230, prev_price: 230, change: 0.7),
//            Instrument.init(instrument_id: 4, code: "AMA", symbol: "AMAZON INC", last_price: 450, prev_price: 445, change: 1.2),
//            Instrument.init(instrument_id: 5, code: "BTC", symbol: "Bitcoin", last_price: 6245, prev_price: 6230, change: 5.0),
//            Instrument.init(instrument_id: 6, code: "SOL", symbol: "Solana", last_price: 100, prev_price: 98, change: 0.3),
//            Instrument.init(instrument_id: 7, code: "ETH", symbol: "Etherium", last_price: 2300, prev_price: 2400, change: 0.7),
//            Instrument.init(instrument_id: 8, code: "ADA", symbol: "Cordana", last_price: 50, prev_price: 45, change: 1.2)
//        ]
        self.detail = Instrument_Detail(
                    instrument_id: -1,
//                    code: "",
//                    symbol: "",
//                    last_price: 0.0,
//                    prev_price: 0.0,
//                    change: 0,
//                    today_change: 0.0,
//                    day_7_change: 0.0,
//                    day_30_change: 5.0,
//                    day_90_change: 0.0,
//                    day_180_change: 0.0,
//                    year_1_change: 0,
//                    market_cap: 0,
                    vol_24: 0,
                    high_24: 0,
                    low_24: 0
//                    total_vol: 0
                )
      
                
        webSocketManager.receivedMessagePublisher
            .sink { [weak self] message in
                self?.updateStore(with: message)
            }
            .store(in: &cancellables)
        
        self.fetch()
    }
    
    func load(numberOfRows: Int = 0) -> [Instrument] {
        if (numberOfRows > 0) {
            return Array(self.items.prefix(numberOfRows))
        }
        return self.items
    }
    func clearChart() {
        self.candle = []
    }
    func getChartDataById(id: Int, interval: Int){
        
        guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":8080/api/instrument/charts/" + String(id)) else {
              return
          }
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // You can use "PUT" or other HTTP methods depending on your API requirements
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: sortParameters)
//            request.httpBody = jsonData
//        } catch {
//            print("Error encoding sort parameters: \(error)")
//            return
//        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
          if let error = error {
              print("Error: \(error)")
              return
          }

          guard let data = data else {
              print("No data received.")
              return
          }

          do {
              let decoder = JSONDecoder()
                     
             // Custom date format to match your timestamp string
             let dateFormatter = DateFormatter()
             dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
             decoder.dateDecodingStrategy = .formatted(dateFormatter)

             let candles = try decoder.decode([Candle].self, from: data)
             DispatchQueue.main.async {
                 
                 
                 for (index, candle) in candles.enumerated() {
                    let timestamp = candle.timestamp.timeIntervalSince1970 / 3600  // Small offset for uniqueness
                    self.candle.append(CandleChartDataEntry(x: timestamp,
                                                             shadowH: candle.high_price,
                                                             shadowL: candle.low_price,
                                                             open: candle.open_price,
                                                             close: candle.close_price))
                    
                 }
                 
                 let xValues = self.candle.map { $0.x }
                 let uniqueXValues = Set(xValues)
                 print("Unique X Values Count: \(uniqueXValues.count), Total Entries: \(self.candle.count)")

                
             }
          } catch {
              print("Error decoding JSON: \(error)")
          }
        }.resume()
    }
    
    func getInstrumentById(id: Int){
        
        guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":8080/api/instrument/" + String(id)) else {
              return
          }

        URLSession.shared.dataTask(with: url) { data, response, error in
          if let error = error {
              print("Error: \(error)")
              return
          }

          guard let data = data else {
              print("No data received.")
              return
          }

          do {
              let decodedData = try JSONDecoder().decode(Instrument_Detail.self, from: data)
              DispatchQueue.main.async {
                  self.detail = decodedData
//                  self.objectWillChange.send()
              }
          } catch {
              print("Error decoding JSON: \(error)")
          }
        }.resume()
    }
    	
    func fetch() {
        guard let url = URL(string: "http://" + AppData.shared.ipAddress + ":8080/api/instruments") else {
              return
          }
        var request = URLRequest(url: url)
        request.httpMethod = "GET" // You can use "PUT" or other HTTP methods depending on your API requirements
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: sortParameters)
//            request.httpBody = jsonData
//        } catch {
//            print("Error encoding sort parameters: \(error)")
//            return
//        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
          if let error = error {
              print("Error: \(error)")
              return
          }

          guard let data = data else {
              print("No data received.")
              return
          }

          do {
              let instruments = try JSONDecoder().decode([Instrument].self, from: data)
              DispatchQueue.main.async {
                  self.items = instruments 
                  self.searchResults = self.items
              }
          } catch {
              print("Error decoding JSON: \(error)")
          }
        }.resume()
    }
    
    func fetchSearchResults(query: String) {
           // API call to search instruments based on the query
           let searchURL = URL(string: "http://" + AppData.shared.ipAddress + ":8080/api/instruments/search?q=\(query)")!
           
           URLSession.shared.dataTask(with: searchURL) { data, response, error in
               if let data = data {
                   let results = try? JSONDecoder().decode([Instrument].self, from: data)
                   DispatchQueue.main.async {
                       self.searchResults = results ?? []
                   }
               }
           }.resume()
    }
    
    func fetchTopGainers() {
        let url = URL(string: "http://" + AppData.shared.ipAddress + ":8080/api/instruments/top-gainers")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // You can use "PUT" or other HTTP methods depending on your API requirements
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: sortParameters)
//            request.httpBody = jsonData
//        } catch {
//            print("Error encoding sort parameters: \(error)")
//            return
//        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
          if let error = error {
              print("Error: \(error)")
              return
          }

          guard let data = data else {
              print("No data received.")
              return
          }

          do {
              let instruments = try JSONDecoder().decode([Instrument].self, from: data)
              DispatchQueue.main.async {
                  self.items = instruments
                  self.searchResults = self.items
              }
          } catch {
              print("Error decoding JSON: \(error)")
          }
        }.resume()
    }
    
    func fetchTopLosers() {
        let url = URL(string: "http://" + AppData.shared.ipAddress + ":8080/api/instruments/top-losers")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET" // You can use "PUT" or other HTTP methods depending on your API requirements
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: sortParameters)
//            request.httpBody = jsonData
//        } catch {
//            print("Error encoding sort parameters: \(error)")
//            return
//        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
          if let error = error {
              print("Error: \(error)")
              return
          }

          guard let data = data else {
              print("No data received.")
              return
          }

          do {
              let instruments = try JSONDecoder().decode([Instrument].self, from: data)
              DispatchQueue.main.async {
                  self.items = instruments
                  self.searchResults = self.items
              }
          } catch {
              print("Error decoding JSON: \(error)")
          }
        }.resume()
    }

    
    func updateStore(with message: String) {
        if let jsonData = message.data(using: .utf8) {
            do {
                let instrumentData = try JSONDecoder().decode(FeedDataPayload.self, from: jsonData)
                updateInstrumentById(instrumentData)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("Invalid JSON string")
        }
        print(message)
    }
    
    func updateInstrumentById(_ updatedInstrument: FeedDataPayload) {
        DispatchQueue.main.async {
            if let index = self.searchResults.firstIndex(where: { $0.id == updatedInstrument.id }) {
                var instrumentToUpdate = self.searchResults[index]
                instrumentToUpdate.last_price = updatedInstrument.last_price
                instrumentToUpdate.prev_price = updatedInstrument.prev_price
                instrumentToUpdate.change = updatedInstrument.change
                instrumentToUpdate.addNewSparkPoint(newY: updatedInstrument.last_price)
                self.searchResults[index] = instrumentToUpdate
                
            }
            
            if let index = self.items.firstIndex(where: { $0.id == updatedInstrument.id }) {
                var instrumentToUpdate = self.items[index]
                instrumentToUpdate.last_price = updatedInstrument.last_price
                instrumentToUpdate.prev_price = updatedInstrument.prev_price
                instrumentToUpdate.change = updatedInstrument.change
                instrumentToUpdate.addNewSparkPoint(newY: updatedInstrument.last_price)
                self.items[index] = instrumentToUpdate
            }
        }
    }
    
    
}





