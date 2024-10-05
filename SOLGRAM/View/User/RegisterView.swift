//
//  RegisterView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 8/30/24.
//

import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var email: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    
    // Validation functions
    var isUsernameValid: Bool {
        return name.count >= 4
    }
    
    var isPasswordLengthValid: Bool {
            return password.count >= 8
    }
    
    var isPasswordUppercaseValid: Bool {
        return password.range(of: "[A-Z]", options: .regularExpression) != nil
    }
    
    var isConfirmPasswordValid: Bool {
        return confirmPassword != "" && confirmPassword == password
    }
    
    var isEmailValid: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    var body: some View {
        VStack {
            Text("Create an account")
                .font(.custom("TrebuchetMS-Bold", fixedSize: 28))
                .padding(10)
//            Spacer()
            HStack {
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    // Username Field
                    TextField("Login", text: $name)
                        .background(Color.white)
                    Divider()
                    HStack(spacing: 3) {
                        Image(systemName: isUsernameValid ? "checkmark.square" : "xmark.app")
                            .scaleEffect(0.8)
                        Text("A minimum of 4 characters")
                            .font(.caption2)
                        
                        Spacer()
                    }
                    .foregroundColor(isUsernameValid ? .green : .red)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .background(Color.white)
                    Divider()
                    VStack(alignment: .leading) {
                        HStack(spacing: 3) {
                            Image(systemName: isPasswordLengthValid ? "checkmark.square" : "xmark.app")
                                .scaleEffect(0.8)
                            Text("A minimum of 8 characters")
                                .font(.caption2)
                            Spacer()
                        }
                        .foregroundColor(isPasswordLengthValid ? .green : .red)
                        
                        HStack(spacing: 3) {
                            Image(systemName: isPasswordUppercaseValid ? "checkmark.square" : "xmark.app")
                                .scaleEffect(0.8)
                            Text("One uppercase letter")
                                .font(.caption2)
                            Spacer()
                        }
                        .foregroundColor(isPasswordUppercaseValid ? .green : .red)
                    }
                    
                    // Confirm Password Field
                    SecureField("Confirm password", text: $confirmPassword)
                        .background(Color.white)
                    Divider()
                    VStack(alignment: .leading) {
                        HStack(spacing: 3) {
                            Image(systemName: isConfirmPasswordValid ? "checkmark.square" : "xmark.app")
                                .scaleEffect(0.8)
                            Text("Confirm password should be same as password")
                                .font(.caption2)
                            Spacer()
                        }
                        .foregroundColor(isConfirmPasswordValid ? .green : .red)
                    }
                    
                    // Email Field
                    TextField("Email", text: $email)
                        .background(Color.white)
                    Divider()
                    VStack(alignment: .leading) {
                        HStack(spacing: 3) {
                            Image(systemName: isEmailValid ? "checkmark.square" : "xmark.app")
                                .scaleEffect(0.7)
                            Text("Email should be valid")
                                .font(.caption2)
                            Spacer()
                        }
                        .foregroundColor(isEmailValid ? .green : .red)
                    }
                    
                    TextField("First name", text: $firstName)
                        .background(Color.white)
                    Divider()
                    VStack(alignment: .leading) {
                        HStack(spacing: 3) {
//                            Image(systemName: isEmailValid ? "checkmark.square" : "xmark.app")
//                                .scaleEffect(0.7)
//                            Text("Email should be valid")
//                                .font(.caption2)
                            Spacer()
                        }
//                        .foregroundColor(isEmailValid ? .green : .red)
                    }
                    
                    TextField("Last name", text: $lastName)
                        .background(Color.white)
                    Divider()
                    VStack(alignment: .leading) {
                        HStack(spacing: 3) {
//                            Image(systemName: isEmailValid ? "checkmark.square" : "xmark.app")
//                                .scaleEffect(0.7)
//                            Text("Email should be valid")
//                                .font(.caption2)
                            Spacer()
                        }
//                        .foregroundColor(isEmailValid ? .green : .red)
                    }
                }
                
                Spacer()
            }
            .padding(20)
//            Spacer()
            
            // Register Button
            Button(action: {
                self.register()
            }, label: {
                Text("Sign Up")
                    .frame(width: 270)
                    .foregroundColor(.white)
                    .font(.custom("TrebuchetMS-Bold", fixedSize: 18))
            })
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .disabled(!isUsernameValid && !isPasswordLengthValid && !isConfirmPasswordValid && !isEmailValid)
            Spacer()
            HStack(spacing: 0){
                Text("Already have an account?")
                    .font(.custom("TrebuchetMS-Bold", fixedSize: 14))
                Text(" Sign In")
                    .font(.custom("TrebuchetMS-Bold", fixedSize: 14))
                    .foregroundColor(.blue) // Make clickable text blue or another color
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func register(){
        let registerInfo = RegisterInfo(username: self.name, email: self.email, password: self.password, first_name: self.firstName, last_name: self.lastName)
        
        userStore.register(registerInfo: registerInfo)
    }
}

#Preview {
    RegisterView().environmentObject(UserStore())
}
