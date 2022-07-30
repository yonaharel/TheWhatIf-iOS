//
//  AddNewGoal.swift
//  The What If
//
//  Created by Yona Harel on 29/05/2022.
//

import SwiftUI
import Combine

struct AddNewGoal: View {
    @EnvironmentObject var viewModel: GoalViewModel
    @Environment(\.self) var env
    @Environment(\.colorScheme) var scheme
    @State var savePressed: Bool = false
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    @State private var finishedWithError: Bool = false

    var textColor: Color {
        scheme == .dark ? .white : .black
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            buildTitleAndButtons()
            
            //MARK: Body
            
            Text("Goal Title")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.goalTitle.isEmpty && savePressed ? .red : textColor)
            TextField("Goal Title", text: $viewModel.goalTitle)
                .frame(maxWidth: .infinity)
                .padding(.top, 10)
            
            
            Divider()
            
            HStack {
                Text("Goal Type")
                    .font(.title3)
                    .fontWeight(.light)
                    .foregroundColor(textColor)
                Spacer()
                Menu {
                    let goalTypes = GoalType.allCases
                    
                    ForEach(goalTypes, id: \.self) { type in
                        Button {
                            viewModel.goalType = type
                        } label: {
                            Label(type.rawValue, systemImage: type.getImage())
                        }
                    }
                    
                } label: {
                    if let goalType = viewModel.goalType {
                        Label(goalType.rawValue, systemImage: goalType.getImage())
                            .foregroundColor(textColor)
                    }else {
                        Text("Choose A Goal Type")
                            .foregroundColor(textColor)
                    }
                    
                }
                
            }
            
            if let goalType = viewModel.goalType {
                Divider()
                goalInputFields(goalType: goalType)
            }
            SaveButton("Save Goal", action: saveGoal)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .sheet(isPresented: self.$isImagePickerDisplay) {
            ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
        }
        .alert("Couldn't create a goal", isPresented: $finishedWithError) {
            Button("OK") {
                finishedWithError = false
            }
            Button("Retry") {
                finishedWithError = false
                saveGoal()
            }
        }
    }
    
    func filterToNumbers(newValue: String) -> String {
        let filtered = newValue.filter(Set("0123456789").contains)
        return filtered
    }
    
    private func saveGoal() {
        savePressed = true
        guard !self.viewModel.goalTitle.trimmingCharacters(in: .whitespaces).isEmpty,
              !self.viewModel.goalString.trimmingCharacters(in: .whitespaces).isEmpty,
              !self.viewModel.progressString.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        //        if viewModel.addGoal(context: env.managedObjectContext){
        //            env.dismiss()
        //        }
        Task {
            do {
                try await viewModel.createGoal(context: env.managedObjectContext)
                self.viewModel.shouldRefresh = true
                env.dismiss()
            } catch {
                print(error)
                self.finishedWithError = true
            }
        }
    }
    
    @ViewBuilder
    private func goalInputFields(goalType: GoalType) -> some View {
        let labels = goalType.getLabels()
        
        VStack(alignment: .leading, spacing: 10) {
            Text("What is your Goal?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.goalString.isEmpty && savePressed ? .red : textColor)
            TextField(labels.goalLabel, text: $viewModel.goalString)
                .keyboardType(.numberPad)
            
            
            Text("What is your progress?")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(viewModel.progressString.isEmpty && savePressed ? .red : textColor)
            TextField(labels.progressLabel, text: $viewModel.progressString)
                .keyboardType(.numberPad)
            
            
            HStack{
                Text("Add an image")
                    .fontWeight(.semibold)
                    .font(.title3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: "square.and.arrow.up")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                print("Open Images")
                self.sourceType = .camera
                self.isImagePickerDisplay.toggle()
            }
            
            
        }
    }
    
    
    @ViewBuilder
    private func buildTitleAndButtons() -> some View{
        //MARK: Header
        Text(isEditing ? "Edit Goal" : "Add Goal")
            .font(.title3.bold())
            .frame(maxWidth: .infinity)
            .overlay(alignment: .leading) {
                Button {
                    env.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                    //                            .render
                        .foregroundColor(scheme == .dark ? .white : .black)
                }
                
            }
            .overlay(alignment: .trailing){
                Button {
                    //TODO: Add a Delete Functionality
                    if let editGoal = viewModel.editGoal {
                        NotificationManager.shared.removeNotifications(for: editGoal)
                        env.managedObjectContext.delete(editGoal)
                        try? env.managedObjectContext.save()
                        env.dismiss()
                        viewModel.isDeleted = true
                    }
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .opacity(isEditing ? 1 : 0)
            }
    }
    
}

extension AddNewGoal {
    var isEditing: Bool {
        viewModel.editGoal != nil
    }
}

struct AddNewGoal_Previews: PreviewProvider {
    static var previews: some View {
        AddNewGoal()
            .environmentObject(GoalViewModel())
    }
}


struct SaveButton: View {
    var action: () -> Void
    var buttonText: String
    
    init(_ buttonText: String, action: @escaping () -> Void){
        self.action = action
        self.buttonText = buttonText
    }
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .font(.callout)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundColor(.white)
                .background{
                    Capsule()
                        .fill(.cyan)
                }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 10)
    }
}
