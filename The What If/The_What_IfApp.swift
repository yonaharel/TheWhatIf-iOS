//
//  The_What_IfApp.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

@main
struct The_What_IfApp: App {
//    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear{
                    NotificationManager.shared.requestAuthorization()
                }
        }
    }
}

//class AppDelegate: NSObject, UIApplicationDelegate{
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        NotificationManager.requestAuthorization()
//        UNUserNotificationCenter.current().delegate = self
//        return true
//    }
//}
//extension AppDelegate: UNUserNotificationCenterDelegate{
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        if let id = response.notification.request.content.userInfo["objectId"] as? URL{
//            UserDefaultUtils.setValue(value: id, for: .notificationId)
//        }
//    }
//}
