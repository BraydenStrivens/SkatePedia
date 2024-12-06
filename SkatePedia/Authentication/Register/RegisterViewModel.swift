//
//  RegisterViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

/// Defines a class that contains functions for registering new users to the database.
@MainActor
final class RegisterViewModel: ObservableObject {
    
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    init() { }
    
    /// Validates the user information and creates a firebase user
    func signUp() async throws {
        guard validate() else {
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(
            email: email,
            password: password) 
        
        let user = DBUser(auth: authDataResult, username: username, dateCreated: Date())
        
        try await UserManager.shared.createNewUser(user: user)
    }
    
    /// Validates the register view text fields aren't empty,
    /// also verifies the email contains '@' and '.' characters,
    /// also verifies the password is at least 6 characters long.
    ///
    /// - Returns: whether or not the inputted account information meets the required critera
    private func validate() -> Bool {
        errorMessage = ""
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Not a valid email address."
            return false
        }
        
        guard password.count >= 6 else {
            errorMessage = "Password must be at least six characters."
            return false
        }
        
        return true
    }
}
