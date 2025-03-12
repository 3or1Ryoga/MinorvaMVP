//
//  UserFollowViewModel.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import SwiftUI
import Firebase
import Foundation
import FirebaseAuth

struct ErrorWrapper: Identifiable {
    let id = UUID()
    let errorMessage: String
}

final class UserFollowViewModel: ObservableObject {
    @Published var userFollows: [UserFollow] = []
    @Published var followerUsers: [UserFollow] = [] //自分をフォローしているユーザー
    @Published var usernames: [UserName] = []
    @Published var errorWrapper: ErrorWrapper?
    
    func fetchFollows() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        DatabaseManager.shared.fetchFollows(for: user.uid) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let follows):
                    self.userFollows = follows
                case .failure(let error):
                    self.errorWrapper = ErrorWrapper(errorMessage: "Failed to fetch follows: \(error)")
                }
            }
        }
    }
    
    func fetchFollowers() {
        guard let user = Auth.auth().currentUser else {
            return
        }

        DatabaseManager.shared.fetchFollowers(for: user.uid) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let followers):
                    self.followerUsers = followers
                case .failure(let error):
                    self.errorWrapper = ErrorWrapper(errorMessage: "Failed to fetch followers: \(error)")
                }
            }
        }
    }
    
    func addFollow(followUserUid: String, username: String) {
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        if followUserUid == user.uid {
            self.errorWrapper = ErrorWrapper(errorMessage: "You cannot follow yourself.")
            return
        }

        
        
        if userFollows.contains(where: { $0.followUserUid == followUserUid }) {
            self.errorWrapper = ErrorWrapper(errorMessage: "You are already following this user.")
            return
        }
        
        let newUserFollow = UserFollow(userUid: user.uid, followUserUid: followUserUid, username: username)
        DatabaseManager.shared.addFollow(userFollow: newUserFollow) { success in
            DispatchQueue.main.async {
                if success {
                    self.fetchFollows()
                } else {
                    self.errorWrapper = ErrorWrapper(errorMessage: "Failed to add follow")
                }
            }
        }
    }
    
    func searchUserName(username: String) {
        DatabaseManager.shared.searchUserName(username: username) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let usernames):
                    self.usernames = usernames
                case .failure(let error):
                    self.errorWrapper = ErrorWrapper(errorMessage: "Failed to search usernames: \(error)")
                }
            }
        }
    }
    
    func updateUsername(newUsername: String) {
        guard let user = Auth.auth().currentUser else {
            self.errorWrapper = ErrorWrapper(errorMessage: "User not authenticated")
            return
        }
        
        let oldUsername = user.displayName ?? ""
        
        DatabaseManager.shared.updateUsernameInFollows(oldUsername: oldUsername, newUsername: newUsername, userUid: user.uid) { success in
            DispatchQueue.main.async {
                if success {
                    print("Username updated successfully in follows")
                } else {
                    self.errorWrapper = ErrorWrapper(errorMessage: "Failed to update usernames in follows")
                }
            }
        }
    }
}
