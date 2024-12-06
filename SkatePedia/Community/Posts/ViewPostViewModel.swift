//
//  ViewPostViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import AVKit

/// Defines a class that contains functions for fetching data to be displayed for each post.
@MainActor
final class ViewPostViewModel: ObservableObject {
    
    @Published var postUsername: String = "N/A"
    @Published var numberOfLikes: Int = 0
    @Published var numberOfComments: Int = 0
    
    /// Gets the username of the account with the associated user id.
    ///
    /// - Parameters:
    ///  - userId: The user id of an account in the database.
    ///
    /// - Returns: The accounts username as a string.
    func getUsername(userId: String) async throws -> String {
        guard let postAuthor = try? await UserManager.shared.getUser(userId: userId) else {
            print("DEBUG: COULDNT GET USERNAME")
            return "N/A"
        }
        
        return postAuthor.username ?? "N/A2"
    }
    
    /// Deletes a post from the database.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to delete.
    func deletePost(postId: String) {
        PostManager.shared.deletePost(postId: postId)
    }
    
    /// Increments the like count of a post.
    ///
    /// > Warning: Does not limit the number of times a user can like a post.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to increment its 'likes' field.
    func addLike(postId: String) {
        PostManager.shared.addLike(postId: postId)
        
        Task {
            try await getNumberOfLikes(postId: postId)
        }
    }
    
    /// Gets the number of likes of the post. Stores this value in local variable.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to get it's like count.
    func getNumberOfLikes(postId: String) async throws {
        guard let numLikes = try? await PostManager.shared.getPostLikeCount(postId: postId) else {
            print("DEBUG: COULDNT GET LIKE COUNT")
            return
        }
        
        self.numberOfLikes = numLikes
    }
    
    /// Adds a comment to a post.
    ///
    /// - Parameters:
    ///  - comment: A 'Comment' object containing information about the comment.
    func addComment(comment: Comment) {
        Task {
            try? await PostManager.shared.addComment(comment: comment)
            try await getNumberOfComments(postId: comment.postId)
        }
    }
    
    /// Gets the number of comments for a post. Stores this value in a local variable
    ///
    /// - Parameters:
    ///  - postId: The id of the post to get it's comment count.
    func getNumberOfComments(postId: String) async throws {
        guard let numComments = try? await PostManager.shared.getPostCommentsCount(postId: postId) else {
            print("DEBUG: COULDNT GET COMMENT COUNT")
            return
        }
        
        self.numberOfComments = numComments
    }
}
