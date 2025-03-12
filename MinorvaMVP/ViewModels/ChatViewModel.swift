//
//  ChatGPTManager.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/08.
//

import Foundation
import OpenAI

//struct ChatRequest: Encodable {
//    let model: String
//    let messages: [[String: String]]
//}
////
////struct ChatResponse: Decodable {
////    struct Choice: Decodable {
////        struct Message: Decodable {
////            let role: String
////            let content: String
////        }
////        let message: Message
////    }
////    
////    let choices: [Choice]
////}
//
//struct ChatResponse: Codable {
//    let choices: [Choice]
//    
//    struct Choice: Codable {
//        let message: Message
//        
//        struct Message: Codable{
//            let content: String
//        }
//    }
//}


class ChatViewModel: ObservableObject {
    
    var openAI = OpenAI(apiToken: "")
    @Published var responseText: String = "ここにレスポンスが表示されます"

    let api_token : String?
    
    init() {
        self.api_token = Bundle.main.object(forInfoDictionaryKey: "ENV_API_TOKEN") as? String
        print("API tokenの出力：\(api_token ?? "nil")")
        openAI = OpenAI(apiToken: api_token ?? "nil")
    }
    
    @MainActor
    func analyzeUserInput(message: String, visions: [Vision]) async {
        let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: message)
        
        let visionsInfo = visions.map { vision in
            "- \(vision.title): \(vision.description)"
        }.joined(separator: "\n")
        
        let systemMessage = ChatQuery.ChatCompletionMessageParam(
            role: .system,
            content: """
            You are an assistant that supports users in achieving their goals.  
            Based on the user's social media post, "\(message)", engage in a conversation to encourage self-reflection.  

            - First, ask a question to explore the motivation and true feelings behind this post.  
            - Next, ask how this post has impacted those around them or themselves.  
            - Then, help the user recognize their goal, "\(visionsInfo)", and ask a question that guides them toward their next action.  

            Ask one short question at a time, in **Japanese**.  
            If you determine that the user's thoughts have become clearer and their self-awareness has deepened,  
            **praise them at an appropriate moment and provide a brief analysis before concluding the conversation.**  

            Additionally, if you feel that the user's vision, "\(visionsInfo)", may need adjustment,  
            suggest an alternative perspective **in a natural and non-forceful manner**,  
            such as: "この視点から見ても良いかもしれませんね" (This perspective might also be worth considering).  
            """
        )
        
        guard let systemMessage = systemMessage, let userMessage = userMessage else { return }
        
        let query = ChatQuery(messages: [systemMessage, userMessage], model: .gpt4_o)

        do {
            let result = try await openAI.chats(query: query)
            if let firstChoice = result.choices.first {
                switch firstChoice.message {
                case .assistant(let assistantMessage):
                    await MainActor.run {
                        responseText = assistantMessage.content ?? "No response"
                    }
                default:
                    break
                }
            }
        } catch {
            await MainActor.run {
                responseText = "エラー: \(error.localizedDescription)"
                print(responseText)
            }
        }
    }
    
    
    @MainActor
    func mentalAnalyzeUserInput(message: String, visions: [Vision], isInit: Bool) async {
        
        var messages: [ChatQuery.ChatCompletionMessageParam] = []
        
        if isInit {
            // 🔹 Vision のデータを文字列化
            let visionsInfo = visions.map { vision in
                "- \(vision.title): \(vision.description)"
            }.joined(separator: "\n")
            
            guard let systemMessage = ChatQuery.ChatCompletionMessageParam(
                role: .system,
                content: """
                As an expert in life studies, behavior and sociology, please consider this step-by-step with general social common sense.
                
                Users have the following [future outlook, ideal image, future vision, and goals to aim for].
                
                [future outlook, ideal image, future vision, and goals to aim for]
                \(visionsInfo)
                
                The psychology and feelings that users have based on their statements,
                After a detailed analysis of the user's psychology and feelings, which are divided into manifest and subconscious,
                The behavior inferred from the user's statements and utterances,
                We then analyze [how the user's statements and actions inferred from the statements are connected to their future outlook, ideal image, future vision, and the goals they are aiming for],
                Please provide a few examples so that users can clearly understand,
                Please provide some examples in Japanese.
                
                [how the user's statements and actions inferred from the statements are connected to their future outlook, ideal image, future vision, and the goals they are aiming for]
                """
            ) else {
                return
            }
            
            messages.append(systemMessage)
        }
        // 🔹 Vision のデータを文字列化
//        let visionsInfo = visions.map { vision in
//            "- \(vision.title): \(vision.description)"
//        }.joined(separator: "\n")
//        
//        let systemMessage = ChatQuery.ChatCompletionMessageParam(
//            role: .system,
//            content: """
//            As an expert in life studies, behavior and sociology, please consider this step-by-step with general social common sense.
//            
//            Users have the following [future outlook, ideal image, future vision, and goals to aim for].
//
//            [future outlook, ideal image, future vision, and goals to aim for]
//            \(visionsInfo)
//
//            The psychology and feelings that users have based on their statements,
//            After a detailed analysis of the user's psychology and feelings, which are divided into manifest and subconscious,
//            The behavior inferred from the user's statements and utterances,
//            We then analyze [how the user's statements and actions inferred from the statements are connected to their future outlook, ideal image, future vision, and the goals they are aiming for],
//            Please provide a few examples so that users can clearly understand,
//            Please provide some examples in Japanese.
//            
//            [how the user's statements and actions inferred from the statements are connected to their future outlook, ideal image, future vision, and the goals they are aiming for]
//            """)
        guard let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: message) else {
            return
        }

        messages.append(userMessage)
        
        let query = ChatQuery(messages: messages, model: .gpt4_o)

        do {
            let result = try await openAI.chats(query: query)
            if let firstChoice = result.choices.first {
                switch firstChoice.message {
                case .assistant(let assistantMessage):
                    await MainActor.run {
                        responseText = assistantMessage.content ?? "No response"
                    }
                default:
                    break
                }
            }
        } catch {
            await MainActor.run {
                responseText = "エラー: \(error.localizedDescription)"
                print(responseText)
            }
        }
    }
}


//            あなたは、ユーザーの目標達成を支援するアシスタントです。
//            ユーザーが投稿した「\(message)」というSNSの内容を基に、対話を通じて自己分析を促してください。
//
//            - まず、その投稿の動機や本音を深掘りする質問をしてください。
//            - 次に、その投稿が周囲や自分自身に与えた影響について質問してください。
//            - その上で、ユーザーの目標である「\(visionsInfo)」というビジョンを再認識し、次の行動を考える質問をしてください。
//
//            質問は短く、1つずつ投げかけてください。
//            会話を続ける中で、ユーザーの考えが整理され、自己理解が深まったと判断できたら、
//            **適切なタイミングでユーザーを褒め、簡単な分析結果を示しながら会話を終えてください。**
//
//            また、もしユーザーの話から「\(visionsInfo)」というビジョンを修正したほうがよいと感じた場合は、
//            無理に押しつけず、**「この視点から見ても良いかもしれませんね」と自然な形で提案してください。**


    
//    func sendMessage(message: String) async -> String{
//        // ⭐️追加：エンドポイントの設定
//        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
//        let body : [String: Any] = [
//            "model": "gpt-3.5-turbo",
//            "messages": [["role": "user", "content": message]]
//        ]
//        var chatResponse : String = ""
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//
//        do{
//            let (data, _) = try await URLSession.shared.data(for: request)
//            if let response = try? JSONDecoder().decode(ChatResponse.self , from: data){
//                chatResponse = response.choices.first?.message.content ?? "エラー"
//            }
//        } catch {
//            chatResponse = "通信エラー"
//        }
//        print(chatResponse)
//        return chatResponse
//    }
    
    
    
//    @MainActor
//    func fetchOpenAIResponse(message: String) async {
//
////        let openAI = OpenAI()
//
//        let systemMessage = ChatQuery.ChatCompletionMessageParam(role: .system, content: "あなたはフレンドリーなアシスタントです。ユーザーに丁寧に対応してください。")
//        let userMessage = ChatQuery.ChatCompletionMessageParam(role: .user, content: "こんにちは！自己紹介してください。")
//        let assistantMessage = ChatQuery.ChatCompletionMessageParam(role: .assistant, content: "Pythonはシンプルで強力なプログラミング言語です。")
//        guard let systemMessage = systemMessage, let userMessage = userMessage else { return }
//
//        let query = ChatQuery(messages: [systemMessage, userMessage], model: .gpt4_o)
//
//        do {
//            let result = try await openAI.chats(query: query)
//            if let firstChoice = result.choices.first {
//                switch firstChoice.message {
//                case .assistant(let assistantMessage):
//                    await MainActor.run {
//                        responseText = assistantMessage.content ?? "No response"
//                    }
//                default:
//                    break
//                }
//            }
//        } catch {
//            await MainActor.run {
//                responseText = "エラー: \(error.localizedDescription)"
//                print(responseText)
//            }
//        }
//    }
    


//        let systemMessage = ChatQuery.ChatCompletionMessageParam(
//            role: .system,
//            content: """
//            人生学と行動学と社会学の専門家として、
//            一般的な社会常識を交えて、段階的に考えてください。
//
//            ユーザーは、以下のような【将来の見通しや理想像や未来像や目指すゴール】を持っています。
//
//            【将来の見通しや理想像、未来像、目指すゴール】
//            \(visionsInfo)
//
//            ユーザーの発言からユーザーが持っている心理や気持ちを、
//            顕在意識と潜在意識に分けて詳細に分析した上で、
//            ユーザーの発言や発言から推測される行動が、
//            【どのように【将来の見通しや理想像、未来像、目指すゴール】に結びつくのか】を、
//            ユーザーにも明確にわかるように、
//            いくつか提示してください。
//
//            【ユーザーの発言や発言から推測される行動が、
//            どのように【将来の見通しや理想像、未来像、目指すゴール】に結びつくのか】
//            """)

//行動の背景や理由を掘り下げる質問
//👉「なぜ、それに取り組んでいるのですか？」

//目標と行動のつながりを再認識させる質問
//👉 「その行動を続けた先に、どんな自分になっていたいですか？」

//3. 目標と行動のつながりを再認識させる質問
//👉 「その行動を続けた先に、どんな自分になっていたいですか？」
    

//let url = URL(string: "https://api.openai.com/v1/chat/completions")!
//print("URL\(url)")
//var request = URLRequest(url: url)
//request.httpMethod = "POST"
//request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//let messages = [
//    ["role": "system", "content": "あなたは優秀なアシスタントです。"],
//    ["role": "user", "content": "\(message)"]
//]
//
//print(messages)
//
//let body = ChatRequest(model: "gpt-4", messages: messages)
//
//do {
//    request.httpBody = try JSONEncoder().encode(body)
//} catch {
//    print("ここでミスが起こってる①")
//    completion(nil)
//    return
//}
//
//let task = URLSession.shared.dataTask(with: request) { data, _, error in
//    guard let data = data, error == nil else {
//        print("ここでミスが起こってる②")
//        completion(nil)
//        return
//    }
//
//    // 🔽 追加: 受け取ったデータを文字列に変換して出力
//    if let jsonString = String(data: data, encoding: .utf8) {
//        print("APIレスポンス: \(jsonString)")
//    } else {
//        print("レスポンスのデータが文字列に変換できませんでした")
//    }
//
//    do {
//        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
////                completion(response.choices.first?.message["content"])
//        completion(response.choices.first?.message.content)
//    } catch {
//        print("ここでミスが起こってる③")
//        completion(nil)
//    }
//}
//task.resume()
