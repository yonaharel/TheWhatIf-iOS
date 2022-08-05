//
//  GoalViewModel.swift
//  The What If
//
//  Created by Yona Harel on 29/05/2022.
//

import SwiftUI
//import Combine
import CoreData
import Combine
import Shared

enum UserError: Error {
    case missingParams
    case notImplemented
}

enum ResultState<T, E: Error> {
    case found(T)
    case loading
    case failed(E)
    case waiting
}
class GoalViewModel: ObservableObject, ItemsViewModel {
    
    //MARK: Editing Existing Goal Data
    @Published var editGoal: Goal?
    
    @Published var selectedGoal: Goal?
    @Published var isAddingNewGoal = false
    @Published var isDeletingGoal = false
    @Published var result = ResultState<[Goal], Error>.waiting
    @Published var showError: Bool = false
    @Published var action: Action = .waiting
    
    enum Action {
        case refresh
        case waiting
        case refreshItem(goal: Goal)
        case deleted
    }
    
    var isDeleted = false
    var counter = 0
    private var cancellables = Set<AnyCancellable>()
    
    let networkManager = GoalNetworkManager()
//    init() {
//        NotificationManager.shared.didRecieveNotificationId.sink { [weak self] notificationId in
//            guard let self else { return }
//            self.selectedGoal = self.selectGoalFromNotification(context: context, id: notificationId)
//        }.store(in: &cancellables)
//    }
    init() {
        $action
            .receive(on: DispatchQueue.main)
            .asyncMap {
                switch $0 {
                case .refresh:
                    await self.fetchGoals()
                case .deleted:
                    await self.fetchGoals()
                    await self.updateSelected(with: nil)
                case .refreshItem(let goal):
                    await self.updateSelected(with: goal)
                default:
                    break
                }
            }
            .eraseToAnyPublisher()
            .sink(receiveValue: { _ in })
            .store(in: &self.cancellables)
    }
    func getItems() async throws -> [Goal] {
        try await networkManager.getAllGoals()
    }
    
    @MainActor
    private func updateSelected(with goal: Goal?) {
        withAnimation {
            self.selectedGoal = goal
        }
    }
    
    @MainActor
    func fetchGoals() async {
        do {
            let goals = try await getItems()
            withAnimation {
                self.result = .found(goals)
                self.showError = false
            }
        } catch {
            withAnimation {
                self.showError = true
                self.result = .failed(error)
            }
        }
    }
}


extension GoalType {
    var description: String {
        switch self {
        case .leisure:
            return "Take A Rest"
        case .sports:
            return "Have A Workout"
        case .education:
            return "Learn Something New"
        case .other:
            return "We Don't Have It Yet"
        case .family:
            return "Spend Time with the family"
        }
    }
    
    func getImage() -> String {
        switch self {
        case .education:
            return "book"
        case .sports:
            return "heart.fill"
        case .leisure:
            return "bed.double"
        case .other:
            return "questionmark.square"
        case .family:
            return "heart"
        }
    }
    
    func getLabels() -> (goalLabel: String, progressLabel: String) {
        switch self {
        case .education:
            return ("Number of pages in the book", "Number of pages read?")
        case .sports:
            return ("Number of minutes of excersize per day", "How Many did you do today?")
        case .leisure:
            return ("How much minutes you want to rest each day?", "How many did you rest?")
       default:
            return ("What is your target?", "What is your goal?")
        }
    }
    
    var goalColor: Color {
        switch self {
        case .education:
            return .cyan
        case .sports:
            return .red
        case .leisure:
            return .brown
        case .other:
            return .green
        case .family:
            return .orange.opacity(0.7)
        }
    }
  
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
}
