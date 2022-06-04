//
//  UserDefaultUtils.swift
//  The What If
//
//  Created by Yona Harel on 04/06/2022.
//

import Foundation
extension UserDefaults{
    enum Key: String {
        case startOfFreeTime
        case endOfFreeTime
        case notifications
        case notificationId
    }
}
class UserDefaultUtils {
    static let container = UserDefaults.standard
    static func getString(for key: UserDefaults.Key) -> String? {
        container.string(forKey: key.rawValue)
    }
    static func getBool(for key: UserDefaults.Key) -> Bool? {
        container.bool(forKey: key.rawValue)
    }
    static func getDate(for key: UserDefaults.Key) -> Date? {
        container.object(forKey: key.rawValue) as? Date
    }
    static func getURL(for key: UserDefaults.Key) -> URL? {
        container.url(forKey: key.rawValue)
    }
    static func setValue(value: Any, for key: UserDefaults.Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    static func getObject<T>(for key: UserDefaults.Key) -> T?{
        container.object(forKey: key.rawValue) as? T
    }
}
