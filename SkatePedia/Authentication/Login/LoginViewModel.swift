//
//  LoginViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation

/// Defines a class that contains functions for logging in a user to the app.
@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init() { }
    
    /// Signs in and validates the user with the inputted email and password.
    func signIn() async throws {
        guard validate() else {
            return
        }
        
        let _ = try await AuthenticationManager.shared.signInUser(
            email: email,
            password: password)
    }
    
    /// Resets the users password
    ///
    /// - Parameters:
    ///     - email: The email connected to the account.
    func resetPassword(email: String) async throws {
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    /// Validates that the email and password textfields are not empty,
    /// also verifies the email contains both '@' and '.' symbols.
    ///
    /// - Returns: whether or not both the email and password textfields contain characters.
    private func validate() -> Bool {
        errorMessage = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
                !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter valid email."
            return false
        }
        
        return true
    }
}
