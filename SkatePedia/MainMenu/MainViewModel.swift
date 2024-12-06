//
//  MainViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation
import FirebaseAuth

/// Defines a class that contains functions for the 'MainMenuView'.
@MainActor
final class MainViewModel: ObservableObject {
    
    @Published var currentUserId: String = ""
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    init() {
        // Detects if user is logged in
        self.handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }
    
    /// Checks if the user is currently signed in on their device.
    ///
    /// - Returns: Whether or not there is a current user signed in.
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil
    }
}
