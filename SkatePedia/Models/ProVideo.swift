//
//  ProVideo.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/20/24.
//

import Foundation

/// Defines a structure to contain information about a professional skateboarder's videos that is stored in the database and storage.
///
/// - Parameters:
///  - id: The id of the document in the pro's 'videos' subcollection.
///  - proName: The name of the pro skater.
///  - proId: The id of the pro's document in the database.
///  - trickName: The name of the trick being done in the video.
///  - trickId: The id of the trick being done in the video.
///  - videoUrl: The url link to the video in firebase's storage
struct ProVideo: Codable {
    let id: String
    let proName: String
    let proId: String
    let trickName: String
    let trickId: String
    let videoUrl: String
    
    init(
        id: String,
        proName: String,
        proId: String,
        trickName: String,
        trickId: String,
        videoUrl: String
    ) {
        self.id = id
        self.proName = proName
        self.proId = proId
        self.trickName = trickName
        self.trickId = trickId
        self.videoUrl = videoUrl
    }
    
    /// Defines naming conventions for the pros document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case id = "document_id"
        case proName = "pro_name"
        case proId = "pro_id"
        case trickName = "trick_name"
        case trickId = "trick_id"
        case videoUrl = "video_url"
    }
    
    /// Defines a decoder to decode a 'pro_videos' document into a 'ProVideo" object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.proName = try container.decode(String.self, forKey: .proName)
        self.proId = try container.decode(String.self, forKey: .proId)
        self.trickName = try container.decode(String.self, forKey: .trickName)
        self.trickId = try container.decode(String.self, forKey: .trickId)
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
    }
    
    /// Defines an encoder to encode a 'ProVideo' object into a 'pro_videos' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.proName, forKey: .proName)
        try container.encodeIfPresent(self.proId, forKey: .proId)
        try container.encodeIfPresent(self.trickName, forKey: .trickName)
        try container.encodeIfPresent(self.trickId, forKey: .trickId)
        try container.encodeIfPresent(self.videoUrl, forKey: .videoUrl)
    }
}
