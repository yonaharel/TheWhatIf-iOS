//
//  SettingsView.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

struct SettingsView: View {
    @State var isOn: Bool = false
    @Environment(\.colorScheme) var scheme
    var body: some View {
        NavigationView{
            List{
                Section{
                    HStack {
                        Text("Notifications")
                        Toggle("", isOn: $isOn)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            isOn.toggle()
                        }
                    }
                    
                } header: {
                    Text("App Settings")
                }
                Section {
                    Button {
                        
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
