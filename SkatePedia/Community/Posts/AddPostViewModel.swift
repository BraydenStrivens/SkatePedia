//
//  AddPostViewModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/19/24.
//

import Foundation
import SwiftUI
import PhotosUI

/// Defines a class that contains functions for adding posts.
@MainActor
final class AddPostViewModel: ObservableObject {
    
    @Published var communityViewModel = CommunityViewModel()
    @Published var trickName = ""
    @Published var content = ""
    @Published var errorMessage = ""
    @Published var selectedAVideo = false
    @Published var selectedItem: PhotosPickerItem? {
        didSet {
            selectedAVideo = true
        }
    }
    
    /// Uploads the post to the database and its associated video to storage through the post manager class.
    ///
    /// - Parameters:
    ///  - userId: The id of the current user in the database.
    ///  - postId: The id of the post in the database.
    func addPost(userId: String, postId: String) async throws {
        
        guard let item = selectedItem else { return }
        guard let videoData = try await item.loadTransferable(type: Data.self) else { return }
        
        let post = Post(id: postId,
                        userId: userId,
                        trick: trickName,
                        notes: content,
                        likes: 0,
                        dateCreated: Date(),
                        videoUrl: "")
        
        try await PostManager.shared.addPost(videoData: videoData, post: post)
    }
}
