//
//  GoalViewModel.swift
//  The What If
//
//  Created by Yona Harel on 29/05/2022.
//

import SwiftUI
//import Combine
import CoreData

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
    
    var isDeleted = false
}

extension GoalViewModel {
    
    func addGoal(context: NSManagedObjectContext) -> Bool{
        guard let target = Double(goalString),
              let currentProgress = Double(progressString),
              target > 0 else {
            return false
        }
      
        var goal: Goal!
      
        if let editGoal = self.editGoal{
            goal = editGoal
        } else {
            goal = Goal(context: context)
        }
        goal.title = goalTitle
        goal.progress = currentProgress
        goal.target = target
        goal.type = self.goalType!.rawValue
        goal.addedDate = .now
        if let _ = try? context.save() {
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
}

enum GoalType: String, CaseIterable {
    case book = "Read A Book"
    case exercise = "Workout"
    case rest = "Take a Rest"
    
    func getImage() -> String {
        switch self {
        case .book:
            return "book"
        case .exercise:
            return "heart.fill"
        case .rest:
            return "bed.double"
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
        }
    }
}
