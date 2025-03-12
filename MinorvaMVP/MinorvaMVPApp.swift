//
//  MinorvaMVPApp.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//


import SwiftUI
import FirebaseCore
import GoogleSignIn
import Combine

extension Color {
    static var minorva_blue = Color(red: 0.24, green: 0.48, blue: 0.88)
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct MinorvaMVPApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var settings = AppSettings()
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
                RouteView()
                    .environmentObject(settings)
            }
        }
    }
}

class AppSettings : ObservableObject{
    @Published var isHelloViewPresented :  Bool = false
    @Published var isEnglish: Bool = UserDefaults.standard.bool(forKey: "isEnglish") {
        didSet {
            // 値が変更されたときにUserDefaultsに保存
            UserDefaults.standard.set(isEnglish, forKey: "isEnglish")

            updateLanguage()
        }
    }
    @Published var isTutorialCompleted : Bool = UserDefaults.standard.bool(forKey: "isTutorialCompleted") {
        didSet {
            // 値が変更されたときにUserDefaultsに保存
            UserDefaults.standard.set(isTutorialCompleted, forKey: "isTutorialCompleted")
        }
    }
    
    @Published var firstColor = Color(red: 56/255, green: 182/255, blue: 255/255)
    @Published var secondColor = Color(red: 227/255, green: 249/255, blue: 227/255)

    private var cancellableEnglish: AnyCancellable?
    private var cancellableTutorial: AnyCancellable?

    init() {
        self.isEnglish = UserDefaults.standard.bool(forKey: "isEnglish")
//        self.isTutorialCompleted = UserDefaults.standard.bool(forKey: "isTutorialCompleted")
        if UserDefaults.standard.object(forKey: "isTutorialCompleted") == nil {
            self.isTutorialCompleted = true
            UserDefaults.standard.set(true, forKey: "isTutorialCompleted")
        } else {
            self.isTutorialCompleted = UserDefaults.standard.bool(forKey: "isTutorialCompleted")
        }

        cancellableEnglish = $isEnglish.sink { newValue in
            UserDefaults.standard.set(newValue, forKey: "isEnglish")
            
            print("isEnglish has changed to: \(newValue)")
        }
        // isTutorialCompletedの変更を監視してUserDefaultsに反映
        cancellableTutorial = $isTutorialCompleted.sink { newValue in
            UserDefaults.standard.set(newValue, forKey: "isTutorialCompleted")
            print("isTutorialCompleted has changed to: \(newValue)")
        }
    }
    
    // 言語設定を切り替えるメソッド
    private func updateLanguage() {
        let languageCode = isEnglish ? "en" : "ja"
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        print("Language changed to: \(languageCode)")
    }
}
