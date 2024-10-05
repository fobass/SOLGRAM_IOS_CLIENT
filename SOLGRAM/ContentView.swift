//
//  ContentView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/23/24.
//

import SwiftUI
import Charts

struct ContentView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var instrumentStore: InstrumentStore
    @EnvironmentObject var orderStore: OrderStore
    @State private var isLoading = true

    var body: some View {
        VStack {
            if userStore.isAuthenticated {
                if isLoading {
                    ProgressView("Loading...")
                        .onAppear {
                            loadQuoteView()
                        }
                } else {
                    HomeView().environmentObject(appData).environmentObject(userStore).environmentObject(orderStore)
                }
            } else {
                WelcomeView().environmentObject(userStore)
            }
        }
//        .background(Color.white.opacity(0.1))
    }

    func loadQuoteView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation {
                self.isLoading = false
            }
        }
    }
}



struct HeaderView: View {
    @State var searachVal: String = ""
    var body: some View {
        HStack{
            Image(systemName: "person.circle")
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(Font.system(size: 16))
                        .padding(3)
                    TextField("Search", text: $searachVal)
                        .font(Font.system(size: 16))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.7), lineWidth: 1)
                )
            }
//            .padding([.trailing,.leading], 0)
//            .padding([.bottom, .top], 5)
            
            
            Image(systemName: "person.fill.questionmark")
            Image(systemName: "bell.badge.circle")
        }
        .font(Font.system(size: 26))
//        .padding([.trailing,.leading], 0)
//        .padding([.bottom], 5)
    }
}



#Preview {
    ContentView().environmentObject(AppData()).environmentObject(UserStore())
}
