//
//  UserAssetsInfo.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 9/6/24.
//

import SwiftUI

struct UserAssetsInfo: View {
    @EnvironmentObject var appData: AppData	
    @EnvironmentObject var userStore: UserStore
    var body: some View {
        
        
        VStack{
            VStack{
                HStack{
                    VStack(alignment: .leading){
                        Text("Total Balance")
                            .font(.custom("TrebuchetMS-Bold", size: 12))
                            .foregroundColor(Color.black.opacity(0.5))
                        Text("\(userStore.userBalance.total_balance)")
                    }
                    .padding([.top, .bottom], 5)
                    Spacer()
                    VStack {
                        Text(String(format: "%.2f%%", 333))
                            .padding(5)
                    }
                    .frame(width: 70)
                    .background(Color.green)
                    .cornerRadius(5)
                    .font(Font.system(size: 10))
                }
               
                Divider()
                Spacer()
                VStack{
                    HStack{
                        Button(action: {
                            userStore.deposite(userId: userStore.userInfo.user_id, amount: 12.0)
                        }, label: {
                            Image(systemName: "chevron.up.circle")
                                .font(Font.system(size: 14))
                            Text("Deposit")
                            Spacer()
                        })
                        
                        .foregroundColor(Color.green.opacity(0.7))
                        Divider()
                        Button(action: {
                            print("dd")
                        }, label: {
                            Spacer()
                            Image(systemName: "chevron.down.circle")
                                .font(Font.system(size: 14))
                            Text("Withdraw")
                        })
                        .foregroundColor(Color.red.opacity(0.7))
                    }
                    .font(.custom("TrebuchetMS-Bold", size: 12))
                }
                .padding(5)
            }
            .padding(15)
            }
            .background(Color.white.opacity(0.8))
            .cornerRadius(20)
            .padding(.bottom, 5)
            .shadow(color: Color.black.opacity(0.4),  radius: 1)
            .onAppear(){
//                userStore.getUserBalance(with: appData.userInfo.user_id)
            }
    }
}

#Preview {
    UserAssetsInfo().environmentObject(AppData()).environmentObject(UserStore())
}
