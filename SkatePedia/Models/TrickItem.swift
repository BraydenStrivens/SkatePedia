//
//  TrickItem.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/13/24.
//

import Foundation

/// Defines the structure to contain information about a trick item in the database.
///
/// - Parameters:
///  - id: The id of the trick item's document in the database.
///  - trickId: The id of the trick the trick item is for.
///  - trickName: The name of the trick the trick item is for.
///  - dateCreated: The date the trick item was added.
///  - notes: The message typed by the user about the trick.
///  - progress: The user's self rated progress of a trick.
///  - videoUrl: The url link to the trick item's video in firebase's storage.
struct TrickItem: Codable, Identifiable, Equatable {
    let id: String
    let trickId: String?
    let trickName: String?
    let dateCreated: Date?
    var notes: String?
    var progress: Int?
    var videoUrl: String?
    
    init(
        id: String,
        trickId: String? = nil,
        trickName: String? = nil,
        dateCreated: Date? = nil,
        notes: String? = nil,
        progress: Int? = nil,
        videoUrl: String? = nil
        
    ) {
        self.id = id
        self.trickId = trickId
        self.trickName = trickName
        self.dateCreated = dateCreated
        self.notes = notes
        self.progress = progress
        self.videoUrl = videoUrl
    }
    
    /// Defines naming conventions for the trick items document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case id = "document_id"
        case trickId = "trick_id"
        case trickName = "trick_name"
        case dateCreated = "date_created"
        case notes = "notes"
        case progress = "progress"
        case videoUrl = "video_url"
    }
    
    // Defines a decoder to decode 'trick_item' documents into 'TrickItem' objects.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.trickId = try container.decode(String.self, forKey: .trickId)
        self.trickName = try container.decode(String.self, forKey: .trickName)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.progress = try container.decode(Int.self, forKey: .progress)
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
    }
    
    // Defines an encoder to encode a 'TrickItem' object into a 'trick_item' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.trickId, forKey: .trickId)
        try container.encodeIfPresent(self.trickName, forKey: .trickName)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.notes, forKey: .notes)
        try container.encodeIfPresent(self.progress, forKey: .progress)
        try container.encodeIfPresent(self.videoUrl, forKey: .videoUrl)
    }
    
    /// Equality function for trick item objects.
    static func ==(lhs: TrickItem, rhs: TrickItem) -> Bool {
        return lhs.id == rhs.id
    }
}
