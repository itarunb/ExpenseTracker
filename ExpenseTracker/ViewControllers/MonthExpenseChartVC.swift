//
//  MonthExpenseChartVC.swift
//  ExpenseTracker
//
//  Created by Tarun Bhargava on 04/01/19.
//  Copyright © 2019 expenseTracker. All rights reserved.
//

import CorePlot


//Reference : https://www.raywenderlich.com/1057-core-plot-tutorial-getting-started

class MonthExpenseChartVC: UIViewController {

    @IBOutlet weak var hostView: CPTGraphHostingView?
    private var noResults: Bool {
        return monthExpenseArray == nil ? true : (monthExpenseArray?.count == 0)
    }
    var chartTitle : String?
    var monthExpenseArray : [[expenseTypes : Int]]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hostView?.hostedGraph?.title = chartTitle
        hostView?.hostedGraph?.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        initPlot()
    }
    
    
    func initPlot() {
        configureHostView()
        configureGraph()
        configureChart()
        configureLegend()
    }
    
    func configureHostView() {
        hostView?.allowPinchScaling = false
    }
    
    func configureGraph() {
        
        guard let validHostView = hostView else {
            return
        }
        
        // 1 - Create and configure the graph
        let graph = CPTXYGraph(frame: (validHostView.bounds))
        validHostView.hostedGraph = graph
        graph.paddingLeft = 0.0
        graph.paddingTop = 0.0
        graph.paddingRight = 0.0
        graph.paddingBottom = 0.0
        graph.axisSet = nil
        
        // 2 - Create text style
        let textStyle: CPTMutableTextStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.black()
        textStyle.fontName = "HelveticaNeue-Bold"
        textStyle.fontSize = 16.0
        textStyle.textAlignment = .center
        
        // 3 - Set graph title and text style
        graph.title = chartTitle != nil ? chartTitle! : "Month Year"
        graph.titleTextStyle = textStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top

    }
    
    func configureChart() {
        guard let validHostView = hostView else {
            return
        }

        // 1 - Get a reference to the graph
        let graph = validHostView.hostedGraph!
        
        // 2 - Create the chart
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(validHostView.bounds.size.width, validHostView.bounds.size.height) * 0.7) / 2
        pieChart.identifier = NSString(string: graph.title!)
        pieChart.startAngle = CGFloat(Double.pi / 4)
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = -0.6 * pieChart.pieRadius
        
        // 3 - Configure border style
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineColor = CPTColor.white()
        borderStyle.lineWidth = 2.0
        pieChart.borderLineStyle = borderStyle
        
        // 4 - Configure text style
        let textStyle = CPTMutableTextStyle()
        textStyle.color = CPTColor.white()
        textStyle.textAlignment = .center
        pieChart.labelTextStyle = textStyle
        
        // 5 - Add chart to graph
        graph.add(pieChart)
    }
    
    func configureLegend() {
    }

    
}



extension MonthExpenseChartVC: CPTPieChartDataSource, CPTPieChartDelegate {
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return noResults ? 1 :UInt(monthExpenseArray!.count)
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        if noResults && plot.numberOfFields() == 1 {
            return 1
        }
        
        guard let validArray = monthExpenseArray,
            idx < validArray.count else {
                return 0
        }
    
        return validArray[Int(idx)].values.first ?? 0
    }
    
    func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        if noResults && plot.numberOfFields() == 1 {
            let layer = CPTTextLayer(text: String("No\n Expenses"))
            layer.textStyle = plot.labelTextStyle
            return layer
        }


        guard let validArray = monthExpenseArray,
            idx < validArray.count else {
                return nil
        }
        
        if let category = validArray[Int(idx)].keys.first {
            if let stringForCategory = enumDict[category] {
                if let amount  = validArray[Int(idx)].values.first {
                    let layer = CPTTextLayer(text: String(format:"\(stringForCategory)\n\(amount)"))
                    layer.textStyle = plot.labelTextStyle
                    return layer
                }
            }
        }

        return nil
    }
    
//    func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
//        return nil
//    }
    
//    func attributedLegendTitle(for pieChart: CPTPieChart, record idx: UInt) -> NSAttributedString? {
//        guard let validArray = monthExpenseArray,
//            idx < validArray.count else {
//                return nil
//        }
//
//        if let category = validArray[Int(idx)].keys.first {
//            if let stringForCategory = enumDict[category] {
//                return NSAttributedString(string: stringForCategory)
//            }
//        }
//        return nil
//
//    }
    
//    func legendTitle(for pieChart: CPTPieChart, record idx: UInt) -> String? {
//        guard let validArray = monthExpenseArray,
//            idx < validArray.count else {
//                return nil
//        }
//
//        if let category = validArray[Int(idx)].keys.first {
//            if let stringForCategory = enumDict[category] {
//                return stringForCategory
//            }
//        }
//        return nil
//    }
}
