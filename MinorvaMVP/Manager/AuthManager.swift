//
//  AuthManager.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth


struct User {
    let uid: String
    let name: String
    let email: String?
    let photoURL: String?
}

enum GoogleSignInError: Error{
    case unableToGrabTopVC
    case signInPresentationError
    case authSignInError
}


final class AuthManager{
    static let shared = AuthManager()
    let auth = Auth.auth()
    
    let firebase_clientid : String?
    
    private init() { 
        self.firebase_clientid = Bundle.main.object(forInfoDictionaryKey: "ENV_FIREBASE_CLIENTID") as? String
//        print("AuthのFirebaseClientIDの出力：\(firebase_clientid ?? "nil")")
    }
    
    func signInWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            guard let result = result, error == nil else {
                completion(.failure(error!))
                return
            }
            let user = User(uid: result.user.uid, name: result.user.displayName ?? "Unknown", email: result.user.email, photoURL: result.user.photoURL?.absoluteString)
            completion(.success(user))
        }
    }
    
    func createUserWithEmail(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            guard let result = result, error == nil else {
                completion(.failure(error!))
                return
            }
            let user = User(uid: result.user.uid, name: result.user.displayName ?? "Unknown", email: result.user.email, photoURL: result.user.photoURL?.absoluteString)
            completion(.success(user))
        }
    }

    func getCurrentUser()-> User?{
        guard let authUser = auth.currentUser else{
            return nil
        }
        return User(uid: authUser.uid, name: authUser.displayName ?? "Unknown", email: authUser.email, photoURL: authUser.photoURL?.absoluteString)
    }
    
    func signInWithGoogle(completion: @escaping (Result<User, GoogleSignInError>) -> Void) {
        let clientID = firebase_clientid ?? ""
        
        print(clientID)
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let topVC = UIApplication.getTopViewController() else {
            completion(.failure(.unableToGrabTopVC))
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: topVC) { [unowned self] result, error in
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString,
                    error == nil
            else {
                completion(.failure(.signInPresentationError))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            auth.signIn(with: credential){ result, error in
                guard let result = result, error == nil else{
                    completion(.failure(.authSignInError))
                    return
                }
                
                let user = User(uid: result.user.uid, name: result.user.displayName ?? "Unknow", email: result.user.email, photoURL: result.user.photoURL?.absoluteString)
                completion(.success(user))
            }
        }
    }
    
    func signOut () throws {
        try auth.signOut()
    }
}


extension UIApplication {
    
    class func getTopViewController(base: UIViewController? = getKeyWindow()?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }

    private class func getKeyWindow() -> UIWindow? {
        //iOS13以降に対応するウィンドウ
        if #available(iOS 15, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first(where: { $0.activationState == .foregroundActive })?
                .windows.first(where: { $0.isKeyWindow })
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
