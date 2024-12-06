//
//  AuthenticationManager.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/4/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

/// An object containing data about an account in the database
///
/// - Parameters:
///  - uid: The id of an account in the database.
///  - email: The email linked to an account in a database.
struct AuthDataResultModel {
    
    let uid: String
    let email: String?
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
    }
}

/// Defines a class that contains functions for creating, updating, and deleting user accounts in the database.
final class AuthenticationManager {
    
    // Allows access to all methods contained in this class
    static let shared = AuthenticationManager()
    
    private init() { }
    
    /// Gets the currently logged in user from firebase.
    ///
    /// - Returns: An object containing the user's id and email.
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        return AuthDataResultModel(user: user)
    }
    
    /// Creates a user within the database.
    ///
    /// - Parameters:
    ///     - email: An email to link to the account.
    ///     - password: A password to log into the account.
    ///
    /// - Returns: An object containing the user's id and email
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /// Signs in the user and gets an object containing user information.
    ///
    /// - Parameters:
    ///     - email: The email linked to an account.
    ///     - password: The password linked to an account.
    ///
    /// - Returns: An object containing the user's id and email.
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    /// Resets the password of the account with the given email.
    ///
    /// - Parameters: The email of the account to reset.
    func resetPassword(email: String) async throws {
        
        let _ = try await Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                let errorMessage = Text(error.localizedDescription)
                let _ = Alert(title: Text("Error Resetting Password"), message: errorMessage)
                return
            }
        }
    }
    
    /// Changes the password of the current user
    ///
    /// - Parameters:
    ///     - password: The new password to give to the current user
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    /// Signs out the current user
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    /// Deletes the current user
    ///
    /// > Warning: Does not delete user information within the database and storage.
    func deleteUser() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
            
        }
        
        try await user.delete()
    }
}
