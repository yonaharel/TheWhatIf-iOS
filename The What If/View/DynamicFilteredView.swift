//
//  DynamicFilteredView.swift
//  Task Manager
//
//  Created by Yona Harel on 13/05/2022.
//

import SwiftUI
import CoreData



struct DynamicFilteredView<Content: View, EmptyContent: View, T>: View where T: NSManagedObject {
    @FetchRequest var request: FetchedResults<T>
    let content: (T) -> Content
    let emptyView: () -> EmptyContent
    let proxy: GeometryProxy
    init(proxy: GeometryProxy, @ViewBuilder content: @escaping (T) -> Content,
         @ViewBuilder emptyView: @escaping () -> EmptyContent) {
        self.proxy = proxy
        _request = FetchRequest(entity: T.entity(), sortDescriptors: [.init(keyPath: \Goal.addedDate, ascending: false)], animation: .easeInOut)
        self.content = content
        self.emptyView = emptyView
        
//        func getPredicate() -> NSPredicate {
//            let predicate: NSPredicate
//            let calendar = Calendar.current
//            let filterKey = "deadline"
//            switch currentTab {
//            case .today:
//                let today = calendar.startOfDay(for: Date.now)
//                let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
//                predicate = NSPredicate(
//                    format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i",
//                    argumentArray: [today, tomorrow, 0]
//                )
//            case .upcoming:
//                let tomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: Date.now)!)
//                let future = Date.distantFuture
//                predicate = NSPredicate(
//                    format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i",
//                    argumentArray: [tomorrow, future, 0]
//                )
//            case .done:
//                predicate = NSPredicate(format: "isCompleted == %i", argumentArray: [1])
//            case .failed:
//                let today = calendar.startOfDay(for: Date())
//                let past = Date.distantPast
//                predicate = NSPredicate(
//                    format: "\(filterKey) >= %@ AND \(filterKey) < %@ AND isCompleted == %i",
//                    argumentArray: [past, today, 0]
//                )
//            }
//            return predicate
//        }
    }
    
    
    var body: some View {
        Group{
            if request.isEmpty {
                self.emptyView()
            } else{
                let width = (proxy.size.width / 2) - 10
                let colums = [
                    GridItem(.fixed(width)),
                    GridItem(.fixed(width)),
                ]
                LazyVGrid(columns: colums) {
                    ForEach(request, id: \.objectID){ object in
                        self.content(object)
                    }
                }
            }
        }
    }
}

