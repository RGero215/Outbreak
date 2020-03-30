//
//  Post.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/28/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import Foundation

struct Post: Decodable {
    let id: String
    let text: String
    let createdAt: Date
    let user: User
    let imageUrl: String
    
    var fromNow: String?
    
    var comments: [Comment]?
    var hasLiked: Bool?
    
    var numLikes: Int
}
