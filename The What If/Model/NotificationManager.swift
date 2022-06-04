//
//  NotificationManager.swift
//  The What If
//
//  Created by Yona Harel on 04/06/2022.
//

import Foundation
import UserNotifications
import Combine
import UIKit

class NotificationManager: NSObject {

    var didRecieveNotificationId: PassthroughSubject<String, Never> = .init()
    static let shared: NotificationManager = NotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("Success")
            }
        }
    }
    
    func scheduleNotification(for goal: Goal, newProgress: Float? = nil) {
        guard UserDefaultUtils.getBool(for: .notifications) == true else { return }
        guard let startTime = UserDefaultUtils.getDate(for: .startOfFreeTime)?.time,
              let endTime = UserDefaultUtils.getDate(for: .endOfFreeTime)?.time else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = goal.title ?? "Notification"
        content.subtitle = "Your progress is already at \(goal.getProgress().getPercentage())"
        content.sound = .default
        content.targetContentIdentifier = goal.objectID.uriRepresentation().absoluteString
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        
        var dateComponents = DateComponents()
        dateComponents.hour = startTime.hour
        dateComponents.minute = startTime.minute
        let startTimeTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        dateComponents = DateComponents()
        dateComponents.hour = endTime.hour
        dateComponents.minute = endTime.minute
        let endTimeTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let id = goal.objectID.uriRepresentation().absoluteString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        let startTimeNotificationRequest = UNNotificationRequest(identifier: id, content: content, trigger: startTimeTrigger)
        if let newProgress = newProgress {
            content.subtitle = "You have progressed \(newProgress.getPercentage()) on this Goal! Hooray!"
        }else {
            content.subtitle = "You haven't done any progress on this goal. Shame on you!"
        }
        let endTimeNotificationRequest = UNNotificationRequest(identifier: id + "_end", content: content, trigger: endTimeTrigger)
        notificationCenter.add(startTimeNotificationRequest)
        notificationCenter.add(endTimeNotificationRequest)
    }
    func removeNotification(for goal: Goal){
        let id = goal.objectID.uriRepresentation().absoluteString
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
}

//MARK: - UNUserNotificationCenterDelegate
extension NotificationManager : UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.banner)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let nid = response.notification.request.content.targetContentIdentifier{
            DispatchQueue.main.async {
                UserDefaultUtils.setValue(value: nid, for: .notificationId)
                self.didRecieveNotificationId.send(nid)
                UIApplication.shared.applicationIconBadgeNumber = 0
                completionHandler()
            }
        }
    }
    
}
