//
//  UserFollow.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import Foundation

class UserFollow : Identifiable {
    let id : String
    let userUid: String
    let followUserUid: String
    let username: String
    
    init(id: String = UUID().uuidString, userUid: String, followUserUid: String, username: String) {
        self.id = id
        self.userUid = userUid
        self.followUserUid = followUserUid
        self.username = username
    }
}
