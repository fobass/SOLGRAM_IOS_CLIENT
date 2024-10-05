//
//  SOLGRAMApp.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/23/24.
//

import SwiftUI

@main
struct SOLGRAMApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(AppData()).environmentObject(UserStore()).environmentObject(InstrumentStore()).environmentObject(OrderStore())
//            RegisterView(store: UserStore())
        }
    }
}
