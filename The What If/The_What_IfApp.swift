//
//  The_What_IfApp.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

@main
struct The_What_IfApp: App {
//    @StateObject var mainVM: MainViewModel = .init()
    var body: some Scene {
        WindowGroup {
            MainTabView()
//                .environmentObject(mainVM)
        }
    }
}
