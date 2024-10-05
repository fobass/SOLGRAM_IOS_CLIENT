//
//  QuoteView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/23/24.
//

import SwiftUI


struct SearchBar: View {
    @Binding var searchText: String
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search", text: $searchText)
                .font(Font.system(size: 18))
                .padding(3)
        }
        .padding(5)
        .background(colorScheme == .dark ? Color.gray.opacity(0.25) : Color.gray.opacity(0.05))
        .cornerRadius(10)
    }
}




struct QuoteView: View {
    @Binding var selection: Int
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var instrumentStore: InstrumentStore
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedFilter: String = "All"
 
    var body: some View {
        VStack{
            SearchBar(searchText: $instrumentStore.searchText)
            Spacer(minLength: 20)
            VStack{
                HStack {
                    // "All" Button
                    Button(action: {
                        selectedFilter = "Fav"
                    }, label: {
                        Image(systemName: selectedFilter == "Fav" ? "star.fill" : "star")
                            .padding(5)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selectedFilter == "Fav" ? Color.white : Color.secondary)
                            .background(selectedFilter == "Fav" ? Color.blue : Color.gray.opacity(0.1))
                    })
                    .cornerRadius(5)
                    .padding(.leading, 10)
                    Button(action: {
                        selectedFilter = "All"
                        self.instrumentStore.fetch()
                    }, label: {
                        Text("All")
                            .frame(width: 50)
                            .font(.system(size: 12, weight: .regular))
                            .padding(5)
                            .foregroundColor(selectedFilter == "All" ? Color.white : Color.secondary)
                            .background(selectedFilter == "All" ? Color.blue : Color.gray.opacity(0.1))
                    })
                    .cornerRadius(5)
                    
                    Button(action: {
                        selectedFilter = "Top Gainer"
                        self.instrumentStore.fetchTopGainers()
                    }, label: {
                        Text("Top Gainer")
                            .font(.system(size: 12, weight: .regular))
                            .padding(5)
                            .foregroundColor(selectedFilter == "Top Gainer" ? Color.white : Color.secondary)
                            .background(selectedFilter == "Top Gainer" ? Color.blue : Color.gray.opacity(0.1))
                    })
                    .cornerRadius(5)

                    Button(action: {
                        selectedFilter = "Top Loser"
                        self.instrumentStore.fetchTopLosers()
                    }, label: {
                        Text("Top Loser")
                            .font(.system(size: 12, weight: .regular))
                            .padding(5)
                            .foregroundColor(selectedFilter == "Top Loser" ? Color.white : Color.secondary)
                            .background(selectedFilter == "Top Loser" ? Color.blue : Color.gray.opacity(0.1))
                    })
                    .cornerRadius(5)
                   
                    Spacer()

                    Button(action: {
                        selectedFilter = "Filter"
                    }, label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .padding(5)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selectedFilter == "Filter" ? Color.white : Color.secondary)
                            .background(selectedFilter == "Filter" ? Color.blue : Color.gray.opacity(0.1))
                    })
                    .cornerRadius(5)
                    .padding(10)
                }
                    
                
                
                ForEach($instrumentStore.searchResults, id: \.id) { $item in
                    NavigationLink(destination: QuoteDetailView(selectTradeTab: $selection, instrument: item).environmentObject(instrumentStore).environmentObject(appData)) {
                        HStack(alignment: .center){
                            HStack{
                                Image("bitcoin-cryptocurrency48x48")
                                    .padding([.leading], 5)
                                VStack(alignment: .leading){
                                    Spacer()
                                    Text(item.code)
                                        .lineLimit(1)
                                        .font(.system(size: 14, weight: .medium))
                                    Text("\(item.volume.abbreviated())")
                                        .font(Font.system(size: 12))
                                        .foregroundColor(Color.secondary)
                                    Spacer()
                                }
                                .foregroundColor(Color.primary)
                               
                                Spacer()
                                VStack{
                                    Sparkline(points: item.spark, box: false)
                                     .stroke(item.change > 0 ? Color.green : Color.red, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                                     .frame(width: 70, height: 20)
                                     .padding(.vertical)
                                }
                                VStack(alignment: .leading) {
                                    VStack{
                                        HStack{
                                            Spacer()
                                            VStack {
                                                Text(String(format: "%.2f%", item.change))
                                                    .padding(3)
                                                    .foregroundColor(.white)
                                            }
                                            .frame(width: 50)
                                            .background(item.change > 0 ? Color.green : Color.red)
                                            .cornerRadius(5)
                                            .font(Font.system(size: 10))
                                        }
                                        HStack{
                                            Spacer()
                                            Text("\(item.last_price, specifier: "%.2f")")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color.primary)
                                        }
                                    }
                                    .padding(.trailing, 10)
                                }
                                .frame(width: 100)
                                
                            }
                            
                        }
                    }
                    
                }
                
            }
            .background(colorScheme == .dark ? Color.gray.opacity(0.25) : Color.gray.opacity(0.05))
            .cornerRadius(10)
            .padding(.bottom, 5)
//            .shadow(color: Color.gray.opacity(0.4),  radius: 3)
//            .onAppear() {
//                self.instrumentStore.fetch()
//            }
            
        }
    }
    
}


struct Sparkline: Shape {
    
    var points: [SparkPoint]
    var box: Bool = false
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        if points.isEmpty { return path }
        
        // Sort points by x values
        let sPoints = points.sorted { $0.x < $1.x }
        
        // Get the highest X and Y values
        let maxYCoord = sPoints.map { $0.y }.max() ?? 1
        let maxXCoord = sPoints.map { $0.x }.max() ?? 1
        
        // Create a scale factor to resize the chart based on maximum values
        let xScale: CGFloat = rect.maxX / CGFloat(maxXCoord)
        let yScale: CGFloat = rect.maxY / CGFloat(maxYCoord)
        
        // Start the path at the first point
        let startPoint = CGPoint(x: rect.minX, y: rect.maxY - (CGFloat(sPoints[0].y) * yScale))
        path.move(to: startPoint)
        
        // Iterate through points and draw a quadratic curve between them
        for index in 1..<sPoints.count {
            let currentPoint = CGPoint(
                x: rect.minX + CGFloat(sPoints[index].x) * xScale,
                y: rect.maxY - CGFloat(sPoints[index].y) * yScale
            )
            
            let previousPoint = CGPoint(
                x: rect.minX + CGFloat(sPoints[index - 1].x) * xScale,
                y: rect.maxY - CGFloat(sPoints[index - 1].y) * yScale
            )
            
            // Calculate control point for smoother transition (midpoint between two points)
            let midPoint = CGPoint(
                x: (previousPoint.x + currentPoint.x) / 2,
                y: (previousPoint.y + currentPoint.y) / 2
            )
            
            // Add a smooth curve using the midpoint as control
            path.addQuadCurve(to: midPoint, control: previousPoint)
            path.addQuadCurve(to: currentPoint, control: midPoint)
        }
        
        // Optionally draw a bounding box
        if box {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        }
        
        return path
    }
}

#Preview {
    QuoteView(selection: .constant(0)).environmentObject(AppData()).environmentObject(InstrumentStore())
//    Chart2()
}
