//
//  RegisterView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 8/30/24.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var userStore: UserStore
    var body: some View {
        NavigationView{
            ZStack{
                Image("bg")
                VStack{
                    Spacer()
                    Text("Welcome to SOLGRAM")
                        .foregroundColor(.white)
                        .font(.custom("TrebuchetMS-Bold", fixedSize: 28))
                    Spacer()
                    Button(action: {
                        //appData.showLoginView = true
                    }) {
                        NavigationLink(destination: LoginView().environmentObject(userStore)) {
                            Text("Log In")
                        }
                        
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    WelcomeView().environmentObject(UserStore())
}
