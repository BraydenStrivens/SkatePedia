//
//  TrickViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation
import Combine

/// Defines a class containing functions for fetching trick items from the database.
@MainActor
final class TrickViewModel: ObservableObject {
    
    @Published private(set) var trickItems: [TrickItem] = []
    @Published private var cancellables = Set<AnyCancellable>()
    
    @Published var alreadyFetched = false
    
    /// Adds a listener for the users trick items in the database. Allows for real time fetching of updates to the database.
    ///
    /// - Parameters:
    ///  - userId: The id of a user account in the database.
    ///  - trickId: The id of the trick which is used to filter the query results.
    func addListenerForTrickItems(userId: String, trickId: String) {
        UserManager.shared.addListenerForTrickItems(userId: userId, trickId: trickId)
            .sink { completion in
                
            } receiveValue: { [weak self] trickItem in
                self?.trickItems = trickItem
            }
            .store(in: &cancellables)
    }
    
    /// Gets the query used to fetch the trick items for a specific user and trick from the database.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickId: The id of the trick which is used to filter query results.
    func getTrickItems(userId: String, trickId: String) {
        Task {
            let trickItems = try await UserManager.shared.getTrickItems(userId: userId, trickId: trickId)
            
            self.trickItems.append(contentsOf: trickItems)
        }
        
        alreadyFetched = true
    }
}
