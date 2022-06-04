//
//  The_What_IfApp.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

@main
struct The_What_IfApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
