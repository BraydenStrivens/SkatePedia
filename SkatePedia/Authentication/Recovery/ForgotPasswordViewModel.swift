//
//  ForgotPasswordViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation
import Firebase

@MainActor
final class ForgotPasswordViewModel: ObservableObject {
    
    @Published var email: String = ""
    
    func resetPassword() {
        Task {
            try await AuthenticationManager.shared.resetPassword(email: email)
        }
    }
}
