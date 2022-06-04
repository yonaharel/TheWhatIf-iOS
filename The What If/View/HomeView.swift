//
//  HomeView.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

struct HomeView: View {

    @State private var midY: CGFloat = 0.0
    @State private var headerText = "Your Goals"
    @Namespace var animation
    @State var selectedCard: Goal?
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
                        
                        if let selectedCard = selectedCard {
                            buildCardDetails(selected: selectedCard)
//                                .animation(.easeInOut(duration: 0.5).delay(0.5), value: selectedCard)
//                                .matchedGeometryEffect(id: "CARD", in: animation)
                                .id("SELECTED")
                        } else {
                            buildGoalGrid(proxy: proxy)
                                .padding(.bottom, 5)
                                .onChange(of: selectedCard) { newValue in
                                    if newValue != nil {
                                        withAnimation {
                                            scrollProxy.scrollTo("SELECTED", anchor: .top)
                                        }
                                    }
                                }
                             
                        }
                    }
                }
                .sheet(isPresented: $goalVM.isAddingNewGoal, onDismiss: {
                    if goalVM.isDeleted {
                        self.selectedCard = nil
                    }
                    goalVM.resetGoalData()

                }) {
                    AddNewGoal().environmentObject(goalVM)
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
    func buildCardDetails(selected: Goal) -> some View{
        VStack(spacing: 5) {
            HStack{
                Image(systemName: "pencil")
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        self.goalVM.editGoal = selected
                        self.goalVM.isAddingNewGoal = true
                        self.goalVM.setupGoal()
                    }
                Spacer()
                Image(systemName: "xmark")
                    .padding()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.selectedCard = nil
                        }
                    }
            }
            GoalCard(goal: selected)
                .padding()
            
            Group {
                VStack(alignment: .leading){
                    Text("Your goal is \(selected.title ?? "")")
                        .font(.title3.bold())
                    if let date = selected.addedDate{
                        Text("You added this goal in \(date.formatted(date: .abbreviated, time: .omitted)) at \(date.formatted(date: .omitted, time: .shortened))")
                            .font(.title3.bold())
                    }
                    
                    Text("Your Progress is \(NSNumber(value: selected.getProgress()).getPercentage())")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            //            .animation(.easeInOut(duration: 1).delay(1))
            
        }
    }
    
    @ViewBuilder func buildGoalGrid(proxy: GeometryProxy) -> some View {
        
        let width = (proxy.size.width / 2) - 10
        let colums = [
            GridItem(.fixed(width)),
            GridItem(.fixed(width)),
        ]
        
        LazyVGrid(columns: colums) {
            
            DynamicFilteredView { (goal: Goal) in
                GoalCard(goal: goal)
                    .onTapGesture {
                        withAnimation {
                            selectedCard = goal
                        }
                    }
            } emptyView: {
                VStack{
                    Image(systemName: "plus.square.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            goalVM.isAddingNewGoal = true
                        }
                    Text("No Goals Right now, add new one")
                        .multilineTextAlignment(.center)
                }
                .offset(x: 100, y: 200)
            }
            
        }
        
    }
    
    
    @ViewBuilder
    func GoalCard(goal: Goal) -> some View {
        let type = GoalType(rawValue: goal.type ?? "") ?? .book
        let color: Color = type.goalColor
        VStack(alignment: .center, spacing: 20){
            
            Image(systemName: type.getImage())
                .resizable()
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
            
            
            Text(goal.title?.uppercased() ?? "")
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.white)
                .frame(height: 80)
            
            //            Text("Your Progress")
            //                .font(.callout)
            //                .fontWeight(.semibold)
            //                .foregroundColor(Color.white)
            //                .padding()
            ProgressBar(progress: goal.getProgress())
                .frame(width: 60, height: 60)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background{
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(  LinearGradient(
                    colors: [
                        color.opacity(1),
                        color.opacity(0.75),
                        color.opacity(0.5),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
        }
        .contentShape(Rectangle())
        .matchedGeometryEffect(id: goal.objectID, in: animation)
        .contextMenu {
            Button {
                self.goalVM.editGoal = goal
                self.goalVM.setupGoal()
                self.goalVM.isAddingNewGoal = true
            } label: {
                Label("Edit Goal", systemImage: "pencil")
            }
            Button(role: .destructive) {
                withAnimation{
                    env.managedObjectContext.delete(goal)
                    try? env.managedObjectContext.save()
                    selectedCard = nil
                }
            } label: {
                Label("Delege Goal", systemImage: "trash")
            }
        }
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
extension NSNumber {
    func getPercentage() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0 // You can set what you want
        return formatter.string(from: self)!
    }
}

extension Goal {
    func getProgress() -> Float {
        Float(progress / target)
    }
}
