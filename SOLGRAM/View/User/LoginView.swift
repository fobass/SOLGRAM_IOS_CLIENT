//
//  LoginView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 9/5/24.
//

import SwiftUI

struct LoginView: View {
    @State private var name: String = ""
    @State private var password: String = ""
    @EnvironmentObject var userStore: UserStore
    var isUsernameValid: Bool {
        return name.count >= 4
    }
    
    var isPasswordLengthValid: Bool {
            return password.count >= 8
    }
    
    var isPasswordUppercaseValid: Bool {
        return password.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    
    /*SwiftUI how is work login view once user login and get access token for one hour and next time app run again login lounch page?*/
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                Text("SOLGRAM")
                    .font(.custom("TrebuchetMS-Bold", fixedSize: 70))
                    .fontWeight(.black)
                    .foregroundColor(Color(red: 68 / 255, green: 79 / 255, blue: 90 / 255))
                HStack{
                    Text(" trade instantly, anytime and anywhere ")
                        .font(.custom("TrebuchetMS", fixedSize: 14))
                        .fontWeight(.black)
                        .foregroundColor(Color(red: 255 / 255, green: 153 / 255, blue: 153 / 255))
                }
            }
            Spacer()

            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 10) {
                    TextField("Username", text: $name)
                        .background(Color.white)
                    Divider()
                    SecureField("Password", text: $password)
                        .background(Color.white)
                    Divider()
                }
                Spacer()
            }
            .padding(20)

            Button(action: {
                self.userStore.login(username: self.name, password: self.password)
            }, label: {
                Text("Login")
                    .frame(width: 270)
                    .foregroundColor(.blue)
                    .font(.custom("TrebuchetMS-Bold", fixedSize: 18))
            })
            .padding()
//            .background(Color.black)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 1))
//            .cornerRadius(5)
            .cornerRadius(10)
            .disabled(!isUsernameValid && !isPasswordLengthValid)
            Spacer()
            Spacer()
            HStack(spacing: 0){
                Text("Don't have an account?")
                    .font(.custom("TrebuchetMS-Bold", fixedSize: 14))
                NavigationLink(destination: RegisterView().environmentObject(userStore)) {
                    Text(" Create account")
                        .font(.custom("TrebuchetMS-Bold", fixedSize: 14))
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView().environmentObject(UserStore())
}
