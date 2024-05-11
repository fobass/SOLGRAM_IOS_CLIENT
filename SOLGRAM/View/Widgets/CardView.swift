//
//  CardView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import SwiftUI
import SwiftUICharts


struct CardView: View {
//    @ObservedObject var items = InstrumentStore()
    var body: some View {
        VStack{
            HStack{
                Text("BTC/USDT")
                    .foregroundColor(.orange)
                Text("+222%")
                    .foregroundColor(.green)
            }
            Spacer()
            HStack{
                Text("323,454,65")
                    .foregroundColor(.green)
                
            }
            Spacer()
        }
        .font(Font.system(size: 13))
    
    }
}

#Preview("Article List View", traits: .fixedLayout(width: 130, height: 50)) {
    CardView()
}

struct Tab {
    var icon: Image?
    var title: String
}
struct Tabs: View {
    var fixed = true
    var tabs: [Tab]
    var geoWidth: CGFloat
    @Binding var selectedTab: Int
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        ForEach(0 ..< tabs.count, id: \.self) { row in
                            Button(action: {
                                withAnimation {
                                    selectedTab = row
                                }
                            }, label: {
                                VStack(spacing: 0) {
                                    HStack {
                                        // Image
//                                        AnyView(tabs[row].icon)
//                                            .foregroundColor(.white)
//                                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 0))
                                        // Text
                                        Text(tabs[row].title)
                                            .font(Font.system(size: 12, weight: .semibold))
//                                            .foregroundColor(Color.white)
                                            .padding(EdgeInsets(top: 10, leading: 3, bottom: 10, trailing: 15))
                                    }
                                    .frame(width: fixed ? (geoWidth / CGFloat(tabs.count)) : .none, height: 2 )
                                    // Bar Indicator
                                    Rectangle().fill(selectedTab == row ? Color.orange : Color.clear)
                                        .frame(height: 3)
                                }
                                .fixedSize()
//                                .background(.blue)
                            })
                                .accentColor(Color.white)
                                .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .onChange(of: selectedTab) { target in
                        withAnimation {
                            proxy.scrollTo(target)
                        }
                    }
                }
            }
        }
        .frame(height: 25)
        .onAppear(perform: {
//            UIScrollView.appearance().backgroundColor = UIColor(#colorLiteral(red: 0.6196078431, green: 0.1098039216, blue: 0.2509803922, alpha: 1))
            UIScrollView.appearance().bounces = fixed ? false : true
        })
        .onDisappear(perform: {
            UIScrollView.appearance().bounces = true
        })
    }
}

struct ContentTabView: View {
    @State private var selectedTab: Int = 0

        let tabs: [Tab] = [
            .init(icon: Image(systemName: "music.note"), title: "Music"),
            .init(icon: Image(systemName: "film.fill"), title: "Movies"),
            .init(icon: Image(systemName: "book.fill"), title: "Books")
        ]


        var body: some View {
            NavigationView {
                GeometryReader { geo in
                    VStack(spacing: 0) {
                        Tabs(tabs: tabs, geoWidth: geo.size.width, selectedTab: $selectedTab)
                        TabView(selection: $selectedTab,
                                content: {
//                            QuoteView(selectTradeTab: .constant(0))
//                                        .tag(0)
                                    CardView()
                                        .tag(1)
                                })
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
//                    .ignoresSafeArea()
                }
            }
        }
}

//
struct ContentTabView_Previews: PreviewProvider {
    static var previews: some View {
        ContentTabView()
    }
}
