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


class GoalViewModel: ObservableObject, ItemsViewModel {
    
    //MARK: Editing Existing Goal Data
    @Published var editGoal: Goal?
    
    @Published var selectedGoal: Goal?

    @Published var shouldRefresh: Bool = false
    
    @Published var isAddingNewGoal = false
    
    @Published var isDeletingGoal = false

    var isDeleted = false
    
    private var cancellables = Set<AnyCancellable>()
    
    let networkManager = GoalNetworkManager()
//    init() {
//        NotificationManager.shared.didRecieveNotificationId.sink { [weak self] notificationId in
//            guard let self else { return }
//            self.selectedGoal = self.selectGoalFromNotification(context: context, id: notificationId)
//        }.store(in: &cancellables)
//    }
    
    func getItems() async throws -> [Goal] {
        try await networkManager.getAllGoals()
    }
}


extension GoalType {
    
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

