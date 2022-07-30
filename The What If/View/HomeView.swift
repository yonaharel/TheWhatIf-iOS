//
//  HomeView.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI
import Shared

struct HomeView: View {

    @State private var midY: CGFloat = 0.0
    @State private var headerText = "Your Goals"
    @Namespace var animation
    @StateObject var goalVM: GoalViewModel = .init()
    @Environment(\.self) var env
    var body: some View {
        NavigationView {
            GeometryReader{ proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    ScrollViewReader { scrollProxy in
                        
                        HStack {
                            //text
                            HeaderView(headerText: self.headerText, midY: $midY)
                                .frame(height: 40, alignment: .leading)
                                .padding(.vertical, 5)
                                .padding(.leading, 10)
                            
                            HStack {
                                Button(action: {
                                    goalVM.isAddingNewGoal = true
                                }) {
                                    Image(systemName: "plus.circle")
                                        .font(.largeTitle)
                                }
                            }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 16))
                                .foregroundColor(.blue)
                        }
                        .frame(height: 40, alignment: .leading)
                        .opacity(self.midY < 70 ? 0.0 : 1.0)
                        .frame(alignment: .bottom)
                        
                        if let selectedGoal = self.goalVM.selectedMotivation {
                            buildCardDetails(selected: selectedGoal)
                                .id("SELECTED")
                        } else {
                            buildGoalGrid(proxy: proxy)
                                .padding(.bottom, 5)
                                .onChange(of: goalVM.selectedGoal) { newValue in
                                    if newValue != nil {
                                        withAnimation {
                                            scrollProxy.scrollTo("SELECTED", anchor: .top)
                                        }
                                    }
                                }
                            
                        }
                    }
                }.sheet(isPresented: $goalVM.isAddingNewGoal, onDismiss: {
                    if goalVM.isDeleted {
                        self.goalVM.selectedGoal = nil
                    }
                    goalVM.resetGoalData()

                }) {
                    if #available(iOS 16.0, *) {
                        AddNewGoal().environmentObject(goalVM)
                            .presentationDetents([.medium, .large])
                    } else {
                        AddNewGoal().environmentObject(goalVM)
                        // Fallback on earlier versions
                    }
                }
            }
            .navigationBarTitle(self.midY < 70 ? Text(self.headerText) : Text(""), displayMode: .inline)
            .toolbar {
                if self.midY < 70 {
                    Button(action: {
                        self.goalVM.isAddingNewGoal = true
                    }) {
                        Image(systemName: "plus.circle")
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
          
          
        
        
    }
    
    @ViewBuilder
    func buildCardDetails(selected: Motivation) -> some View{
        VStack(spacing: 5) {
            HStack{
                Image(systemName: "pencil")
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
//                        self.goalVM.editGoal = selected
//                        self.goalVM.isAddingNewGoal = true
//                        self.goalVM.setupGoal()
                    }
                Spacer()
                Image(systemName: "xmark")
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.goalVM.selectedGoal = nil
                        }
                    }
            }
            GoalCard(motivation: selected, isExpanded: true)
                .padding()
            
            Group {
                VStack(alignment: .leading){
                    Text("Your goal is \(selected.title)")
                        .font(.title3.bold())
                    let date = selected.dueDate
                    if let date {
                        Text("You added this goal in \(date.formatted(date: .abbreviated, time: .omitted)) at \(date.formatted(date: .omitted, time: .shortened))")
                            .font(.title3.bold())
                    }
                    
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    self.goalVM.selectedGoal = nil
                }
            }
            .padding()
            
        }
    }
    
    @ViewBuilder func buildGoalGrid(proxy: GeometryProxy) -> some View {
        DynamicFilteredView(proxy: proxy,
                            shouldRefresh: $goalVM.shouldRefresh,
                            VM: self.goalVM) { motivation in
            GoalCard(motivation: motivation)
                .onTapGesture {
                    withAnimation {
                        self.goalVM.selectedMotivation = motivation
                    }
                }
        } emptyView: {
            VStack{
                Image(systemName: "plus.square.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        goalVM.isAddingNewGoal = true
                    }
                Text("You don't have any goals? Start Working man!")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
            .offset(y: 100)
            .padding()
        }
    }
    
    
    @ViewBuilder
    func GoalCard(motivation: Motivation, isExpanded: Bool = false) -> some View {
        let type = GoalType(from: motivation.type)
        let color: Color = type.goalColor
        VStack(alignment: .center, spacing: 20){
            
            Image(systemName: type.getImage())
                .resizable()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
            
            
            Text(motivation.title.uppercased())
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.white)
                .frame(height: 80)
            
            if isExpanded{
                if #available(iOS 16, *){
                    let progress = motivation.getProgress()
                    if progress >= 0 {
                        Gauge(value: motivation.getProgress(), in: 0...1) {
                            let percentageString = motivation.getProgress().getPercentage()
                            Text("You've made \(percentageString), You're getting closer!")
                                .multilineTextAlignment(.center)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        .gaugeStyle(.linearCapacity)
                        .tint(.white)
                    }
                } else {
                    ProgressView(value: motivation.getProgress()) {
                        Label("Some Progress", systemImage: "person.fill.checkmark")
                    }
                }
            } else {
                ProgressBar(progress: motivation.getProgress())
                    .frame(width: 60, height: 60)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            if #available(iOS 16, *){
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                
                    .fill(  LinearGradient(
                        colors: [
                            color.opacity(1),
                            color.opacity(0.75),
                            color.opacity(0.5),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).shadow(.drop(radius: 4))
                    )
            }
        }
        .contentShape(Rectangle())
        .matchedGeometryEffect(id: motivation.id, in: animation)
//        .contextMenu {
//            Button {
//                self.goalVM.editGoal = goal
//                self.goalVM.setupGoal()
//                self.goalVM.isAddingNewGoal = true
//            } label: {
//                Label("Edit Goal", systemImage: "pencil")
//            }
//            Button(role: .destructive) {
//                withAnimation{
//                    NotificationManager.shared.removeNotifications(for: goal)
//                    env.managedObjectContext.delete(goal)
//                    try? env.managedObjectContext.save()
//                    self.goalVM.selectedGoal = nil
//                }
//            } label: {
//                Label("Delege Goal", systemImage: "trash")
//            }
//        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct ProgressBar: View {
    var progress: Float
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(Color.white)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.white)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                .font(.callout)
                .bold()
                .foregroundColor(.white)
        }
    }
}


struct HeaderView: View {
    let headerText: String
    @Binding var midY: CGFloat
    var body: some View {
        GeometryReader { geometry -> Text in
            let frame = geometry.frame(in: CoordinateSpace.global)

            withAnimation(.easeIn(duration: 0.25)) {
                DispatchQueue.main.async {
                   self.midY = frame.midY
                }
            }

            return Text(self.headerText)
                .bold()
                .font(.largeTitle)
        }
    }
}
