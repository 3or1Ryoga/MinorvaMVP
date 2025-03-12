//
//  UserName.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import Foundation

class UserName: Identifiable {
    let userUid: String
    let username: String
    let userPhotoUrl : String
    
    init(userUid: String, username: String, userPhotoUrl : String) {
        self.userUid = userUid
        self.username = username
        self.userPhotoUrl = userPhotoUrl
    }
}
