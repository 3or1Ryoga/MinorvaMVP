//
//  SetVisionView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/08.
//

import SwiftUI

struct SetVisionView: View {
    @EnvironmentObject var settings : AppSettings
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showCompletion: Bool = false
    // ユーザーID（ログイン済みのユーザーのUID）
    
    var body: some View {
        ZStack{
            VStack(spacing: 20) {
                Text("新しいビジョンを追加")
                    .font(.title)
                    .fontWeight(.bold)
                
                TextField("ビジョンのタイトル", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextEditor(text: $description)
                    .frame(height: 150)
                    .border(Color.gray, width: 1)
                    .padding()
                
                Button(action: {
                    saveVision()
                    showCompletion = true
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("保存する")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .padding()
        }
    }
    
    private func saveVision() {
        let newVision = Vision(id: UUID().uuidString, title: title, description: description, createdAt: Date())
        if let currentUser = AuthManager.shared.getCurrentUser() {
            DatabaseManager().saveVision(for: currentUser.uid, vision: newVision)
            
            // 入力フォームをリセット
            title = ""
            description = ""
        }
    }
}

#Preview {
    SetVisionView()
}
