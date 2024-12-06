//
//  CommunityViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

/// Defines a class that contains functions for the 'CommunityView'.
@MainActor
final class CommunityViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var posts: [Post] = []
    
    @Published private var cancellables = Set<AnyCancellable>()
    
    @Published var filterOptions: [String] = ["All Posts", "My Posts"]
    @Published var selectedFilter: String = "All Posts"
    
    @Published var filterUserOnly = false
    
    private var lastDocument: DocumentSnapshot? = nil
    
    init() {
        Task {
            try? await loadCurrentUser()
        }
    }
    
    /// Fetches information about the current user and stores it in a local variable
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    /// Toggles the filterUserOnly variable which controls which posts are displayed.
    func toggleFilterUserOnly() {
        filterUserOnly.toggle()
        
        if selectedFilter == filterOptions[0] {
            selectedFilter = filterOptions[1]
        } else {
            selectedFilter = filterOptions[0]
        }
        self.posts = []
        self.addListenerForPosts(userId: user!.userId,
                                 filterUserOnly: filterUserOnly)
    }
    
    /// Adds a listener to fetch posts from the database. Can filter posts to the user's post using the user's id.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - filterUserOnly: Whether or not to filter the posts.
    func addListenerForPosts(userId: String, filterUserOnly: Bool) {
        PostManager.shared.addListenerForPosts(userId: userId,
                                               filterUserOnly: filterUserOnly,
                                               count: 10,
                                               lastDocument: lastDocument)
            .sink { completion in
                
            } receiveValue: { [weak self] post in
                self?.posts = post
            }
            .store(in: &cancellables)
    }
    
    /// Fetches 10 posts starting from the last fetched document from the database. Saves the fetched posts in a local variable.
    func getPosts() {
        Task {
            if let user {
                let (newPosts, lastDocument) = try await PostManager
                    .shared.getAllPosts(userId: user.userId,
                                        count: 10,
                                        filterUserOnly: filterUserOnly,
                                        lastDocument: lastDocument)
                
                self.posts.append(contentsOf: newPosts)
                
                if let lastDocument {
                    self.lastDocument = lastDocument
                }
            }
        }
    }
}
