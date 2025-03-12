//
//  SignInView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import SwiftUI

struct SignInView: View {
    
    @State var showName : Bool = false
    @State private var showEmailSignIn: Bool = false
    
//    let firstColor = Color(uiColor: .blue)
//    let secondColor = Color(uiColor: .green)
//    let firstColor = Color(uiColor: UIColor(red: 56/255, green: 101/255, blue: 206/255, alpha: 1.0))
//    let secondColor = Color(uiColor: UIColor(red: 248/255, green: 68/255, blue: 58/255, alpha: 1.0))
//    let firstColor = Color(red: 0.2, green: 0.6, blue: 0.8)
//    let secondColor = Color(red: 0.2, green: 0.6, blue: 0.8)
    
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    @EnvironmentObject var settings : AppSettings
    
    var body: some View {
        ZStack{
//            Color.black
            LinearGradient(colors: [settings.firstColor.opacity(0.9), settings.secondColor.opacity(0.5)],
                                                  startPoint: .topLeading,
                                                  endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
//            (spacing: 60)
            VStack{
                Spacer()
//                Image(systemName: "apple.meditate.square.stack")
//                    .resizable()
//                    .frame(maxWidth: screenWidth * 0.8, maxHeight: screenWidth * 0.8)
//                    .scaledToFit()
//                    .foregroundColor(.minorva_blue)
//                    .clipped()
//                    .puffEffect()
                
                Text(settings.isEnglish ? "Welcome to Minorva" : "Minorvaへようこそ")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .frame(maxWidth: 360)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 20){
                    Button{
                        AuthManager.shared.signInWithGoogle{result in
                            switch result{
                            case .success(_):
                                var transaction = Transaction()
                                transaction.disablesAnimations = true
                                withTransaction(transaction) {
                                    showName = true
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }label: {
                        Text(settings.isEnglish ? "Sign in with Google" : "Googleでサインイン")
                            .padding()
                            .foregroundColor(.white)
                            .overlay{
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke()
                                    .foregroundColor(.white)
                                    .frame(width: 300)
                            }
                            .shadow(color: Color.init(uiColor: .white), radius: 2)
                    }
                    .frame(width: 300)
                    
                    Button {
                       showEmailSignIn = true
                   } label: {
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
                   .frame(width: 300)
                }
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showName){
            UserNameView()
        }
        .sheet(isPresented: $showEmailSignIn) {
            SignInWithEmailView(showName: $showName, showEmailSignIn: $showEmailSignIn)
                .padding()
                .presentationBackground(LinearGradient(gradient: Gradient(colors: [settings.firstColor.opacity(0.6), settings.secondColor.opacity(0.2)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .edgesIgnoringSafeArea(.all)
        }
    }
}
