//
//  EndPoints.swift
//  PlatziTweets
//
//  Created by Eduardo Torrez on 6/8/20.
//  Copyright © 2020 Rene Corrales. All rights reserved.
//

import Foundation

struct Endpoints {
    static let domain = "https://platzi-tweets-backend.herokuapp.com/api/v1"
    static let login = Endpoints.domain + "/auth"
    static let register = Endpoints.domain + "/register"
    static let getPosts = Endpoints.domain + "/posts"
    static let post = Endpoints.domain + "/posts"
    static let delete = Endpoints.domain + "/posts/"
}

