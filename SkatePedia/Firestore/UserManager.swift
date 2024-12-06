//
//  UserManager.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/4/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

/// Defines a class that contains functions for fetching and updating data pertaining to a user in the database.
final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let trickObjectModel = Bundle.main.decode([JsonMenuItem].self, from: "TrickList.json")
    private let userCollection = Firestore.firestore().collection("users")
    
    private var trickItemUpdatedListener: ListenerRegistration? = nil
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    /// Fetches the username of the account with the associated id.
    ///
    /// - Parameters:
    ///  - userId: The id of a user account in the database.
    ///
    /// - Returns: The accounts username as a string.
    func getUsername(userId: String) async throws -> String {
        let givenUser = try await getUser(userId: userId)
        
        return givenUser.username!
    }
    
    /// Adds a listener for the users trick items in the database. Allows for real time fetching of updates to the database.
    ///
    /// - Parameters:
    ///  - userId: The id of a user account in the database.
    ///  - trickId: The id of the trick which is used to filter the query results.
    ///
    /// - Returns:
    func addListenerForTrickItems(userId: String, trickId: String) -> AnyPublisher<[TrickItem], Error> {
        let (publisher, listener) = userDocument(userId: userId).collection("trick_items")
            .whereField(TrickItem.CodingKeys.trickId.rawValue, isEqualTo: trickId)
            .order(by: TrickItem.CodingKeys.dateCreated.rawValue, descending: true)
            .addSnapshotListener(as: TrickItem.self)
        
        self.trickItemUpdatedListener = listener
        
        return publisher
    }
    
    /// Removes the database listener for trick items.
    func removeListenerForTrickItems() {
        self.trickItemUpdatedListener?.remove()
    }
    
    /// Gets the query used to fetch the trick items for a specific user and trick from the database.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickId: The id of the trick which is used to filter query results.
    ///
    /// - Returns: A 'Query' object used to fetch the trick items.
    private func getTrickItems(userId: String, trickId: String) -> Query {
        userDocument(userId: userId).collection("trick_items")
            .whereField(TrickItem.CodingKeys.trickId.rawValue, isEqualTo: trickId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        
        return decoder
    }()
    
    /// Writes new user data to the database.
    ///
    /// - Parameters:
    ///  - user: An object containing information about an account.
    func createNewUser(user: DBUser) async throws {
        try await userDocument(userId: user.userId).setData(user.asDictionary())
    }
    
    /// Fetches a user from the database and encodes the data into a 'DBUser' object.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///
    /// - Returns: A 'DBUser' containing information about an account.
    func getUser(userId: String) async throws -> DBUser {
        let snapshot = try await userDocument(userId: userId).getDocument()
        
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let email = data["email"] as? String
        let username = data["username"] as? String
        let dateCreated = data["date_created"] as? Date
        
        return DBUser(userId: userId,
                      username: username,
                      email: email,
                      dateCreated: dateCreated)
    }
    
    /// Deletes all data for a user from the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    func deleteUserData(userId: String) async throws {
        // Deletes user trick items from database and storage
        do {
            let userTrickItems: [TrickItem] = try await getAllUserTrickItems(userId: userId)
            
            if !userTrickItems.isEmpty {
                for item in userTrickItems {
                    try await deleteTrickItem(userId: userId, trickItemId: item.id)
                }
            }
        } catch {
            print("DEBUG: COULDNT GET TRICK ITEMS TO DELETE, \(error.localizedDescription)")
        }
        
        // Deletes user posts from database and storage
        do {
            let userPosts: [Post] = try await PostManager.shared.getAllUserPosts(userId: userId)
            
            if !userPosts.isEmpty {
                for item in userPosts {
                    PostManager.shared.deletePost(postId: item.id)
                }
            }
        } catch {
            print("DEBUG: COULDNT GET USER'S POSTS TO DELETE")
        }
        
        // Deletes the user from the 'users' collection in the database
        do {
            try await userDocument(userId: userId).delete()
        } catch {
            print("DEBUG: COULDNT DELETE USER FROM DATABASE")
        }
    }
    
    /// Uploads a trick item to the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - videoData: Data about the video associated with a trick item.
    ///  - trickItem: An object containing information about a trick item.
    func addTrickItem(userId: String, videoData: Data, trickItem: TrickItem) async throws {
        
        let document = userDocument(userId: userId).collection("trick_items").document()
        let documentId = document.documentID
        
        let videoUrl = try await StorageManager.shared.uploadTrickItemVideo(videoData: videoData, trickItemId: documentId)
        
        let data: [String: Any] = [
            TrickItem.CodingKeys.id.rawValue : documentId,
            TrickItem.CodingKeys.trickId.rawValue : trickItem.trickId ?? "No TrickID",
            TrickItem.CodingKeys.trickName.rawValue : trickItem.trickName ?? "No Name",
            TrickItem.CodingKeys.dateCreated.rawValue : trickItem.dateCreated ?? Date(),
            TrickItem.CodingKeys.notes.rawValue : trickItem.notes ?? "No Notes",
            TrickItem.CodingKeys.progress.rawValue : trickItem.progress ?? 0,
            TrickItem.CodingKeys.videoUrl.rawValue : videoUrl ?? "No Video Url"
        ]
        
        try await document.setData(data, merge: false)
        
        print("DEBUG: VIDEO SUCCEFULLY UPLOADED TO USER DATABASE")
    }
    
    /// Fetches a user's trick items for a specified trick from the database and encodes them into 'TrickItem' objects.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickId: The id of a trick in the database.
    ///
    /// - Returns: An array of 'TrickItem' objects fetched from the database.
    func getTrickItems(userId: String, trickId: String) async throws -> [TrickItem] {
        try await userDocument(userId: userId).collection("trick_items")
            .whereField(TrickItem.CodingKeys.id.rawValue, isEqualTo: trickId)
            .getDocuments(as: TrickItem.self)
    }
    
    /// Fetches a user's trick items for all tricks and encodes them into 'TrickItem' objects.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///
    /// - Returns: An array of 'TrickItem' objects fetched from the database.
    func getAllUserTrickItems(userId: String) async throws -> [TrickItem] {
        try await userDocument(userId: userId).collection("trick_items")
            .getDocuments(as: TrickItem.self)
    }
    
    /// Updates the 'notes' field in in a trick item's document in the database.
    ///
    /// - Parameters: The id of an account in the database.
    ///  - userId: The id of an account in the database.
    ///  - trickItemId: The id of a trick item in the database.
    ///  - newNotes: The new notes used to over-write the 'notes' field of the trick item.
    func updateTrickItemNotes(userId: String, trickItemId: String, newNotes: String) async throws {
        try await userDocument(userId: userId).collection("trick_items").document(trickItemId)
            .updateData( [ TrickItem.CodingKeys.notes.rawValue : newNotes ] )
    }
    
    /// Deletes the trick item from the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickItemId: The id of a trick item in the database.
    func deleteTrickItem(userId: String, trickItemId: String) async throws {
        // Deletes the trick item's video from storage
        Task {
            try await StorageManager.shared.deleteTrickItemVideo(trickItemId: trickItemId)
        }
        
        // Deletes the trick item from the user's 'trick_items' collection
        userDocument(userId: userId).collection("trick_items")
            .whereField("document_id", isEqualTo: trickItemId)
            .getDocuments() { (querySnapshot, err) in
                
            if let err = err {
                print("ERROR GETTING DOCUMENTS: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
}
