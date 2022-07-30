//
//  ChartsExample.swift
//  The What If
//
//  Created by Yona Harel on 10/06/2022.
//

import SwiftUI
import Charts

struct ChartValues: Identifiable {
    
    var name: String
    var value: Double
    var color: Color
    var id : String {name}
}
enum NavItem{
    case home
    case add
    case next
}
@available(iOS 16.0, *)
struct ChartsExample: View {
    var chartValues : [ChartValues] =
    [
        .init(name: "A", value: 50, color: .green),
        .init(name: "B", value: 100, color: .blue),
        .init(name: "C", value: 120, color: .orange),
        .init(name: "D", value: 150, color: .yellow),
        .init(name: "E", value: 200, color: .red)
    ]
    @State var currNavItem: NavItem = .home
    @State var isPresented: Bool = false
    @State var isPresented2: Bool = false
    var body: some View {
        NavigationStack {
            
            VStack{
                Text("Yona's Chart")
                    .font(.title2)
                    .fontWeight(.semibold)
                Divider()
                    .padding(.horizontal)
                
                Chart(chartValues) { chart in
//                        BarMark(x: .value("name", chart.name), y: .value("value", chart.value))
//                            .foregroundStyle(chart.color.opacity(1))
                        
                        RectangleMark(x: .value("name", chart.name), y: .value("value", chart.value))
                            .foregroundStyle(chart.color)
                        AreaMark(x: .value("name", chart.name), y: .value("value", chart.value))
                            .opacity(0.4)
                      
                    
                    
                }.padding()
                Button("Present sheet") {
                    isPresented.toggle()
                }
                .sheet(isPresented: $isPresented) {
                    VStack {
                     Text("It's like a collectionView")
                            .multilineTextAlignment(.center)
                            .font(.title)
                            .bold()
                        HStack {
                            ForEach(1...3, id: \.self) { _ in
                                buildView()
                            }
                        }
                    }
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
                }
                ShareLink(item: URL(string: "google.com")!) {
                    Text("Share")
                     
                }
            }.frame(height: 300)
        }
    }
}

@available(iOS 16.0, *)
extension ChartsExample {
    @ViewBuilder func buildView() -> some View {
        VStack(spacing: 5) {
            ForEach((1...4), id: \.self) { _ in
                Button {
                    isPresented2.toggle()
                } label: {
                    Text("Hello Nehora")
                        .truncationMode(.middle)
                        .padding()
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .foregroundColor(Color.cyan)
                        }
                }
                .sheet(isPresented: $isPresented2) {
                    Text("Hello Yona")
                        .truncationMode(.middle)
                        .padding()
                        .foregroundColor(.white)
                        .background {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .foregroundColor(Color.cyan)
                        }
                        .presentationDragIndicator(.visible)
                        .presentationDetents([.small ,.medium, .large])
                }
//                .frame(width: 100, height: 50)
            }
        }
    }
}
struct ChartsExample_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 16.0, *) {
            ChartsExample()
        } else {
            // Fallback on earlier versions
        }
    }
}

@available(iOS 16.0, *)
extension PresentationDetent {
    static let small = Self.height(150)
}
