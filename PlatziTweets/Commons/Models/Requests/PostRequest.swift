//
//  RegisterRequest.swift
//  PlatziTweets
//
//  Created by Eduardo Torrez on 6/8/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import Foundation

struct PostRequest: Codable {
    let text: String
    let imageUrl: String?
    let videoUrl: String?
    let location: PostRequestLocation?
}
