//
//  Comment.swift
//  Outbreak
//
//  Created by Ramon Geronimo on 3/30/20.
//  Copyright © 2020 Ramon Geronimo. All rights reserved.
//

import Foundation

struct Comment: Decodable {
    let text: String
    let user: User
    let fromNow: String
}
