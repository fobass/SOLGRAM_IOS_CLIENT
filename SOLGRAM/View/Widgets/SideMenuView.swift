//
//  SideBar.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/29/24.
//

import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var instrumentStore: InstrumentStore
    @Binding var selectedSideMenuTab: Int
    @Binding var presentSideMenu: Bool
    @State private var selection: Int = 0
    var body: some View {
        HStack {
            ZStack{
                Rectangle()
                    .fill(.white)
                    .frame(width: 300)
                    .shadow(color: .purple.opacity(0.1), radius: 5, x: 0, y: 3)
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack{
                        Text("Spot")
                        Spacer()
                    }
                    .padding(10)
                    
                    ScrollSlidingTabBar(selection: $selection,tabs: ["Favorites", "USD", "BRC20", "DePIN", "Vol 24"])
                    
                    TabView(selection: $selection) {
                        ScrollView{
                            VStack{
                                Divider()
                                HStack{
                                    Text("Pair")
                                    Spacer()
                                    Text("Price/Change")
                                }
                                .font(Font.system(size: 10))
                                .padding([.leading,.trailing], 10)
                                .padding([.top], 5)
                                ForEach($instrumentStore.items, id: \.id) { $item in
                                    HStack{
                                        Text(item.code)
                                            .font(.callout)
                                        
                                            .font(Font.system(size: 16))
                                        Spacer()
                                        VStack(alignment: .trailing) {
                                            Text("\(item.last_price)")
                                                .font(.subheadline)
                                                .foregroundColor(item.last_price > item.prev_price ? Color.green : Color.red)
                                            Text(String(format: "%.2f%%", item.change))
                                                .font(Font.system(size: 9))
                                        }
                                        
                                    }
                                    
                                    Divider()
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding([.leading,.trailing], 10)
                                Spacer()
                                
                            }
                        }.tag(0)
                        
                        
                        
                        
                        Spacer()
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.default, value: selection)
                   
                    Spacer()
                }
                
                .padding(.top, 60)
                .frame(width: 300)
                .background(Color.white)
                Spacer()
            }
            Spacer()
        }
    }

}


#Preview{
    SideMenuView(selectedSideMenuTab: .constant(1), presentSideMenu: .constant(true)).environmentObject(InstrumentStore())
}
