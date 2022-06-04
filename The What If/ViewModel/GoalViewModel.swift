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
class GoalViewModel: ObservableObject {
    @Published var goalTitle: String = ""
    @Published var goalType: GoalType? = .book
    @Published var goalDeadline: Date = .now
    @Published var progress: Double = 0
    @Published var progressString: String = ""
    @Published var goalString: String = ""
    @Published var isAddingNewGoal = false
    
    //MARK: Editing Existing Goal Data
    @Published var editGoal: Goal?
    
    @Published var selectedGoal: Goal?
    var isDeleted = false
    var cancellables = Set<AnyCancellable>()
    init() {
        let context = PersistenceController.shared.container.viewContext
        NotificationManager.shared.didRecieveNotificationId.sink { notificationId in
            self.selectedGoal = self.selectGoalFromNotification(context: context, id: notificationId)
        }.store(in: &cancellables)
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
        if let editGoal = self.editGoal{
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
    
    //MARK: If Edit Task is Available then Setting Existing Data
    func setupGoal() {
        if let editGoal = editGoal {
            goalType = GoalType(rawValue: editGoal.type ?? "")
            goalTitle = editGoal.title ?? ""
            goalString = "\(Int(editGoal.target))"
            let currProgress = editGoal.progress
            progressString = "\(Int(currProgress))"
        }
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
        if let urlString = UserDefaultUtils.getString(for: .notificationId),
           let url = URL(string: urlString),
           let oid = context.persistentStoreCoordinator!.managedObjectID(forURIRepresentation: url),
           let goal = try? context.existingObject(with: oid) as? Goal{
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
        case .other:
            return ("What is your target", "What is your goal")
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
        }
    }
  
}

