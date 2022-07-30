//
//  DynamicFilteredView.swift
//  Task Manager
//
//  Created by Yona Harel on 13/05/2022.
//

import SwiftUI
import CoreData
import Shared

protocol ItemsViewModel<Item>: AnyObject {
    associatedtype Item: Identifiable
    func getItems() async throws -> [Item]
}

struct DynamicFilteredView<Content: View,
                           EmptyContent: View,
                           Item,
                           VM: ItemsViewModel<Item>>: View {
    
    let content: (Item) -> Content
    let emptyView: () -> EmptyContent
    let proxy: GeometryProxy
    let viewModel: VM
    @State var items: [Item] = []
    @State var networkError: String? = nil
    @Binding var shouldRefresh: Bool
    var filterFunction: ((Item) -> Bool)?
    
    init(proxy: GeometryProxy,
         shouldRefresh: Binding<Bool>,
         VM: VM,
         @ViewBuilder content: @escaping (Item) -> Content,
         @ViewBuilder emptyView: @escaping () -> EmptyContent,
         filter: ((Item) -> Bool)? = nil) {
        self.viewModel = VM
        self.proxy = proxy
        self.content = content
        self.emptyView = emptyView
        self.filterFunction = filter
        self._shouldRefresh = shouldRefresh
    }
    
    
    var body: some View {
        Group {
            if items.isEmpty || self.networkError != nil {
                VStack {
                    if let networkError {
                        Spacer()
                        Text("\(networkError)")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red)
                            }
//                            .foregroundColor(.red)
                    }
                    self.emptyView()
                        .onAppear{ shouldRefresh = false }
                }
            } else {
                buildRequestView()
            }
        }
        .task {
            await fetchItemsFromVM()
        }
        .refreshable {
            await fetchItemsFromVM()
        }
        .onChange(of: shouldRefresh) { newValue in
            guard newValue else { return }
            Task {
                await fetchItemsFromVM()
            }
        }
    }
    
    private func fetchItemsFromVM() async {
        do {
            self.items = try await viewModel.getItems()
            shouldRefresh = false
        } catch {
            self.networkError = error.localizedDescription
        }
    }
    
    @ViewBuilder
    func buildRequestView() -> some View {
        let width = (proxy.size.width / 2) - 10
        let colums = [
            GridItem(.fixed(width)),
            GridItem(.fixed(width)),
        ]
        LazyVGrid(columns: colums) {
            if let filterFunction {
                ForEach(items.filter(filterFunction)) {
                    self.content($0)
                }
            } else {
                ForEach(items) { item in
                    self.content(item)
                }
            }
        }
    }
}

