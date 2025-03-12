//
//  SignInWithEmailView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import SwiftUI

struct SignInWithEmailView: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    @Binding var showName: Bool
    @Binding var showEmailSignIn: Bool // Binding for controlling sheet visibility
    
    @EnvironmentObject var settings : AppSettings
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocapitalization(.none)
            
            SecureField(settings.isEnglish ? "Password" : "パスワード", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .autocapitalization(.none)
            
            Button(action: {
                AuthManager.shared.createUserWithEmail(email: email, password: password) { result in
                    switch result {
                    case .success(_):
                        showEmailSignIn = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showName = true // Show full screen cover
                        }
                    case .failure(_):
                        AuthManager.shared.signInWithEmail(email: email, password: password) { result in
                            switch result {
                            case .success(_):
                                showEmailSignIn = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showName = true
                                }
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                                showError = true
                            }
                        }
                    }
                }
            }) {
                Text(settings.isEnglish ? "Sign in with Email" : "Emailでサインイン")
                    .padding()
                    .foregroundColor(.white)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke()
                            .foregroundColor(.white)
                            .frame(width: 300)
                    }
                    .shadow(color: Color.init(uiColor: .white), radius: 2)
            }
            .alert(isPresented: $showError) {
                Alert(title: Text(settings.isEnglish ? "Sign In Error" : "サインインできませんでした"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
        .padding()
    }
}
