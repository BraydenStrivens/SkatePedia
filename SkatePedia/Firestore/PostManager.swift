//
//  PostManager.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/4/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

/// Contains all functions for accessing and manipulating post documents in the database.
final class PostManager {
    
    // Allows access to this class' functions in other files
    static let shared = PostManager()
    private init() { }
    
    private var postListener: ListenerRegistration? = nil
    private let postCollection = Firestore.firestore().collection("posts")
    
    private func postDocument() -> DocumentReference {
        postCollection.document()
    }
    
    private func postCommentsCollection(postId: String) -> CollectionReference {
        postCollection.document(postId).collection("comments")
    }
    
    /// Adds listener to 'posts' collection. Allows for live updates when this collection is changed.
    func addUnfilteredListenerForPosts(count: Int, lastDocument: DocumentSnapshot?) -> AnyPublisher<[Post], Error> {
        let (publisher, listener) = postCollection
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
//            .limit(to: count)
//            .startOptionally(afterDocument: lastDocument)
            .addSnapshotListener(as: Post.self)
        
        self.postListener = listener
        return publisher
    }
    
    /// Adds a listener to fetch the user's posts from the database.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    func addFilteredListenerForPosts(userId: String, count: Int, lastDocument: DocumentSnapshot?) -> AnyPublisher<[Post], Error> {
        let (publisher, listener) = postCollection
            .whereField(Post.CodingKeys.userId.rawValue, isEqualTo: userId)
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
//            .limit(to: count)
//            .startOptionally(afterDocument: lastDocument)
            .addSnapshotListener(as: Post.self)
        
        self.postListener = listener
        return publisher
    }
    
    /// Adds a listener to fetch all posts from the database. Can filter posts to the user's post using the user's id.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user.
    ///  - filterUserOnly: Whether or not to filter the posts.
    func addListenerForPosts(userId: String, filterUserOnly: Bool, count: Int, lastDocument: DocumentSnapshot?) -> AnyPublisher<[Post], Error> {
        if filterUserOnly {
            addFilteredListenerForPosts(userId: userId, count: count, lastDocument: lastDocument)
        } else {
            addUnfilteredListenerForPosts(count: count, lastDocument: lastDocument)
        }
    }
    
    /// Removes the listener for posts.
    func removeListenerForPosts() {
        self.postListener?.remove()
    }
    
    /// Uploads the post to the database and its associated video to storage through the post manager class.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user in the database.
    ///  - postId: The id of the post in the database.
    func addPost(videoData: Data, post: Post) async throws {
        let document = postDocument()
        let documentId = document.documentID
        
        let videoUrl = try await StorageManager.shared.uploadPostVideo(videoData: videoData, postId: documentId)
        
        let data: [String: Any] = [
            Post.CodingKeys.id.rawValue : documentId,
            Post.CodingKeys.userId.rawValue : post.userId,
            Post.CodingKeys.trick.rawValue : post.trick,
            Post.CodingKeys.dateCreated.rawValue : post.dateCreated,
            Post.CodingKeys.notes.rawValue : post.notes,
            Post.CodingKeys.likes.rawValue : post.likes,
            Post.CodingKeys.videoUrl.rawValue : videoUrl ?? "No Video Url"
        ]
        
        try await document.setData(data, merge: false)
    }
    
    /// Queries for all the documents in the 'posts' collections.
    private func getAllPostsQuery() -> Query {
        postCollection
    }
    
    /// Queries for all the documents in the 'posts' collection that belong to a specific user.
    ///
    /// - Parameters:
    ///  - userId: The id of the account to filter posts.
    private func getAllCurrentUserPosts(userId: String) -> Query {
        postCollection
            .whereField(Post.CodingKeys.userId.rawValue, isEqualTo: userId)
    }
    
    /// Fetches 10 posts from the database starting at the last fetched post. Has the option to fetch only a specific user's posts.
    ///
    /// - Parameters:
    ///  - userId: The id of the account to filter posts.
    ///  - count: The maximum number of posts to fetch.
    ///  - filterUserOnly: Whether to only fetch the user's posts.
    ///  - lastDocument: The last fetched post.
    ///
    /// - Returns: A tuple containing an array of the fetched posts and the last fetched post.
    func getAllPosts(userId: String?, count: Int, filterUserOnly: Bool?, lastDocument: DocumentSnapshot?) async throws -> (item: [Post], lastDocument: DocumentSnapshot?) {
        
        var query: Query = getAllPostsQuery()
        
        if let userId {
            query = getAllCurrentUserPosts(userId: userId)
        }
        
        return try await query
            .order(by: Post.CodingKeys.dateCreated.rawValue, descending: true)
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
    }
    
    /// Fetches all the posts from a specific user and encodes then into 'Post' objects.
    ///
    /// - Parameters:
    ///  - userId: The id of the account to filter posts.
    ///
    /// - Returns: An array containing the fetched posts.
    func getAllUserPosts(userId: String) async throws -> [Post] {
        return try await getAllCurrentUserPosts(userId: userId)
            .getDocuments(as: Post.self)
    }
    
    /// Deletes a post from the database.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to delete.
    func deletePost(postId: String) {
        Task {
            try await StorageManager.shared.deletePostVideo(postId: postId)
        }
        
        postCollection.whereField("post_id", isEqualTo: postId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("ERROR GETTING DOCUMENTS: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    /// Increments the like count of a post.
    ///
    /// > Warning: Does not limit the number of times a user can like a post.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to increment its 'likes' field.
    func addLike(postId: String) {
        let postDocument = postCollection.document(postId)
        
        postDocument.updateData([
            Post.CodingKeys.likes.rawValue : FieldValue.increment(Int64(1))
        ])
    }
    
    /// Gets the number of likes of the post. Stores this value in local variable.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to get it's like count.
    func getPostLikeCount(postId: String) async throws -> Int {
        var likes: Int = 0
        
        likes = try await postCollection.document(postId).getDocument().get(Post.CodingKeys.likes.rawValue) as! Int
        
        return likes
    }
    
    /// Fetches 10 comments starting from the last fetched comment from the database.
    ///
    /// - Parameters:
    ///  - postId: The id of the post to get comments from.
    ///  - count: The maximum number of comments to fetch.
    ///  - lastDocument: The last fetched comment.
    ///
    /// - Returns: A tuple containing an array of the fetched posts and the last fetched post.
    func getComments(postId: String, count: Int, lastDocument: DocumentSnapshot?) async throws -> (item: [Comment], lastDocument: DocumentSnapshot?) {
        
        let query: Query = postCommentsCollection(postId: postId)
            .order(by: Comment.CodingKeys.dateCreated.rawValue, descending: true)
            
        
        return try await query
            .limit(to: count)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Comment.self)
    }
    
    /// Adds a comment to a post.
    ///
    /// - Parameters:
    ///  - comment: A 'Comment' object containing information about the comment.
    func addComment(comment: Comment) async throws {
        let document = postCollection.document(comment.postId).collection("comments").document()
        let documentId = document.documentID
        
        let data: [String: Any] = [
            Comment.CodingKeys.id.rawValue : documentId,
            Comment.CodingKeys.postId.rawValue : comment.postId,
            Comment.CodingKeys.fromUserId.rawValue : comment.fromUserId,
            Comment.CodingKeys.content.rawValue : comment.content,
            Comment.CodingKeys.dateCreated.rawValue : comment.dateCreated
        ]
        
        try await document.setData(data, merge: false)
        
        print("DEBUG: COMMENT SUCCESSFULLY ADDED TO POST")
    }
    
    /// Gets the number of comments for a post. Stores this value in a local variable
    ///
    /// - Parameters:
    ///  - postId: The id of the post to get it's comment count.
    ///
    /// - Returns: The number of comments on a post as an 'Integer'.
    func getPostCommentsCount(postId: String) async throws -> Int {
        let numberOfComments = try await postCollection.document(postId).collection("comments").aggregateCount()
        
        return numberOfComments
    }
}
