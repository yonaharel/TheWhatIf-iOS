//
//  MainViewModel.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

class MainViewModel: ObservableObject {
    @Published var currentTab: TabItem = .home
    @Published var notificationsOn: Bool = UserDefaultUtils.getBool(for: .notifications) ?? false
    @Published var userStartTime: Date = UserDefaultUtils.getDate(for: .startOfFreeTime) ?? Date()
    @Published var userEndTime: Date = UserDefaultUtils.getDate(for: .endOfFreeTime) ?? Calendar.current.date(byAdding: .hour, value: 1, to: .now)!


}
extension MainViewModel {
    func resetSettings() {
        notificationsOn = false
        userStartTime = Calendar.current.startOfDay(for: .now)
        userEndTime = userStartTime.addingTimeInterval(60*30)
    }
}

extension MainViewModel {

    func onTimeChange(for key: UserDefaults.Key, newValue: Date){
        switch key {
        case .startOfFreeTime:
            if userEndTime.time <= newValue.time{
                userEndTime = newValue.addingTimeInterval(60*60)
            }
        case .endOfFreeTime:
            if newValue.time <= userStartTime.time{
                userEndTime = userStartTime.addingTimeInterval(60*60)
            }
        default:
            return
        }
        UserDefaultUtils.setValue(value: newValue, for: key)
        
    }
}


