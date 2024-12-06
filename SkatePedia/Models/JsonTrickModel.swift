//
//  JsonTrickModel.swift
//  SkatePedia
//
//  Created by Brayden Strivens on 10/23/24.
//

import Foundation

/// Defines the structure of the 'beginner', 'intermediate', and 'advanced' sections in the profile view. This data is pulled from a Json file.
struct JsonMenuItem: Codable, Identifiable {
    enum CodingKeys: CodingKey {
        case id
        case name
        case items
    }
    
    var id: String
    var name: String
    var items: [JsonTrick]
}

/// Defines the structure of each trick in the profile view. This data is pulled from a Json file.
struct JsonTrick: Codable, Identifiable {
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case description
        case tricksToLearnFirst
    }
    
    var id: String
    var name: String
    var description: String
    var tricksToLearnFirst: String
}
