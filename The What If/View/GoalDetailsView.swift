//
//  GoalDetailsView.swift
//  The What If
//
//  Created by Yona Harel on 28/05/2022.
//

import SwiftUI

struct GoalDetailsView: View {
    var goalColor: Color = .blue
    @State var numberOfPages = "\(230)"
    @State var pagesRead = "\(0)"
    
    var progress: Float {
        guard let numperOfPages = Int(numberOfPages),
              let read = Int(pagesRead),
        numperOfPages > 0 else { return 0 }
        return Float( Double(read) / Double(numperOfPages))
    }
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
            Text("Reading The Catcher in the Rye")
                .foregroundColor(.white)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                
                Text("Progress:")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                if #available(iOS 16, *){
                    Gauge(value: 0.7, in: 0...1) {
                    }
                    .gaugeStyle(.linearCapacity)
                    .tint(.white)
                    
                    
                } else {
                    ProgressBar(progress: progress)
                        .frame(width: 80)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background{
                LinearGradient(
                    colors: [
                        goalColor.opacity(1),
                        goalColor.opacity(0.75),
                        goalColor.opacity(0.5),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
//            .ignoresSafeArea()
            List {
                Label {
                    VStack(alignment: .leading, spacing: 10){
                        Text("Total number of pages")
                        TextField("Enter number", text: $numberOfPages)
                    }
                } icon: {
                    Image(systemName: "book").renderingMode(.template)
                }
                
                Label {
                    VStack(alignment: .leading, spacing: 10){
                        Text("Pages Read")
                        TextField("Enter number", text: $pagesRead)
                    }
                } icon: {
                    Image(systemName: "book").renderingMode(.template)
                }
            }
        }
  
      
    }
}

struct GoalDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalDetailsView()
    }
}
