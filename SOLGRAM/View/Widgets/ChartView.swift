//
//  ChartView.swift
//  SOLGRAM
//
//  Created by Ernist Isabekov on 1/25/24.
//

import SwiftUI
import Charts
import DGCharts


   
struct CandleChartView: UIViewRepresentable {
    @Binding var candleData: [CandleChartDataEntry]
    var shouldHideData: Bool

    func makeUIView(context: Context) -> CandleStickChartView {
        let chartView = CandleStickChartView()
        chartView.delegate = context.coordinator
        chartView.dragEnabled = true
        chartView.pinchZoomEnabled = true
        chartView.setScaleEnabled(true)
        
        chartView.maxVisibleCount = 100
        chartView.xAxis.labelPosition = .bottom
        chartView.rightAxis.enabled = true
        chartView.leftAxis.enabled = false
        chartView.rightAxis.labelPosition = .insideChart
        chartView.xAxis.setLabelCount(5, force: false)
        chartView.isUserInteractionEnabled = true

//        context.coordinator.addTapGesture(to: chartView)
        return chartView
    }
    
    class Coordinator: NSObject, ChartViewDelegate {
        var parent: CandleChartView

        init(parent: CandleChartView) {
            self.parent = parent
        }

        func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, dataSetIndex: Int, highlight: Highlight) {
            print("Chart value selected: \(entry)")  // Check if this is printed
            // The rest of your code...
        }

        
        func chartValueNothingSelected(_ chartView: ChartViewBase) {
            print("No value selected")  // Log when nothing is selected
        }
        
//        func addTapGesture(to chartView: CandleStickChartView) {
//               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
//               chartView.addGestureRecognizer(tapGesture)
//           }

//       @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
//           let location = gesture.location(in: gesture.view)
//           let highlight = highlightForTouch(location: location, chartView: gesture.view as! CandleStickChartView)
//           if let highlight = highlight {
//               chartView.highlightValue(highlight)
//           }
//       }
//
//       private func highlightForTouch(location: CGPoint, chartView: CandleStickChartView) -> Highlight? {
//           let x = chartView.xAxis.valueForTouch(at: location.x)
//           let y = chartView.getYForTouch(location.y)
//           return Highlight(x: x, y: y, dataSetIndex: 0)  // Adjust based on your dataset index
//       }
    }

    // Required methods for UIViewRepresentable
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func showDetailAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Candlestick Details", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(alert, animated: true, completion: nil)
            }
        }
    }


    func updateUIView(_ uiView: CandleStickChartView, context: Context) {
        if shouldHideData {
            uiView.data = nil
        } else {
            let dataSet = CandleChartDataSet(entries: self.candleData, label: "Candlestick Data")

            guard let minValue = candleData.map({ $0.low }).min(),
                  let maxValue = candleData.map({ $0.high }).max() else {
                uiView.data = nil
                return
            }

            let buffer: Double = (maxValue - minValue) * 10
            uiView.rightAxis.axisMinimum = minValue
            uiView.rightAxis.axisMaximum = maxValue + buffer

            dataSet.colors = [NSUIColor(white: 0.8, alpha: 1)]
            dataSet.drawIconsEnabled = false
            dataSet.shadowColor = .darkGray
            dataSet.decreasingColor = .red
            dataSet.decreasingFilled = true
            dataSet.increasingColor = .green
            dataSet.increasingFilled = true
            dataSet.barSpace = 0.5
            dataSet.shadowWidth = 1.5
            dataSet.drawValuesEnabled = false
            // Assign data to the chart
            let data = CandleChartData(dataSet: dataSet)
            uiView.data = data
            uiView.xAxis.valueFormatter = DefaultAxisValueFormatter { value, axis in
                let date = Date(timeIntervalSince1970: value * 3600)  // Scaling timestamp
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"  // You can adjust this as needed
                return dateFormatter.string(from: date)
            }

            uiView.xAxis.labelPosition = .bottom
            uiView.xAxis.setLabelCount(5, force: false)  // Or a different number based on data

            uiView.setVisibleXRange(minXRange: 1, maxXRange: Double(candleData.count))
            uiView.setScaleMinima(0.1, scaleY: 0.1)
            uiView.zoomToCenter(scaleX: 0.1, scaleY: 1)

        }
    }


}

struct ChartDataEntry: Identifiable {
    let id = UUID()
    var entry: CandleChartDataEntry
}

struct ChartView: View {
    var instrumnet_id: Int
    @EnvironmentObject var instrumentStore: InstrumentStore
    var body: some View {
        VStack {
            CandleChartView(candleData: $instrumentStore.candle, shouldHideData: false)
        }
        .onAppear() {
            instrumentStore.getChartDataById(id: instrumnet_id, interval: 1)
        }
        .onDisappear() {
            instrumentStore.clearChart()
        }
        
    }
}

            

#Preview {
    ChartView(instrumnet_id: 1).environmentObject(InstrumentStore())
}
