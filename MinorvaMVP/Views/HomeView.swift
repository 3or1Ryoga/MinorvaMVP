//
//  HomeView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/08.
//

import SwiftUI
import FirebaseFirestore

struct HomeView: View {
    @EnvironmentObject var settings : AppSettings
    @State private var postText: String = ""
    @State private var isShowingShareSheet = false
    @State private var sharedApp: String?  // 共有先のアプリ名を保持する変数
    
    @State private var messages: [String] = []
    @State private var inputText: String = ""
    @State private var isChatActive = false
    
    @EnvironmentObject var visionsViewModel: VisionsViewModel
    
    @StateObject private var chatViewModel = ChatViewModel()
    
    @State private var chatCount: Int = 0
    @State private var chatUntil: Int = 2
    @State private var isShowingPointAlert = false
    @State private var initialMessage : String = "テキストを他のアプリに投稿してください"
    
    var body: some View {
        ZStack{
            LinearGradient(colors: [settings.firstColor.opacity(0.3), settings.secondColor.opacity(0.5)],
                                                  startPoint: .topLeading,
                                                  endPoint: .bottomTrailing)
            .ignoresSafeArea()
            ScrollView{
                VStack(spacing: 20) {
                    Text("Minorva")
                        .font(.title2)
                        .bold()
                    
                    TextEditor(text: $postText)
                        .frame(height: 150)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    
                    Button(action: {
                        isShowingShareSheet = true
                    }) {
                        Text("他のアプリに投稿する")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(postText.isEmpty)
                    .sheet(isPresented: $isShowingShareSheet) {
                        ShareSheet(activityItems: [postText]) { activityType in
                            if let activityType = activityType {
                                sharedApp = activityType.rawValue  // 共有先のアプリを取得
                                inputText = postText
                                isChatActive = true
                                Task{
                                    await startChatAI()
                                }
                                
                            } else {
                                sharedApp = "キャンセルまたは不明"
                            }
                        }
                    }
                    
                    // 共有先のアプリ名を表示
                    if let sharedApp = sharedApp {
                        Text("共有先: \(sharedApp)")
                            .font(.headline)
                            .foregroundColor(.gray)
        
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
//                            Text("AI Chat Below")
//                                .padding()
//                                .background(Color.gray.opacity(0.2))
//                                .cornerRadius(10)
                        
                        ForEach(messages, id: \.self) { message in
                            Text(message)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                        if isChatActive {
                            HStack {
                                TextEditor(text:  $inputText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    Task { await startChatAI() }
                                }) {
                                    Image(systemName: "paperplane.fill")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                                .disabled(inputText.isEmpty)
                            }
                        }
                    }
                    
                    
//                    VStack(alignment: .leading, spacing: 10) {
//                        Text("AI Chat Below")
//                            .padding()
//                            .background(Color.gray.opacity(0.2))
//                            .cornerRadius(10)
//                        ForEach(messages, id: \.self) { message in
//                            Text(message)
//                                .padding()
//                                .background(Color.gray.opacity(0.2))
//                                .cornerRadius(10)
//                        }
//                    }

                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            visionsViewModel.fetchVisions()
            
            if initialMessage != "" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    messages.append(initialMessage)
                    initialMessage = ""
                }
            }
        }
        .alert("5ptを獲得しました", isPresented: $isShowingPointAlert ) {
            Button("完了", role: .destructive) {
                isShowingPointAlert = false
                chatCount = 0
            }
        } message: {
            Text("🎉 ポイントがたまりました！ 🎉")
                .font(.largeTitle)
                .bold()
                .padding()
                .background(Color.yellow.opacity(0.8))
                .cornerRadius(15)
                .transition(.scale)
        }
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) } // SafeAreaを明示
    }
    private func startChatAI() async{
        print("startChatAIが出力された")
        let userMessage = "ユーザー：\(inputText)"
        messages.append(userMessage)
        
        
        Task {
//            await chatViewModel.fetchOpenAIResponse(message: userMessage)
//            await chatViewModel.analyzeUserInput(message: userMessage, visions: visionsViewModel.visions)
            let loadingMessage = "AI：…"
            messages.append(loadingMessage)
            
            await chatViewModel.analyzeUserInput(message: userMessage, visions: visionsViewModel.visions)
            
            if let index = messages.firstIndex(of: loadingMessage){
                messages[index] =  "AI：\(chatViewModel.responseText)"
            }
//            messages.append("AI: \(chatViewModel.responseText)")
        }
        
        chatCount += 1
        if chatCount == chatUntil {
            withAnimation {
                isShowingPointAlert = true
            }
            chatCount = 0
        }
        
        inputText = ""
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var completion: ((UIActivity.ActivityType?) -> Void)?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller.completionWithItemsHandler = { activity, _, _, _ in
            completion?(activity)  // 共有先のアプリを渡す
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

