//
//  PortfolioView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 9/21/24.
//

import SwiftUI

struct PortfolioView: View {
    let buttonWidth: CGFloat = 80 // Set a fixed width for the buttons
    let buttonHeight: CGFloat = 50  // Set a fixed height for the buttons
    @EnvironmentObject var instrumentStore: InstrumentStore
    @Environment(\.colorScheme) var colorScheme
//    @Binding var selection: Int
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            VStack(spacing: 20){
                VStack{
                    HStack{
                        VStack(alignment: .leading){
                            Text("$12123.000")
                                .font(.title)
                            Text("Total Account Value")
                                .font(.footnote)
                        }
                        Spacer()
                        Button(action: {}) {
                            VStack {
                                Image(systemName: "eye")
                                    .font(Font.system(size: 13))
                            }
//                            .frame(maxHeight: buttonHeight)
                        }
                    }
                    Spacer(minLength: 20)
                    Divider()
                    
                    HStack(alignment: .center){
                        VStack{
                            Text("-344")
                                .font(.subheadline)
                            Text("(-4%)")
                                .font(.footnote)
                            Text("Monthly Gain")
                                .font(.footnote)
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack{
                            Text("-344")
                                .font(.subheadline)
                            Text("(-4%)")
                                .font(.footnote)
                            Text("Yearly Gain")
                                .font(.footnote)
                        }
                        Spacer()
                        Divider()
                        Spacer()
                        VStack{
                            Text("-344")
                                .font(.subheadline)
                            Text("(-4%)")
                                .font(.footnote)
                            Text("Total Gain")
                                .font(.footnote)
                        }
                        
                    }
                    .frame(height: 60)
//                    Spacer()
                    Divider()
                }
                HStack(alignment: .center){
//                    Spacer()
                    GeometryReader { geometry in
                        let buttonWidth = geometry.size.width / 4.4 // Dynamically divide width by the number of buttons
                        
                        HStack(spacing: 10) {
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image(systemName: "arrow.down")
                                    Text("Deposit")
                                        .font(.caption)
                                }
                                .frame(maxHeight: buttonHeight) // Max height for all buttons
                                //                            .padding(5)
                            }
                            .frame(width: buttonWidth)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))
                            .cornerRadius(5)
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "arrow.up")
                                    Text("Withdrawal")
                                        .font(.caption)
                                }
                                .frame(maxHeight: buttonHeight) // Max height for all buttons
                                //                            .padding(5)
                            }
                            .frame(width: buttonWidth) // Set dynamic width
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))
                            .cornerRadius(5)
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("Transfer")
                                        .font(.caption)
                                }
                                .frame(maxHeight: buttonHeight) // Max height for all buttons
                                //                            .padding(5)
                            }
                            .frame(width: buttonWidth) // Set dynamic width
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))
                            .cornerRadius(5)
                            
                            Button(action: {}) {
                                VStack {
                                    Image(systemName: "repeat.circle")
                                    Text("Earn")
                                        .font(.caption)
                                }
                                .frame(maxHeight: .infinity) // Max height for all buttons
                                //                            .padding(3)
                            }
                            .frame(width: buttonWidth) // Set dynamic width
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.blue, lineWidth: 1))
                            .cornerRadius(5)
                        }
                        .frame(height: buttonHeight)
                        .shadow(color: Color.gray.opacity(0.2), radius: 2)
                    }
                    
                }
                HStack{
                    Text("Assets")
                        .font(.custom("TrebuchetMS-Bold", size: 12))
                        .foregroundColor(Color.black.opacity(0.5))
                    Spacer()
                }
                .padding(.top, 40)
                
                VStack{
                    Spacer()
                    ForEach($instrumentStore.items, id: \.id) { $item in
                        VStack(alignment: .leading){
                            HStack{
                                Image(systemName: "person.circle")
//                                    .font(Font.system(size: 16))
                                            .padding([.leading], 0)
                                Text(item.code)
                                    .font(Font.system(size: 12))
                            }
                            .padding(2)
                            
                            HStack{
                                VStack(alignment: .leading, spacing: 5){
                                    Text("Total")
                                        .font(Font.system(size: 10))
                                    Text("23")
                                        .font(Font.system(size: 14))
                                    Text("$334")
                                        .font(Font.system(size: 9))
                                }
                                .padding([.leading], 5)
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 5){
                                    Text("Available")
                                        .font(Font.system(size: 10))
                                    Text("23")
                                        .font(Font.system(size: 12))
                                    Text("$334")
                                        .font(Font.system(size: 9))
                                }
//                                .padding(5)
                                Spacer()
                                VStack(alignment: .leading, spacing: 5){
                                    Text("In Orders")
                                        .font(Font.system(size: 10))
                                    Text("23")
                                        .font(Font.system(size: 12))
                                    Text("$334")
                                        .font(Font.system(size: 9))
                                }
                                .padding([.trailing], 5)
//                                .padding(5)
                                
                            }
                            
                        }
                        .padding(2)
                        Divider()
//                            .background(Color.gray.opacity(0.4))
                    }
                }
                .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.05))
                .cornerRadius(10)
                .padding(.bottom, 5)
                .shadow(color: Color.gray.opacity(0.4),  radius: 3)
                
            }
//            .padding([.trailing, .leading], 20)
            
            
        }
    }

}


#Preview {
    PortfolioView().environmentObject(InstrumentStore())
}
