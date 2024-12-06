//
//  ProfileViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation

/// Defines a class that contains functions for the current user.
@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    // Loads the current user
    init() {
        Task {
            try? await loadCurrentUser()
        }
    }
    
    /// Gets a 'DBUser' object for the current user. Saves this object in a local variable.
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
