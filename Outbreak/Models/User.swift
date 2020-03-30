//
//  User.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/28/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import Foundation

struct User: Decodable {
    let id: String
    let fullName: String
    var isFollowing: Bool?
    var isPositive: Bool?
    var hasSymptoms: Bool?
    var isHealthy: Bool?
    var bio, profileImageUrl: String?
    var following, followers: [User]?
    var UUID: String?
    var major: Int?
    var minor: Int?
    
    var posts: [Post]?
    
    var isEditable: Bool?
    
}
