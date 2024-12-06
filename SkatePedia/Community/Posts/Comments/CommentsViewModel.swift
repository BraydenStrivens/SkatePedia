//
//  CommentsViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/28/24.
//

import Foundation
import FirebaseFirestore

/// Defines a class that contains functions for fetching and uploading data about comments.
@MainActor
final class CommentsViewModel: ObservableObject {
    
    @Published var comment: String = ""
    @Published private(set) var comments: [Comment] = []
    
    private var lastDocument: DocumentSnapshot? = nil
    
    /// Fetches the comments associated with a post as comment objects and stores these objects in an array.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to get the comments from.
    func getComments(postId: String) {
        
        Task {
            let (newComments, lastDocument) = try await PostManager.shared
                .getComments(postId: postId,
                             count: 10,
                             lastDocument: lastDocument)
            
            self.comments.append(contentsOf: newComments)
            
            if let lastDocument {
                self.lastDocument = lastDocument
            }
        }
    }

    /// Adds a comment to a given post.
    ///
    /// > Warning: The post id is within the comment object.
    ///
    /// - Parameters: A 'Comment' object containing the information to be stored in the database.
    func addComment(comment: Comment) async throws {
        try await PostManager.shared.addComment(comment: comment)
    }
    
    /// Gets the username associated of the account that posted the comment.
    ///
    /// > Warning: The id of this account is contained in the 'comment' object.
    ///
    /// - Parameters:
    ///  - userId: The id of the account that posted the comment.
    func getCommenterUsername(userId: String) -> String {
        var username = "not found"
        
        Task {
            username = try await UserManager.shared.getUsername(userId: userId)
        }
        
        return username
    }
}
