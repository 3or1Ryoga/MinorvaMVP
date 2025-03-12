//
//  TabsView.swift
//  MinorvaMVP
//
//  Created by Ryoga Sakai on 2025/03/04.
//

import SwiftUI

enum TabItems: Int, CaseIterable {
    case home = 0
    case visions
    case person

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .visions:
            return "Visions"
        case .person:
            return "Person"
        }
    }
    // Added differentiation between system and custom images
    var systemImageName: String? {
        switch self {
        case .home:
            return "house.circle"
        case .visions:
            return "exclamationmark.warninglight"
//            warninglight　この二つを切り替えてもいいかも
        case .person:
            return "person.crop.circle"
        }
    }
    
//    var customUIImage: (Bool) -> UIImage? {
//        switch self {
//        case .works:
//            return { isActive in
//                isActive ? UIImage(named: "Works_Tabbar2") : UIImage(named: "Works_Tabbar4")
//            }
//        default:
//            return { _ in
//                nil
//            }
//        }
//    }
}


struct TabsView: View {
    @State var showSighOutAlert = false
    @EnvironmentObject var settings : AppSettings
    @State private var selectedTab = 0
    @StateObject private var visionViewModel = VisionsViewModel()
    
//    init() {
//        UITabBar.appearance().isHidden = true
//    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
                .environmentObject(visionViewModel)
            
            VisionsView()
                .tabItem {
                    Label("Visions", systemImage: "exclamationmark.warninglight")
                }
                .tag(1)
                .environmentObject(visionViewModel)
            
            PersonView()
                .tabItem {
                    Label("Person", systemImage: "person.crop.circle")
                }
                .tag(2)
        }
        
        
//        NavigationView{
//            ZStack(alignment: .bottom) {
//                
//                TabView(selection: $selectedTab) {
//                    HomeView()
//                        .tag(0)
//                        .environmentObject(visionViewModel)
//
//                    VisionsView()
//                        .tag(1)
//                        .environmentObject(visionViewModel)
//
//                    PersonView()
//                        .tag(2)
//                }
//
//                // Custom Tab Bar
//                ZStack {
//                    HStack {
//                        ForEach(TabItems.allCases, id: \.self) { item in
//                            Button(action: {
//                                selectedTab = item.rawValue
//                            }) {
//                                CustomTabItem(tabItem: item, isActive: (selectedTab == item.rawValue))
//                            }
//                        }
//                    }
//                    .padding(.horizontal ,6)
//                }
//                .frame(height: 70)
//                .background(Color(red: 12/255, green: 192/255, blue: 223/255).opacity(0.2))
//                .cornerRadius(35)
//                .padding(.horizontal, 26)
//                .shadow(radius: 10)
//            }
//        }
    }
}

// MARK: - Custom Tab Item
struct CustomTabItem: View {
    let tabItem: TabItems
    let isActive: Bool

    var body: some View {
        HStack(spacing: 10) {
            Spacer()
            // Image rendering based on whether it's system or custom UIImage
//            if let systemImageName = tabItem.systemImageName {
//                Image(systemName: systemImageName)
//                    .resizable()
//                    .renderingMode(.template)
//                    .foregroundColor(isActive ? .black : .gray)
//                    .frame(width: 20, height: 20)
//            } else if let customUIImage = tabItem.customUIImage(isActive) {
//                Image(uiImage: customUIImage)
//                    .resizable()
//                    .renderingMode(.original) // Use original color for custom images
//                    .frame(width: 22, height: 22)
//            }
            if let systemImageName = tabItem.systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(isActive ? .black : .gray)
                    .frame(width: tabItem == .visions ? 24 : 20, height: tabItem == .visions ? 24 : 20)
            }

            // Tab Title when active
            if isActive {
                Text(tabItem.title)
                    .font(.system(size: 14))
                    .foregroundColor(isActive ? .black : .gray)
            }

            Spacer()
        }
        .frame(width: isActive ? 120 : 60, height: 60) // Adjust active/inactive width
        .background(isActive ? Color(red: 12/255, green: 192/255, blue: 223/255).opacity(0.4) : .clear)
        .cornerRadius(30)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
}

//List{
//    Section{
//        Button(action: {
//            do {
//                try AuthManager.shared.signOut()
//                showSighOutAlert = true
//                
//                var transaction = Transaction()
//                transaction.disablesAnimations = true
//                withTransaction(transaction) {
//                    settings.isHelloViewPresented  = true
//                }
//            } catch {
//                print("error signing out")
//            }
//        }, label: {
//            Text("サインアウト")
//        })
//    }
//}

#Preview {
    TabsView()
}
