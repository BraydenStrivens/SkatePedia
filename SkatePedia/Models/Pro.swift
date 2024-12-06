//
//  Pro.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 12/3/24.
//

import Foundation

/// Defines a structure to contain data about a professional skateboarder in the database.
///
/// - Parameters:
///  - id: The id of the pro's document in the database.
///  - proName: The name of the pro skater.
///  - stance: The stance of the pro skate (regular or goofy)
struct Pro: Codable {
    let id: String
    let proName: String
    let stance: String
    
    init(
        id: String,
        proName: String,
        stance: String
    ) {
        self.id = id
        self.proName = proName
        self.stance = stance
    }
    
    /// Defines the naming conventions for the pros document's fields in the database.
    enum CodingKeys: String, CodingKey {
        case id = "document_id"
        case proName = "pro_name"
        case stance = "stance"
    }
    
    /// Defines a decoder to decode a 'pro' document into a 'Pro' object.
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.proName = try container.decode(String.self, forKey: .proName)
        self.stance = try container.decode(String.self, forKey: .stance)
    }
    
    /// Defines an encoder to encode a 'Pro' object into a 'pro' document in the database.
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.proName, forKey: .proName)
        try container.encodeIfPresent(self.stance, forKey: .stance)
    }
}
