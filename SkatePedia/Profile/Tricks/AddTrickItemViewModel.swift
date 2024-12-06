//
//  AddTrickItemViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation
import PhotosUI
import SwiftUI
import Firebase
import FirebaseFirestore

/// Defines a class that contains functions for uploading user trick items to the database.
@MainActor
final class AddTrickItemViewModel: ObservableObject {
    
    @Published var notes: String = ""
    @Published var progress: Int = 0
    @Published var errorMessage = ""
    
    @Published var selectedAVideo = false
    @Published var selectedItem: PhotosPickerItem? {
        didSet {
            selectedAVideo = true
        }
    }
    
    @Published private(set) var user: DBUser? = nil
    
    private let userVideoStoragePath = "user_videos"
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    /// Uploads the trick item video to storage and uploads a 'TrickItem' object to the database. Returns the video url of the trick item video in storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - trickItemId: The id of a trick item in the database
    ///
    /// - Returns: The video url of the uploaded video.
    func uploadVideo(userId: String, trickItemId: String) async throws -> String? {
        guard let item = selectedItem else { return nil }
        guard let videoData = try await item.loadTransferable(type: Data.self) else { return nil }
        

        guard let videoUrl = try await StorageManager.shared.uploadTrickItemVideo(videoData: videoData, trickItemId: trickItemId) else { return nil }
        
        return videoUrl
    }
    
    /// Uploads a trick item to the database and storage.
    ///
    /// - Parameters:
    ///  - userId: The id of an account in the database.
    ///  - data: A 'JsonTrick' object containing information about the trick the trick item is for.
    func addTrickItem(userId: String, data: JsonTrick) async throws {
        guard let item = selectedItem else { return }
        guard let videoData = try await item.loadTransferable(type: Data.self) else { return }
            
        let trickItem = TrickItem(
            id: "",
            trickId: data.id,
            trickName: data.name,
            dateCreated: Date(),
            notes: notes,
            progress: progress,
            videoUrl: ""
        )
        
        try await UserManager.shared.addTrickItem(userId: userId, videoData: videoData, trickItem: trickItem)
    }
}
