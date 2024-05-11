//
//  NewsTickerView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import SwiftUI


struct NewsTickerView: View {
    var body: some View {
        HStack{
            Image(systemName: "flag")
            Text("The first step is to install Rust. We’ll download Rust through rustup, a command line tool for managing Rust versions and associated tools.")
        }
        .frame(height: 12)
        .font(Font.system(size: 12))
//        .padding([.bottom], 5)
    }
}


#Preview {
    NewsTickerView()
}
