//
//  Post.swift
//  FirebaseDemo
//
//  Created by Simon Ng on 30/1/2020.
//  Copyright © 2020 AppCoda. All rights reserved.
//

import Foundation

struct Post {

    // MARK: - Properties
    
    var postId: String
    var imageFileURL: String
    var userPhoto: String
    var user: String
    var votes: Int
    var timestamp: Int
    
    // MARK: - Firebase Keys
    
    enum PostInfoKey {
        static let imageFileURL = "imageFileURL"
        static let userPhoto = "userPhoto"
        static let user = "user"
        static let votes = "votes"
        static let timestamp = "timestamp"
    }
    
    // MARK: - Initialization
    
    init(postId: String, imageFileURL: String, userPhoto: String, user: String, votes: Int, timestamp: Int = Int(Date().timeIntervalSince1970 * 1000)) {
        self.postId = postId
        self.imageFileURL = imageFileURL
        self.userPhoto = userPhoto
        self.user = user
        self.votes = votes
        self.timestamp = timestamp
    }
    
    init?(postId: String, postInfo: [String: Any]) {
        guard let imageFileURL = postInfo[PostInfoKey.imageFileURL] as? String,
            let userPhoto = postInfo[PostInfoKey.userPhoto] as? String,
            let user = postInfo[PostInfoKey.user] as? String,
            let votes = postInfo[PostInfoKey.votes] as? Int,
            let timestamp = postInfo[PostInfoKey.timestamp] as? Int else {
                
                return nil
        }
        
        self = Post(postId: postId, imageFileURL: imageFileURL, userPhoto: userPhoto,user: user, votes: votes, timestamp: timestamp)
    }
}
