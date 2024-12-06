//
//  Comment.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/15/24.
//

import Foundation

/// Defines a structure to contain information about a comment.
///
/// - Parameters:
///  - id: The id of the comment's document in the database.
///  - postId: The id of the post for which the comment was posted on.
///  - fromUserId: The id of the user who wrote the comment.
///  - content: A 'String' message typed by the commenter.
///  - dateCreated: The data the comment was added to a post.
struct Comment: Codable {
    let id: String
    let postId: String
    let fromUserId: String
    let content: String
    let dateCreated: Date
    
    init(
        id: String,
        postId: String,
        fromUserId: String,
        content: String,
        dateCreated: Date
    ) {
        self.id = id
        self.postId = postId
        self.fromUserId = fromUserId
        self.content = content
        self.dateCreated = dateCreated
    }
    
    // Defines the naming conventions for the comment document's fields in the database
    enum CodingKeys: String, CodingKey {
        case id = "comment_id"
        case postId = "post_id"
        case fromUserId = "from_user_id"
        case content = "content"
        case dateCreated = "date_created"
    }
    
    // Defines the decoder for decoding a comment document into a comment object
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.postId = try container.decode(String.self, forKey: .postId)
        self.fromUserId = try container.decode(String.self, forKey: .fromUserId)
        self.content = try container.decode(String.self, forKey: .content)
        self.dateCreated = try container.decode(Date.self, forKey: .dateCreated)
    }
    
    // Defines an encoder for encoding a comment object to the comment document in the database
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.postId, forKey: .postId)
        try container.encodeIfPresent(self.fromUserId, forKey: .fromUserId)
        try container.encodeIfPresent(self.content, forKey: .content)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
    
    // Equality function
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id
    }
}
