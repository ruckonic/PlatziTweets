//
//  ErrorResponse.swift
//  PlatziTweets
//
//  Created by Eduardo Torrez on 6/8/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let user: User
    let token: String
}
