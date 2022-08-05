//
//  EditGoalViewModel.swift
//  The What If
//
//  Created by Yona Harel on 31/07/2022.
//

import Foundation
import Shared

// MARK: - VM for editing / creating the goal
class EditGoalViewModel: ObservableObject {
    
    @Published var goalTitle: String = ""
    @Published var goalType: GoalType = .education
    @Published var goalDeadline: Date = .now
    @Published var progress: Int = 0
    @Published var progressString: String = ""
    @Published var goalString: String = ""
    
    let editGoal: Goal?
    let network = GoalNetworkManager()
    
    init(editGoal: Goal? = nil) {
        self.editGoal = editGoal
        setupGoal()
    }
    
    func deleteGoal() async -> Bool {
        do {
            guard let editGoal else { return false }
            try await _ = network.performRequest(for: .remove(id: editGoal.id.uuidString))
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    @MainActor
    func createGoal() async throws -> Goal? {
        guard let target = Int(goalString),
              let currentProgress = Int(progressString),
              target > 0 else {
            throw UserError.missingParams
        }
        let goal = Goal(
            id: editGoal?.id ?? UUID(),
            title: goalTitle,
            type: goalType,
            dueDate: goalDeadline,
            progress: currentProgress,
            target: target
        )
        
        if editGoal != nil {
            dump(goal)
            return try await network.updateGoal(goal)
        }
        
        if try await network.createGoal(goal) {
            return goal
        }
        return nil
    }
    
    //MARK: If Edit Goal is Available then Setting Existing Data
    func setupGoal() {
        if let editGoal {
            goalType = editGoal.type
            goalTitle = editGoal.title
            goalString = "\(Int(editGoal.target))"
            let currProgress = editGoal.progress
            progressString = "\(Int(currProgress))"
        }
    }
  
   
}
