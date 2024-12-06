//
//  RegisterView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

/// Defines the layout of items in the 'RegisterView'.
struct RegisterView: View {
    @StateObject var viewModel = RegisterViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            // Header
            HeaderView(title: "Register", subtitle: "", angle: -15, background: .orange)
            
            Form {
                // Displays error message to user
                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundColor(Color.red)
                }
                
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                // Create account button
                SPButton(
                    title: "Create Account",
                    background: .green
                ) {
                    // Attemp Registration
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            print("DEBUG: COULDNT SIGN UP, \(error)")
                        }
                    }
                }
            }
            .offset(y: -50)
            
            Spacer()
        }
    }
}
