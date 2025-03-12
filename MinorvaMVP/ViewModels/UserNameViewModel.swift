//
//  UserNameViewModel.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

final class UserNameViewModel: ObservableObject {
    @Published var currentUserName: String?
    @Published var usernames: [UserName] = []
    @Published var errorMessage: String? = nil
    @Published var selectedImage: UIImage? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUserNames(completion: ((Result<[UserName], FetchFollowError>) -> Void)? = nil) {
        DatabaseManager.shared.fetchUserNames { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let usernames):
                    self?.usernames = usernames
                    completion?(.success(usernames))
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch usernames: \(error)"
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func addUserName(username: String) {
        guard let user = AuthManager.shared.getCurrentUser() else{
            print("ダメだね！")
            return
        }
        
        let userName = UserName(userUid: user.uid, username: username, userPhotoUrl: user.photoURL ?? "")
        DatabaseManager.shared.addUserNameToDatabase(userName: userName) { [weak self] success in
            if success {
                self?.fetchUserNames()
            } else {
                self?.errorMessage = "Failed to add username"
            }
        }
    }
    
    func deleteUserName(userUid: String, completion: @escaping (Bool) -> Void) {
        DatabaseManager.shared.deleteUserName(userUid: userUid) { success in
            DispatchQueue.main.async {
                if success {
                    self.fetchUserNames()
                } else {
                    self.errorMessage = "Failed to delete username"
                }
                completion(success)
            }
        }
    }
    func fetchCurrentUserName() {
        guard let user = AuthManager.shared.getCurrentUser() else {
            errorMessage = "User not found"
            return
        }
        
        DatabaseManager.shared.fetchUserNames { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let usernames):
                    if let userName = usernames.first(where: { $0.userUid == user.uid }) {
                        self?.currentUserName = userName.username
                    } else {
                        self?.errorMessage = "Username not found"
                    }
                case .failure(let error):
                    self?.errorMessage = "Failed to fetch username: \(error)"
                }
            }
        }
    }
    
    func updateUserPhotoUrl(newPhotoUrl: String) {
        guard let user = AuthManager.shared.getCurrentUser() else {
            self.errorMessage = "User not found"
            return
        }
        
        DatabaseManager.shared.updateUserPhotoUrl(userUid: user.uid, newPhotoUrl: newPhotoUrl) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    // Optionally, update the local `currentUserName`'s photo URL if needed
//                    self?.currentUserName = newPhotoUrl
//                    self?.fetchUserNames()
                    self?.updateFollowersPhotoUrl(newPhotoUrl: newPhotoUrl, userUid: user.uid)
                } else {
                    self?.errorMessage = "Failed to update user photo URL"
                }
            }
        }
    }
    
    private func updateFollowersPhotoUrl(newPhotoUrl: String, userUid: String) {
        DatabaseManager.shared.updatePhotoUrlInFollows(newPhotoUrl: newPhotoUrl, userUid: userUid) { success in
            if success {
                print("Successfully updated followers' photo URLs")
                self.fetchCurrentUserName()
            } else {
                print("Failed to update followers' photo URLs")
            }
        }
    }
    
    func getUserName(for userUid: String) -> String? {
        return usernames.first(where: { $0.userUid == userUid })?.username
    }
    
    func getUserPhotoUrl(for userUid: String) -> String? {
        return usernames.first(where: { $0.userUid == userUid })?.userPhotoUrl
    }
}
