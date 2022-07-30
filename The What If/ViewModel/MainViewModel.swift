//
//  MainViewModel.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI
import Combine
class MainViewModel: ObservableObject {
    @Published var currentTab: TabItem = .home
    @Published var notificationsOn: Bool = UserDefaultUtils.getBool(for: .notifications)
    @Published var userStartTime: Date = UserDefaultUtils.getDate(for: .startOfFreeTime) ?? Date()
    @Published var userEndTime: Date = UserDefaultUtils.getDate(for: .endOfFreeTime) ?? Calendar.current.date(byAdding: .hour, value: 1, to: .now)!
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        bindItems()
    }
    
    private func bindItems() {
        NotificationManager.shared.didRecieveNotificationId
            .map{ _ in TabItem.home }
            .assign(to: &$currentTab)
        
        Publishers.CombineLatest($userStartTime, $userEndTime)
            .receive(on: RunLoop.main)
            .sink(receiveValue: onTimeChange)
            .store(in: &self.cancellables)
        
    }
    
}


extension MainViewModel {
    func resetSettings() {
        notificationsOn = false
        userStartTime = Calendar.current.startOfDay(for: .now)
        userEndTime = userStartTime.addingTimeInterval(60*30)
    }

}


//MARK: - On Time Change
extension MainViewModel {
    func onTimeChange(startTime: Date, endTime: Date){
        if endTime.time <= startTime.time {
            let calendar = Calendar.current
            if let newEndTime = calendar.date(byAdding: .hour, value: 1, to: startTime) {
                self.userEndTime = newEndTime
            }
        }
        UserDefaultUtils.setValues([
            .startOfFreeTime: startTime,
            .endOfFreeTime: endTime
        ])
    }
}


