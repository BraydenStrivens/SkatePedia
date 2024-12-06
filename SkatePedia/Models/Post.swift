//
//  Post.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/20/24.
//

import Foundation

/// Defines the structure to contain information about a post in the databse.
///
/// - Parameters:
///  - id: The id of the post's document in the database.
///  - userId: The id of the account who published the post.
///  - trick: The name of the trick the user is posting about.
///  - notes: A message typed by the poster.
///  - likes: The number of likes on a post.
///  - dateCreated: The date the post was posted.
///  - videoUrl: The url of the post's video in firebase's storage.
struct Post: Codable {
    let id: String
    let userId: String
    let trick: String
    let notes: String
    let likes: Int
    let dateCreated: Date
    let videoUrl: String?
    
    init(
        id: String,
        userId: String,
        trick: String,
        notes: String,
        likes: Int,
        dateCreated: Date,
        videoUrl: String? = nil
    ) {
        self.id = id
        self.userId = userId
        self.trick = trick
        self.notes = notes
        self.likes = likes
        self.dateCreated = dateCreated
        self.videoUrl = videoUrl
    }
     
    /// Defines naming conventions for the post document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case id = "post_id"
        case userId = "user_id"
        case trick = "trick_name"
        case notes = "notes"
        case likes = "likes"
        case dateCreated = "date_created"
        case videoUrl = "video_url"
    }
    
    /// Defines a decoder to decode a 'post' document into a 'Post' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.trick = try container.decode(String.self, forKey: .trick)
        self.notes = try container.decode(String.self, forKey: .notes)
        self.likes = try container.decode(Int.self, forKey: .likes)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
        self.videoUrl = try container.decode(String.self, forKey: .videoUrl)
    }
    
    /// Defines an encoder to encode a 'Post' object into a 'post' document.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.trick, forKey: .trick)
        try container.encodeIfPresent(self.notes, forKey: .notes)
        try container.encodeIfPresent(self.likes, forKey: .likes)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.videoUrl, forKey: .videoUrl)
    }
    
    /// Equality function for 'Post' objects.
    static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id
    }
}




