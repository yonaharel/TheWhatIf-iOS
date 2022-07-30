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
}

class GoalViewModel: ObservableObject, ItemsViewModel {
    @Published var goalTitle: String = ""
    @Published var goalType: GoalType? = .book
    @Published var goalDeadline: Date = .now
    @Published var progress: Double = 0
    @Published var progressString: String = ""
    @Published var goalString: String = ""
    @Published var isAddingNewGoal = false
    
    @Published var isDeletingGoal = false
    //MARK: Editing Existing Goal Data
    @Published var editGoal: Goal?
    
    @Published var selectedGoal: Goal?
    @Published var selectedMotivation: Motivation?
    @Published var shouldRefresh: Bool = false
    var isDeleted = false
    var cancellables = Set<AnyCancellable>()
    let networkManager = MotivationNetworkManager()
    init() {
        let context = PersistenceController.shared.container.viewContext
        NotificationManager.shared.didRecieveNotificationId.sink { [weak self] notificationId in
            guard let self else { return }
            self.selectedGoal = self.selectGoalFromNotification(context: context, id: notificationId)
        }.store(in: &cancellables)
    }
    
    func getItems() async throws -> [Motivation] {
        try await networkManager.getAllMotivations()
    }
}

extension GoalViewModel {
    
    func addGoal(context: NSManagedObjectContext) -> Bool{
        guard let target = Double(goalString),
              let currentProgress = Double(progressString),
              target > 0 else {
            return false
        }
      
        var goal: Goal!
        var newProgress: Float? = nil
        if let editGoal{
            goal = editGoal
            newProgress = Float((currentProgress - goal.progress) / target)
        } else {
            goal = Goal(context: context)
            goal.addedDate = Date.now
        }
        goal.title = goalTitle
        goal.progress = currentProgress
        goal.target = target
        goal.type = self.goalType!.rawValue
        
        if let _ = try? context.save() {
            NotificationManager.shared.scheduleNotification(for: goal, newProgress: newProgress)
            return true
        }
        return false
    }
    func createGoal(context: NSManagedObjectContext) async throws {
        guard let target = Double(goalString),
              let currentProgress = Double(progressString),
              target > 0 else {
            throw UserError.missingParams
        }
      
        var goal: Goal!
        
        if let editGoal {
            goal = editGoal
        } else {
            goal = Goal(context: context)
            goal.addedDate = Date.now
        }
        
        goal.title = goalTitle
        goal.progress = currentProgress
        goal.target = target
        goal.type = self.goalType!.rawValue
        
       try await createMotivation(from: goal)
    }
    //MARK: If Edit Task is Available then Setting Existing Data
    func setupGoal() {
        if let editGoal {
            goalType = GoalType(rawValue: editGoal.type ?? "")
            goalTitle = editGoal.title ?? ""
            goalString = "\(Int(editGoal.target))"
            let currProgress = editGoal.progress
            progressString = "\(Int(currProgress))"
        }
    }
    
    func createMotivation(from goal: Goal) async throws {
        try await networkManager.addMotivation(goal.toMotivation())
    }
}

extension Motivation: Identifiable { }
extension Motivation {
    func toGoal() -> Goal {
        let newGoal = Goal()
        newGoal.progress = Double(progress)
        newGoal.title = title
        newGoal.type = self.type.rawValue
        newGoal.addedDate = dueDate
        newGoal.target = Double(self.goal)
        return newGoal
    }
}

extension Goal {
    func toMotivation() -> Motivation {
        .init(id: UUID(),
              title: title ?? "",
              type: MotivationType(type),
              dueDate: self.addedDate ?? .distantFuture,
              progress: Int(progress),
              goal: Int(target))
    }
}

extension MotivationType {
    init(goalType: GoalType) {
        switch goalType {
        case .book:
            self = .education
        case .exercise:
            self = .sports
        case .rest:
            self = .leisure
        case .other:
            self = .other
        case .family:
            self = .family
        }
    }
    
    init(_ description: String?) {
        guard let description,
              let goalType = GoalType(rawValue: description) else {
            self = .other
            return
        }
        self = .init(goalType: goalType)
    }
}

extension GoalViewModel{
    //MARK: Resetting Data
    func resetGoalData() {
        goalType = .book
        goalTitle = ""
        editGoal = nil
        progressString = ""
        goalString = ""
        isDeleted = false
    }
    func selectGoalFromNotification(context: NSManagedObjectContext, id: String) -> Goal?{
        if id.isEmpty { return nil }
        if let url = URL(string: id),
           let oid = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
           let goal = try? context.existingObject(with: oid) as? Goal{
            NotificationManager.shared.scheduleNotification(for: goal)
            return goal
        }
        return nil
    }
}

enum GoalType: String, CaseIterable {
    case book = "Read A Book"
    case exercise = "Workout"
    case rest = "Take a Rest"
    case other = "Other"
    case family = "Spend Time with Family"
    
    init(from type: MotivationType) {
        switch type {
        case .leisure:
            self = .rest
        case .sports:
            self = .exercise
        case .education:
            self = .book
        case .other:
            self = .other
        case .family:
            self = .family
        }
    }
}


extension GoalType{
    
    func getImage() -> String {
        switch self {
        case .book:
            return "book"
        case .exercise:
            return "heart.fill"
        case .rest:
            return "bed.double"
        case .other:
            return "questionmark.square"
        case .family:
            return "heart"
        }
    }
    
    func getLabels() -> (goalLabel: String, progressLabel: String) {
        switch self {
        case .book:
            return ("Number of pages in the book", "Number of pages read?")
        case .exercise:
            return ("Number of minutes of excersize per day", "How Many did you do today?")
        case .rest:
            return ("How much minutes you want to rest each day?", "How many did you rest?")
       default:
            return ("What is your target?", "What is your goal?")
        }
    }
    var goalColor: Color {
        switch self {
        case .book:
            return .cyan
        case .exercise:
            return .red
        case .rest:
            return .brown
        case .other:
            return .green
        case .family:
            return .orange.opacity(0.7)
        }
    }
  
}

