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
    
    struct Messages {
        static let endPrefix = "_end"
        static let tomorrowPrefix = "_tomorrow"
        static let failure = "You haven't done any progress on this goal. Shame on you!"
        static let endOfDayMessage = "Have you done any progress today?"
        static func startOfDayMessage(with progress: Float) -> String {
            "Your progress is already at \(progress.getPercentage())"
        }
        static func progressMessage(with progress: Float) -> String {
            "You have progressed \(progress.getPercentage()) on this Goal! Hooray!"
        }
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            if let error = error {
                print("Error authorizing request:\n \(error)")
            } else {
                print("Success")
            }
        }
    }
    
    func scheduleNotification(for goal: Goal, newProgress: Float? = nil) {
        guard UserDefaultUtils.getBool(for: .notifications),
              let startTime = UserDefaultUtils.getDate(for: .startOfFreeTime)?.time,
              let endTime = UserDefaultUtils.getDate(for: .endOfFreeTime)?.time else {
            return
        }
        let content = UNMutableNotificationContent()
        let id = goal.objectID.uriRepresentation().absoluteString

        content.title = goal.title ?? "Notification"
        content.subtitle = Messages.startOfDayMessage(with: goal.getProgress())
        content.sound = .default
        content.targetContentIdentifier = id
        content.badge = (UIApplication.shared.applicationIconBadgeNumber + 1) as NSNumber
        removeNotifications(for: goal)
        
        //MARK: Creating The Start of free time Trigger
        scheduleStartOfDayNotification(startTime: startTime, content: content, id: id)
        
        //MARK: Creating The Same Day of free time Trigger because there has been progress - only one time
        /// Adding this notification for the same day only if the user made an update before the deadline of the same day, if not, this notification is useless
        if Date.now.time <= endTime {
            scheduleNotificationForToday(id: id, content: content, newProgress: newProgress)
        }
        
        scheduleNotificationsFromTomorrow(endTime: endTime, content: content, id: id)
        
    }
    func removeNotifications(for goal: Goal) {
        let id = goal.objectID.uriRepresentation().absoluteString
        let identifiers = [id, id + Messages.endPrefix, id + Messages.tomorrowPrefix]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    //MARK: - Create for start of day
    func scheduleStartOfDayNotification(startTime: Time, content: UNMutableNotificationContent, id: String) {
        var dateComponents = DateComponents()
        dateComponents.hour = startTime.hour
        dateComponents.minute = startTime.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
    
    //MARK: - schedule for today
    func scheduleNotificationForToday(id: String, content: UNMutableNotificationContent, newProgress: Float?) {
        if let newProgress = newProgress, newProgress > 0 {
            content.subtitle = Messages.progressMessage(with: newProgress)
        } else {
            content.subtitle = Messages.failure
        }
        let now = Date()
        if let timeOfNotification = Calendar.current.date(byAdding: .minute, value: 30, to: now)?.time {
            var dateComponents = DateComponents()
            dateComponents.hour = timeOfNotification.hour
            dateComponents.minute = timeOfNotification.minute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(identifier: id + Messages.endPrefix, content: content, trigger: trigger)
            notificationCenter.add(request)
        }
    }
    //MARK: - Schedule notification from tomorrow
    func scheduleNotificationsFromTomorrow(endTime: Time, content: UNMutableNotificationContent, id: String) {
        var components = DateComponents()
        components.hour = endTime.hour
        components.minute = endTime.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        content.subtitle = Messages.endOfDayMessage
        let request = UNNotificationRequest(identifier: id + Messages.tomorrowPrefix, content: content, trigger: trigger)
        notificationCenter.add(request)
    }
}

//MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.banner)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notificationId = response.notification.request.content.targetContentIdentifier {
            DispatchQueue.main.async {
                self.didRecieveNotificationId.send(notificationId)
                UIApplication.shared.applicationIconBadgeNumber = 0
                completionHandler()
            }
        }
    }
}
