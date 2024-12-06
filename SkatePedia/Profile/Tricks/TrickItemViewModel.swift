//
//  TrickItemViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 12/4/24.
//

import Foundation

/// Defines a class that contains functions for updating a user's trick items.
@MainActor
final class TrickItemViewModel: ObservableObject {
    
    @Published var newNotes: String = ""
    
    /// Updates the 'notes' field in the specified trick item in the database.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickItem: A 'TrickItem' object containing information about the trick item.
    func updateTrickItemNotes(userId: String, trickItem: TrickItem) {
        if !newNotes.trimmingCharacters(in: .whitespaces).isEmpty &&
            newNotes != trickItem.notes {
            Task {
                try await UserManager.shared.updateTrickItemNotes(
                    userId: userId,
                    trickItemId: trickItem.id,
                    newNotes: newNotes)
            }
        }
    }
}
