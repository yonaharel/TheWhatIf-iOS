//
//  HomeView.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

struct HomeView: View {
//
    //    var goals = ["read a book", "workout1", "read a book1", "work1out", "read a book1"]
    @State private var midY: CGFloat = 0.0
    @State private var headerText = "Your Goals"
    
    var body: some View {
        NavigationView {
            GeometryReader{ proxy in
                
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        //text
                        HeaderView(headerText: self.headerText, midY: $midY)
                            .frame(height: 40, alignment: .leading)
                            .padding(.vertical, 5)
                            .padding(.leading, 10)
                        
                        HStack {
                            Button(action: {
                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.largeTitle)
                            }
                            
                            
                        }.padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 16))
                            .foregroundColor(.blue)
                        
                    } .frame(height: 40, alignment: .leading)
                        .opacity(self.midY < 70 ? 0.0 : 1.0)
                        .frame(alignment: .bottom)
                    
                    
                    buildGoalGrid(proxy: proxy)
                        .padding(.bottom, 5)
                }
//                .overlay(alignment: .bottom) {
//                    //MARK: Add Button
//                    Button {
//                    } label: {
//                        Label {
//                            Text("Create a New Goal")
//                                .font(.callout)
//                                .fontWeight(.semibold)
//                        } icon: {
//                            Image(systemName: "plus.app.fill")
//                        }
//                        .foregroundColor(.white)
//                        .padding(.vertical, 12)
//                        .padding(.horizontal)
//                        .background(.black, in: Capsule())
//                    }
//
//                    //MARK: Linear Gradient BG
//                    .padding(.vertical, 10)
//                    .frame(maxWidth: .infinity)
//                    .background {
//                        LinearGradient(colors: [
//                            .white.opacity(0.05),
//                            .white.opacity(0.5),
//                            .white.opacity(0.7),
//                            .white
//                        ], startPoint: .top, endPoint: .bottom)
//                        .ignoresSafeArea()
//                    }
//                }
                
            }
            .navigationBarTitle(self.midY < 70 ? Text(self.headerText) : Text(""), displayMode: .inline)

            .toolbar {
                if self.midY < 70 {
                    Button(action: {
                        //                                    self.action1()
                    }) {
                        Image(systemName: "plus.circle")
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }.navigationViewStyle(.stack)
          
          
        
        
    }
    
    @ViewBuilder func buildGoalGrid(proxy: GeometryProxy) -> some View {
        
        let width = (proxy.size.width / 2) - 10
        let colums = [
            GridItem(.fixed(width)),
            GridItem(.fixed(width)),
        ]
        
        LazyVGrid(columns: colums) {
            ForEach(Array(1...7), id: \.self){ goal in
                GoalCard(goal: "\(goal)", progress: 0.5)
            }
            
        }
        
    }
    
    
    @ViewBuilder
    func GoalCard(goal: String, progress: Float = 0.5) -> some View {
   
        let color: Color = {
            let colors = [Color.red, Color.blue, Color.green, Color.cyan, Color.black, .brown]
            let colorIndex = (Int(goal) ?? 0) % colors.count
            return colors[colorIndex]
        }()
        
        VStack(alignment: .center, spacing: 5){
            Text(goal.uppercased())
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
                .padding()
            Text("Your Progress")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundColor(Color.white)
                .padding()
            ProgressBar(progress: progress)
                .frame(width: 60, height: 60)
//            ProgressView("some")
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
                .animation(.linear, value: true)
//                .animation(.linear)
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