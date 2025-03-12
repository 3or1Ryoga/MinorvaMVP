//
//  UserNameView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//


import SwiftUI

struct UserNameView: View {
    @StateObject var viewModel = UserNameViewModel()
    @State var showUserNameView : Bool = false
    @State var showNextButton : Bool = false
    @State var canUse : Bool = false
    @State var alertMessage = ""
    @State var username = ""
    
//    let firstColor = Color(uiColor: UIColor(red: 56/255, green: 101/255, blue: 206/255, alpha: 1.0))
//    let secondColor = Color(uiColor: UIColor(red: 248/255, green: 68/255, blue: 58/255, alpha: 1.0))

//    let firstColor = Color(red: 0.2, green: 0.6, blue: 0.8)
//    let secondColor = Color(red: 0.2, green: 0.6, blue: 0.8)
    
    @EnvironmentObject var settings : AppSettings
    
    var body: some View {
        ZStack{
            LinearGradient(gradient: Gradient(colors: [settings.firstColor.opacity(0.9), settings.secondColor.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20){
                if !showNextButton {
                    Text(settings.isEnglish ? "Write Your User Name" : "ユーザーネームを書いてください")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                
                if showNextButton {
                    Text(settings.isEnglish ? "Hello!! \(username)" : "こんにちは\(username)さん")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                
                TextField("User Name", text: $username, axis: .vertical)
                    .autocapitalization(.none)
                    .keyboardType(.asciiCapable)
                    .onChange(of: username){
                        filter(value: username)
                    }
                    .padding()
                    .frame(width: 300)
                    .background(Color.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .shadow(color: Color.init(uiColor: .white), radius: 2)
                    .onChange(of: username) {
                        if username.count < 3 {
                            alertMessage = settings.isEnglish ? "Username must be at least 3 characters." : "ユーザーネームは３文字以上にしてください。"
                            canUse = false
                            return
                        }
                        
                        checkUsernameAvailability(username: username) { isAvailable in
                            if isAvailable {
                                alertMessage = settings.isEnglish ? "The username is available." :"そのユーザーネームは利用可能です。"
                                canUse = true
                            } else {
                                alertMessage = settings.isEnglish ? "Username is duplicated with someone else." :"ユーザーネームが誰かと重複しています。"
                                
                                viewModel.errorMessage = "This username is already taken."
                                canUse = false
                            }
                        }
                    }

                Text(alertMessage)
                    .foregroundColor(canUse ? .white : .red)

                Button(action: {



                    if username.count < 3 {
                        alertMessage = settings.isEnglish ? "Username must be at least 3 characters." :"ユーザーネームは３文字以上にしてください。"
                        canUse = false
                        return
                    }


                    // ユーザーネームの重複チェックを実行
                    checkUsernameAvailability(username: username) { isAvailable in
                        if isAvailable {
                            viewModel.addUserName(username: username)
                            UserFollowViewModel().updateUsername(newUsername: username)
                            alertMessage = ""
                            showNextButton = true
                        } else {
                            alertMessage = settings.isEnglish ? "Username is duplicated with someone else." :"ユーザーネームが誰かと重複しています。"
                            
                            viewModel.errorMessage = "This username is already taken."
                            canUse = false
                        }
                    }
                }) {
                    Text(settings.isEnglish ? "Add User Name" :"ユーザーネームを追加")
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(Color.orange)
//                        .cornerRadius(10)
                        .padding()
                        .foregroundColor(.white)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 20)
//                                .stroke()
//                                .foregroundColor(.white)
//                                .frame(width: 300)
//                        }
                        .background(.gray)
                        .shadow(color: Color.init(uiColor: .white), radius: 2)
                        .cornerRadius(10)
                }
                
                if showNextButton {
                    Button(action: {
                        var transaction = Transaction()
                        transaction.disablesAnimations = true
                        withTransaction(transaction) {
                            showUserNameView = true
                        }
                    }){
                        Text(settings.isEnglish ? "Next →" : "次へ →")
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }
            .padding()
            .onAppear {
                UserNameViewModel().fetchUserNames()
                
//                以下のコードはユーザーネームを消すコード！必ずユーザーネームをつける時に使おう
                guard let user = AuthManager.shared.getCurrentUser() else{
                    return
                }
                viewModel.deleteUserName(userUid: user.uid) { success in
                    if success {
                        // Sign out or any other necessary actions
                        print("Succed to delete the username")
                    } else {
                        // Handle error case
                        print("Faild to delete")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showUserNameView){
            InitialVisionView()
//            showHelloView: $showHelloView
        }
    }
        
    
    func filter(value: String) {
        let validCodes = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let sets = CharacterSet(charactersIn: validCodes)
        username = String(value.unicodeScalars.filter(sets.contains).map(Character.init))
    }
    // ユーザーネームの重複チェック関数
    func checkUsernameAvailability(username: String, completion: @escaping (Bool) -> Void) {
        viewModel.fetchUserNames { result in
            switch result {
            case .success(let usernames):
                let isAvailable = !usernames.contains { $0.username == username }
                completion(isAvailable)
            case .failure:
                viewModel.errorMessage = "Failed to check username availability."
                completion(false)
            }
        }
    }
    
    
}

