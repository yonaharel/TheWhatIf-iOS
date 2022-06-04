//
//  SettingsView.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) var scheme
    @EnvironmentObject var mainViewModel: MainViewModel
   
    var body: some View {
        NavigationView{
            List{
                Section{
                    HStack {
                        Text("Notifications")
                        Toggle("", isOn: $mainViewModel.notificationsOn)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            mainViewModel.notificationsOn.toggle()
                        }
                    }.onChange(of: mainViewModel.notificationsOn) { newValue in
                        UserDefaultUtils.setValue(value: newValue, for: .notifications)
                        NotificationManager.shared.notificationCenter.removeAllPendingNotificationRequests()
                    }
                    
                    DatePicker(selection: $mainViewModel.userStartTime, in: ...Date.distantFuture, displayedComponents: .hourAndMinute) {
                        Text("Start of Free Time")
                    }
                    .onChange(of: mainViewModel.userStartTime) { newValue in
                        mainViewModel.onTimeChange(for: .startOfFreeTime, newValue: newValue)
                    }
                    .onChange(of: mainViewModel.userEndTime) { newValue in
                        mainViewModel.onTimeChange(for: .endOfFreeTime, newValue: newValue)
                    }
                    DatePicker(selection: $mainViewModel.userEndTime, in: ...Date.distantFuture, displayedComponents: .hourAndMinute) {
                        Text("End of Free Time")
                    }

                } header: {
                    Text("App Settings")
                }
                Section {
                    Button {
                        mainViewModel.resetSettings()
                    } label: {
                        Text("Reset settings")
                            .foregroundColor(scheme == .dark ? .white : .black)
                    }
                    Button {
                        
                    } label: {
                        Text("Logout")
                            .foregroundColor(.red)
                    }
                 
                } header: {
                    Text("Configuartions")
                    
                }

            }
            .navigationTitle("Settings")
            .navigationViewStyle(StackNavigationViewStyle())
//            .phoneOnlyStackNavigationView()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(MainViewModel.init())
    }
}

extension View {
    @ViewBuilder func phoneOnlyStackNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }
}
