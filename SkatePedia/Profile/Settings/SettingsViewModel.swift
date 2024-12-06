//
//  SettingsViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation

/// Defines a class that contains functions for the 'SettingsView'
@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published var errorMessage: String = ""
    
    /// Gets a 'DBUser' object of the current user and stores it in a local variable.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    /// Signs out the current user
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    /// Updates the password of the current user's account.
    ///
    /// - Parameters:
    ///  - password: The new password to update to the account.
    func updatePassword(password: String) async throws {
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    /// Deletes the user account from the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    func deleteUser(userId: String) async throws {
        // Deletes the users account
        try await AuthenticationManager.shared.deleteUser()
        // Deletes all the users data and videos 
        try await UserManager.shared.deleteUserData(userId: userId)
    }
}
