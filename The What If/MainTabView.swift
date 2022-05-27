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
//    @EnvironmentObject var mainVM: MainViewModel
    @StateObject var mainVM: MainViewModel = .init()
    var items: [TabItem] = [
        .home,
        .settings
    ]
    var body: some View {
        VStack(spacing: 0) {
            switch mainVM.currentTab {
            case .home:
                HomeView()
            case .settings:
                Spacer()
                EmptyView()
            }
            buildTabBar()
        }
    }
    
    private func buildTabBar() -> some View {
        VStack(spacing: 0) {
            Divider().frame(height: 0.1)
            HStack(alignment: .center) {
                ForEach(items, id: \.self){ item in
                    buildTabBarItem(tabItem: item)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
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
        }.frame(maxWidth: .infinity)
            .onTapGesture {
                withAnimation{
                    mainVM.currentTab = tabItem
                }
            }
            .foregroundColor(mainVM.currentTab == tabItem ? .black : .gray)
    }
}

struct MainTabView_Previews: PreviewProvider {
//    @StateObject var mainVM: MainViewModel = .init()
    static var previews: some View {
        MainTabView()
//            .environmentObject(mainVM)
    }
}
