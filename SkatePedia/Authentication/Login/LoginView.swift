//
//  LoginView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines the layout of items in the 'LoginView'.
struct LoginView: View {
    
    @StateObject var viewModel = LoginViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            // Header
            HeaderView(title: "SkatePedia", subtitle: "Make Learning Tricks Easier", angle: 15, background: .yellow)
            
            // Login Form
            Form {
                // Displays error message to user
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                // Login button
                SPButton(
                    title: "Login",
                    background: .green
                ) {
                    // Attempt Login
                    Task {
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                            return
                        } catch {
                            viewModel.errorMessage = "Invalid Credentials"
                            print("DEBUG: Couldn't sign in ,\(error)")
                        }
                    }
                }
            }
        
            // Create Account and reset password links
            VStack {
                // Forgot password
                NavigationLink(
                    "Forgot Password",
                    destination: ForgotPasswordView()
                )
                
                // Create an account link
                NavigationLink(
                    "Create An Account",
                    destination: RegisterView(showSignInView: .constant(false))
                )
            }
            .padding(.bottom, 50)
            Spacer()
        }
    }
}
