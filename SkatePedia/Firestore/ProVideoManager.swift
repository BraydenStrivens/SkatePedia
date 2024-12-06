//
//  ProVideoManager.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/20/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore

/// Contains all the functions for uploading and fetching data of the professional skateboarder's videos.
final class ProVideoManager {
    
    static let shared = ProVideoManager()
    private init() { }
    
    private let proCollection = Firestore.firestore().collection("pro_videos")
    
    private func proDocument(proId: String) -> DocumentReference {
        proCollection.document(proId)
    }
    
    private func proVideosCollection(proId: String) -> CollectionReference {
        proDocument(proId: proId).collection("videos")
    }
    
    private func proVideosDocument(proId: String, trickId: String) -> DocumentReference {
        proVideosCollection(proId: proId).document(trickId)
    }
    
    /// Fetches the data about a pro given the pro's name
    ///
    /// - Parameters:
    ///  - proName: The name of the professional skateboarder.
    ///
    /// - Returns: An object containing data about the pro fetched from the database.
    func getPro(proName: String) async throws -> Pro {
        let query: Query = proCollection
            .whereField(Pro.CodingKeys.proName.rawValue, isEqualTo: proName)
        
        return try await query.getDocument(as: Pro.self)
    }
    
    /// Fetches the data for the video of a specified pro doing a specified trick.
    ///
    /// - Parameters:
    ///  - proId: The id of the pro to fetch the video from.
    ///  - trickId: The id of the trick to fetch the video from.
    ///
    /// - Returns: A 'ProVideo' object containing data about the video.
    func getProVideo(proId: String, trickId: String) async throws -> ProVideo {
        let query: Query = proVideosCollection(proId: proId)
            .whereField(ProVideo.CodingKeys.trickId.rawValue, isEqualTo: trickId)
        
        return try await query.getDocument(as: ProVideo.self)
    }
    
    /// Uploads data about the pro's video to the database.
    ///
    /// - Parameters:
    ///  - proVideo: An object containing data about the pro's video. 
    func uploadProVideoToDatabase(proVideo: ProVideo) async throws {
        let document = proVideosDocument(proId: proVideo.proId, trickId: proVideo.trickId)
        let documentId = document.documentID
        
        let videoUrl = try await StorageManager.shared.getProVideoUrl(proId: proVideo.proId, trickId: proVideo.trickId)
        
        let data: [String: Any] = [
            ProVideo.CodingKeys.id.rawValue : documentId,
            ProVideo.CodingKeys.proName.rawValue : proVideo.proName,
            ProVideo.CodingKeys.proId.rawValue : proVideo.proId,
            ProVideo.CodingKeys.trickName.rawValue : proVideo.trickName,
            ProVideo.CodingKeys.trickId.rawValue : proVideo.trickId,
            ProVideo.CodingKeys.videoUrl.rawValue : videoUrl
        ]
        
        try await document.setData(data, merge: false)
        
        print("DEBUG: PRO VIDEO SUCCESSFULLY UPLOADED TO DATABASE")
    }
}
