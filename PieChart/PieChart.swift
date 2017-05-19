//
//  PieChart.swift
//  PieChart
//
//  Created by Dharay Mistry on 5/17/17.
//  Copyright © 2017 Dharay Mistry. All rights reserved.
//

import Foundation
import UIKit

import CorePlot

public class PieChart: UIView, CPTPieChartDataSource, CPTPieChartDelegate {
    
    public var pieView : CPTGraphHostingView!
    let dataList = ["Red","Blue"]
    public var graph : CPTXYGraph!
    var weightList : [Int] = [500,500]
    var finalWeightList : [Int] = [75,25]
    let animationDuration = 1
    var tempWeights:[Int] = [0,0]
    var operatingFlag = false
    public var wedgeArray :[Wedge] = []
    private var wedgeExceptionArray:[Int] = []
    var theFrame :CGRect!
    
    public override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        theFrame = frame
        commominit()
        self.wedgeArray = [Wedge(title: "Empty", weight: 10)]
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commominit()
    }
    public convenience init(frame: CGRect,data : [Wedge]) {
        self.init(frame: frame)
        if data.count == 0{self.wedgeArray = [Wedge(title: "Empty", weight: 10)];return}
        self.wedgeArray = data
        self.tempWeights = Array.init(repeating: 0, count: wedgeArray.count)
    }
    func commominit(){
        pieView = CPTGraphHostingView(frame: CGRect(x: 0, y: 0, width: theFrame.width, height: theFrame.height))
        
        
        
        //        pieView.translatesAutoresizingMaskIntoConstraints = false
        pieView.allowPinchScaling = false
        pieView.backgroundColor = .cyan
        
        // 1 - Create and configure the graph
        graph = CPTXYGraph(frame: pieView.bounds)
        pieView.hostedGraph = graph
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
        graph.title = "ColouredPie!"
        graph.titleTextStyle = textStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top
        
        
        // 2 - Create the chart
        let pieChart = CPTPieChart()
        pieChart.delegate = self
        pieChart.dataSource = self
        pieChart.pieRadius = (min(pieView.bounds.size.width, pieView.bounds.size.height) * 0.7) / 2
        pieChart.identifier = NSString(string: graph.title!)
        pieChart.startAngle = CGFloat(0)
        pieChart.sliceDirection = .clockwise
        pieChart.labelOffset = -0.6 * pieChart.pieRadius
        
        // 3 - Configure border style
        let borderStyle = CPTMutableLineStyle()
        borderStyle.lineColor = CPTColor.white()
        borderStyle.lineWidth = 2.0
        pieChart.borderLineStyle = borderStyle
        
        pieChart.labelTextStyle = textStyle
        
        // 5 - Add chart to graph
        graph.add(pieChart)
        
        self.addSubview(pieView)
        
    }
    
    public func animateNewData(newWeights : [Int]) {
        
        if newWeights.count != wedgeArray.count {print("counts not equal");return}
        if operatingFlag == true{return}
        finalWeightList = newWeights
        weightList = []
        self.wedgeExceptionArray = []
        for i in self.wedgeArray{
            weightList.append(i.weight)
        }
        operatingFlag = true
        
        if configureTempArray() == false{return}
        Timer.scheduledTimer(timeInterval: TimeInterval(animationDuration/max(abs(tempWeights.max()!),abs(tempWeights.min()!))), target: self, selector: #selector(animatePie), userInfo: nil, repeats: true)
        
    }
    
    func animatePie(timer: Timer){
        if finalWeightList == weightList {
            print("returned")
            tempWeights = Array(repeating: 0, count: weightList.count)
            timer.invalidate()
            operatingFlag = false
            return
        }else{
            
            for i in 0..<weightList.count{
                if weightList[i] == finalWeightList[i] && !self.wedgeExceptionArray.contains(i){
                    self.wedgeExceptionArray.append(i)
                }
                if tempWeights[i] != 0 && !self.wedgeExceptionArray.contains(i){
                    weightList[i] += (tempWeights[i])/abs(tempWeights[i])
                    wedgeArray[i].weight += (tempWeights[i])/abs(tempWeights[i])
                }
            }
            print(weightList)
            pieView.hostedGraph?.reloadData()
            
        }
        
    }
    
    func configureTempArray() -> Bool  {
        print(weightList.count,finalWeightList.count)
        
        if finalWeightList == weightList {
            print("returned")
            tempWeights = Array(repeating: 0, count: weightList.count)
            return false
        }
        
        if tempWeights.min() == 0 && tempWeights.max() == 0{
            
            for i in 0..<weightList.count{
                tempWeights[i] = Int((finalWeightList[i] - weightList[i]) )
                
            }
            print("temparray configured",tempWeights,finalWeightList,weightList)
            return true
        }
        return false
    }
    
    public func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(self.wedgeArray.count)
    }
    
    public func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        
        let weight = self.wedgeArray[Int(idx)].weight
        return weight
    }
    
    public func dataLabel(for plot: CPTPlot, record idx: UInt) -> CPTLayer? {
        
        let layer = CPTTextLayer(text: self.wedgeArray[Int(idx)].title)
        layer.textStyle = plot.labelTextStyle
        return layer
    }
    
    public func sliceFill(for pieChart: CPTPieChart, record idx: UInt) -> CPTFill? {
        
        return CPTFill(color: CPTColor(cgColor: self.wedgeArray[Int(idx)].backgroundColor.cgColor))
        
    }
    
}



