//
//  Root.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import SwiftUI
import Foundation

struct RouteView: View {
    @EnvironmentObject var settings : AppSettings
    
    var body: some View {
        NavigationStack{
            ZStack{
//                HelloView()
//                    .transition(.identity)
//                    .environmentObject(settings)
//                TabsView(workLocation: nil)
                
                TabsView()
                    .environmentObject(settings)
                
//                TutorialTabsView(workLocation: nil)
                
            }
            .fullScreenCover(isPresented: $settings.isHelloViewPresented){
                HelloView()
                    .transition(.identity)
            }
        }
        .onAppear{
            switch LaunchUtil.launchStatus {
                case .FirstLaunch://初回起動
                
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    settings.isHelloViewPresented = true
                }
                case .NewVersionLaunch ://更新時
                break
                case .Launched://通常起動
                if AuthManager.shared.getCurrentUser() != nil {
                    settings.isHelloViewPresented = false
                    break
                }
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    settings.isHelloViewPresented = true
                }
            }
        }
    }
}

struct RouteView_Previews: PreviewProvider {
    static var previews: some View {
        RouteView()
    }
}

import Foundation
import SwiftUI

enum LaunchStatus {
    case FirstLaunch
    case NewVersionLaunch
    case Launched
}

class LaunchUtil {
    static let launchedVersionKey = "launchedVersion"
    @AppStorage(launchedVersionKey) static var launchedVersion = ""
    
    static var launchStatus: LaunchStatus {
        get{
            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            let launchedVersion = self.launchedVersion
            
            self.launchedVersion = version
            
            if launchedVersion == "" {
                return .FirstLaunch
            }
            
            return version == launchedVersion ? .Launched : .NewVersionLaunch
        }
    }
}
