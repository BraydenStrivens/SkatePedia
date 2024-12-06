//
//  ForgotPasswordView.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @StateObject var viewModel = ForgotPasswordViewModel()
     
    var body: some View {
        VStack {
            Spacer()
            
            VStack(alignment: .leading) {
                TextField("Email Address", text: $viewModel.email)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.gray.opacity(0.3))
                    .stroke(Color.gray.opacity(0.6))
            }
            

            HStack(alignment: .center) {
                SPButton(title: "Send Verification Email", background: .green) {
                    viewModel.resetPassword()
                }
                .frame(height: 75)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Reset Password")
    }
}

#Preview {
    ForgotPasswordView()
}
