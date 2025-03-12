//
//  SettingView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/08.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI
import FirebaseStorage


struct PersonView: View {
    
    @EnvironmentObject var settings : AppSettings
    @StateObject var userNameViewModel = UserNameViewModel()
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var iconPhotoUrl : URL? = nil
    @State private var showUserNameView = false
    let iconSize : CGFloat = UIScreen.main.bounds.width * 0.28
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: iconSize, height: iconSize)
                            .cornerRadius(iconSize / 2)
                            .foregroundColor(.gray)
                            .overlay(
                                Circle()
                                    .stroke(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.green.opacity(0.5)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                            )
                        
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .frame(width: iconSize / 4, height: iconSize / 4)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(x: -4, y: -4)
                    }
                    .padding(.trailing, 4)
                    
//                    if let username = userNameViewModel.currentUserName {
//                        Button(action: {
//                            showUserNameView = true
//                        }, label: {
//                            Text(username)
//                                .font(.system(size: 24, weight: .bold, design: .monospaced))
//                                .foregroundColor(Color.black)
//                        })
//                    }
//
                    Button(action: {
                        showUserNameView = true
                    }, label: {
                        Text(userNameViewModel.currentUserName ?? "")
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(Color.black)
                    })
                    
                    Button(action: {
                        do {
                            try AuthManager.shared.signOut()

                            var transaction = Transaction()
                            transaction.disablesAnimations = true
                            withTransaction(transaction) {
                                settings.isHelloViewPresented  = true
                            }
                        } catch {
                            print("error signing out")
                        }
                    }, label: {
                        Text("サインアウト")
                    })
                }
            }
            .onAppear{
                userNameViewModel.fetchUserNames()
                print(userNameViewModel.currentUserName ?? "nil")
                print("settings.isHelloViewPresented: \(settings.isHelloViewPresented)")
                      
            }
            .fullScreenCover(isPresented: $showUserNameView){
                UserNameViewForSetting()
            }
        }
        
    }
}
