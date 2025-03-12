//
//  DatabaseManager.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import SwiftUI
import Foundation
import FirebaseFirestore
//import FirebaseFirestoreSwift
import CoreLocation

enum FetchFollowError: Error {
    case snapshotError
}

final class DatabaseManager {
    static let shared = DatabaseManager()
    let db = Firestore.firestore()
    
    let annotationsRef = Firestore.firestore().collection("annotations")
    let polylinesRef = Firestore.firestore().collection("polylines")
    let worksRef = Firestore.firestore().collection("works")
    let usernameRef = Firestore.firestore().collection("usernames")
    let followRef = Firestore.firestore().collection("follows")
    let workThanksRef = Firestore.firestore().collection("workThanks")
    
    func fetchUserNames(completion: @escaping (Result<[UserName], FetchFollowError>) -> Void) {
        usernameRef.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(.snapshotError))
                return
            }
            var usernames: [UserName] = []
            for document in snapshot.documents {
                let data = document.data()
                if let userUid = data["userUid"] as? String,
                   let userPhotoUrl = data["userPhotoUrl"] as? String,
                   let username = data["username"] as? String {
                   let userName = UserName(userUid: userUid, username: username, userPhotoUrl: userPhotoUrl)
                    usernames.append(userName)
                }
            }
            completion(.success(usernames))
        }
    }

    func addUserNameToDatabase(userName: UserName, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "userUid": userName.userUid,
            "username": userName.username,
            "userPhotoUrl": userName.userPhotoUrl
        ]
        
        usernameRef.document(userName.userUid).setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func deleteUserName(userUid: String, completion: @escaping (Bool) -> Void) {
        usernameRef.whereField("userUid", isEqualTo: userUid).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(false)
                return
            }
            
            for document in snapshot.documents {
                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting username: \(error)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func updateUsernameInFollows(oldUsername: String, newUsername: String, userUid: String, completion: @escaping (Bool) -> Void) {
        followRef.whereField("followUserUid", isEqualTo: userUid).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching follows: \(String(describing: error))")
                completion(false)
                return
            }
            
            let batch = Firestore.firestore().batch()
            
            for document in snapshot.documents {
                batch.updateData(["username": newUsername], forDocument: document.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error updating usernames: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func updateUserPhotoUrl(userUid: String, newPhotoUrl: String, completion: @escaping (Bool) -> Void) {
        let userDocument = usernameRef.document(userUid)
        userDocument.updateData(["userPhotoUrl": newPhotoUrl]) { error in
            if let error = error {
                print("Error updating user photo URL: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updatePhotoUrlInFollows(newPhotoUrl: String, userUid: String, completion: @escaping (Bool) -> Void) {
        followRef.whereField("followUserUid", isEqualTo: userUid).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching follows: \(String(describing: error))")
                completion(false)
                return
            }
            
            let batch = Firestore.firestore().batch()
            
            for document in snapshot.documents {
                batch.updateData(["photoUrl": newPhotoUrl], forDocument: document.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error updating photoUrls: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func fetchFollows(for userUid: String, completion: @escaping (Result<[UserFollow], FetchFollowError>) -> Void) {
        followRef.whereField("userUid", isEqualTo: userUid).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(.snapshotError))
                return
            }
            var follows: [UserFollow] = []
            for document in snapshot.documents {
                let data = document.data()
                if let userUid = data["userUid"] as? String,
                   let followUserUid = data["followUserUid"] as? String,
                   let username = data["username"] as? String,
                   let id = data["id"] as? String {
                    let userFollow = UserFollow(id: id, userUid: userUid, followUserUid: followUserUid, username: username)
                    follows.append(userFollow)
                }
            }
            completion(.success(follows))
        }
    }
    
    func fetchFollowers(for userUid: String, completion: @escaping (Result<[UserFollow], FetchFollowError>) -> Void) {
        followRef.whereField("followUserUid", isEqualTo: userUid).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(.snapshotError))
                return
            }
            var followers: [UserFollow] = []
            for document in snapshot.documents {
                let data = document.data()
                if let userUid = data["userUid"] as? String,
                   let followUserUid = data["followUserUid"] as? String,
                   let username = data["username"] as? String,
                   let id = data["id"] as? String {
                    let userFollow = UserFollow(id: id, userUid: userUid, followUserUid: followUserUid, username: username)
                    followers.append(userFollow)
                }
            }
            completion(.success(followers))
        }
    }

    
    func addFollow(userFollow: UserFollow, completion: @escaping (Bool) -> Void) {
        let data: [String: Any] = [
            "id": userFollow.id,
            "userUid": userFollow.userUid,
            "followUserUid": userFollow.followUserUid,
            "username": userFollow.username
        ]
        
        followRef.document(userFollow.id).setData(data) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func searchUserName(username: String, completion: @escaping (Result<[UserName], FetchFollowError>) -> Void) {
        usernameRef.whereField("username", isEqualTo: username).getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(.failure(.snapshotError))
                return
            }
            var usernames: [UserName] = []
            for document in snapshot.documents {
                let data = document.data()
                if let userUid = data["userUid"] as? String,
                   let userPhotoUrl = data["userPhotoUrl"] as? String,
                   let username = data["username"] as? String {
                    let userName = UserName(userUid: userUid, username: username, userPhotoUrl: userPhotoUrl)
                    usernames.append(userName)
                }
            }
            completion(.success(usernames))
        }
    }
    
    func saveVision(for userUid: String, vision: Vision) {
        let visionRef = db.collection("usernames").document(userUid).collection("visions").document(vision.id)

        let visionData: [String: Any] = [
            "id" : vision.id,
            "title": vision.title,
            "description": vision.description,
            "createdAt": Timestamp(date: vision.createdAt)
        ]

        visionRef.setData(visionData) { error in
            if let error = error {
                print("Error saving vision: \(error.localizedDescription)")
            } else {
                print("Vision saved successfully!")
            }
        }
    }
    
    func fetchVisions(for userUid: String, completion: @escaping ([Vision]) -> Void) {
        let visionRef = db.collection("usernames").document(userUid).collection("visions")

        visionRef.order(by: "createdAt", descending: true).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching visions: \(error.localizedDescription)")
                completion([])
                return
            }

            var visions: [Vision] = []
            snapshot?.documents.forEach { document in
                let data = document.data()
                let title = data["title"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                let createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                let id = data["id"] as? String ?? ""

                let vision = Vision(id: id, title: title, description: description, createdAt: createdAt)
                visions.append(vision)
            }

            completion(visions)
        }
    }
    
    func deleteVision(for userUid: String, visionId: String, completion: @escaping (Error?) -> Void) {
        let visionRef = db.collection("usernames").document(userUid).collection("visions").document(visionId)
        
        visionRef.delete { error in
            if let error = error {
                print("Error deleting vision: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Vision deleted successfully!")
                completion(nil)
            }
        }
    }
}
