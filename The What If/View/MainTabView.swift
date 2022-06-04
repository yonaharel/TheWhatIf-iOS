//
//  MainTabView.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

enum TabItem{
//    case settings
    case home
    case settings
    
    var image: String {
        switch self {
        case .home:
            return "house"
        case .settings:
            return "gearshape"
        }
    }
    var text: String {
        switch self {
        case .home:
            return "Home"
        case .settings:
            return "Settings"
        }
    }
}

struct MainTabView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var mainVM: MainViewModel = .init()
    var items: [TabItem] = [
        .home,
        .settings
    ]
    var body: some View {
        TabView(selection: $mainVM.currentTab){
            HomeView()
                .tabItem {
                    buildTabBarItem(tabItem: .home)
                }.tag(TabItem.home)
            
            SettingsView()
                .environmentObject(mainVM)
                .tabItem {
                    buildTabBarItem(tabItem: .settings)
                }.tag(TabItem.settings)
            
        }
        .onAppear{
            if UserDefaultUtils.getString(for: .notificationId) != nil{
                mainVM.currentTab = .home
            }
        }
        .onChange(of: mainVM.currentTab) { newValue in
            print(newValue)
        }
    }
    
    private func buildTabBar() -> some View {
        VStack(spacing: 0) {
            Divider().frame(height: 0.1)
            HStack(alignment: .center) {
                ForEach(items, id: \.self){ item in
                    buildTabBarItem(tabItem: item)
                        .padding(.top, 25)
                }
            }
            .padding()
            .frame(height: 50)
            .background(.gray.opacity(0.1))
        }
    }
    
    private func buildTabBarItem(tabItem: TabItem) -> some View {
        VStack {
            Image(systemName: tabItem.image)
                .resizable()
                .frame(width: 25, height: 25)
            Text(tabItem.text)
                .font(.callout)
                .fontWeight(.semibold)
        }//.frame(maxWidth: .infinity)
//            .contentShape(Rectangle())
//            .onTapGesture {
//                withAnimation{
//                    mainVM.currentTab = tabItem
//                }
//            }
            .foregroundColor(mainVM.currentTab == tabItem ? (colorScheme == .dark ? .white : .black) : .gray)
            
    }
}

struct MainTabView_Previews: PreviewProvider {
//    @StateObject var mainVM: MainViewModel = .init()
    static var previews: some View {
        MainTabView()
//            .environmentObject(mainVM)
    }
}
