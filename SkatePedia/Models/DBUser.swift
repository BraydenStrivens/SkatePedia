//
//  DBUser.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 11/13/24.
//

import Foundation

/// Defines a structure to contain information about a user in the database.
///
/// - Parameters:
///  - userId: The id of an account in the database.
///  - username: The username associated with an account.
///  - email: The email associated with an account.
///  - dateCreated: The date an account was created.
struct DBUser: Codable {
    let userId: String
    let username: String?
    let email: String?
    let dateCreated: Date?
    
    init(auth: AuthDataResultModel, username: String, dateCreated: Date) {
        self.userId = auth.uid
        self.email = auth.email
        self.username = username
        self.dateCreated = dateCreated
    }
    
    init(
        userId: String,
        username: String? = nil,
        email: String? = nil,
        dateCreated: Date? = nil
    ) {
        self.userId = userId
        self.username = username
        self.email = email
        self.dateCreated = dateCreated
    }
    
    /// Defines the naming conventions for the 'users' document's fields in the database
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case username = "username"
        case email = "email"
        case dateCreated = "date_created"
    }
    
    /// Defines a decoder to decode a 'users' document into a 'DBUser' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.username = try container.decodeIfPresent(String.self, forKey: .username)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
    }
    
    /// Defines an encoder to encode a 'DBUser' object into the 'users' document in the database.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.username, forKey: .username)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
    }
}
