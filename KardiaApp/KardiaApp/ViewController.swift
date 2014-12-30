//
//  ViewController.swift
//  KardiaApp
//
//  Created by Charlie Depman on 12/29/14.
//  Copyright (c) 2014 Kardia. All rights reserved.
//

import UIKit

class ViewController: UIViewController, LineChartDelegate {
    var label = UILabel()
    var lineChart: LineChart?
    var views: Dictionary<String, AnyObject> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
        
        
        label.text = "Incoming Data"
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-80-[label]", options: nil, metrics: nil, views: views))
        
        var data: Array<CGFloat> = [4.492, 5.120, 4.440, 4.917, 5.009]
        
        lineChart = LineChart()
        lineChart!.animationEnabled = false
        lineChart!.gridVisible = false
        lineChart!.dotsVisible = false
//        lineChart!.addLine(data)
//        lineChart!.setTranslatesAutoresizingMaskIntoConstraints(false)
        lineChart!.delegate = self
        self.view.addSubview(lineChart!)
        views["chart"] = lineChart
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: nil, metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==200)]", options: nil, metrics: nil, views: views))
        
//        var delta: Int64 = 4 * Int64(NSEC_PER_SEC)
//        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
//        
//        dispatch_after(time, dispatch_get_main_queue(), {
//            if let bleService = btDiscoverySharedInstance.bleService {
//                self.lineChart!.clear()
//                println("foo")
//            }
//        });
        
        
        // Watch for incoming data from Bluetooth
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("drawGraph:"), name: GotBLEDataNotification, object: nil)
    }
    
    func drawGraph(notification: NSNotification) {
        // Got data, time to redraw the graph.
        let data = notification.userInfo!["passData"]! as [String]
        let cgFloatData = data.map {
            CGFloat(($0 as NSString).doubleValue)
        }
        println(cgFloatData)
        lineChart!.addLine(cgFloatData)
        lineChart!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==200)]", options: nil, metrics: nil, views: views))

//        let userInfo = notification.userInfo as [NSArray: String]
        
//        dispatch_async(dispatch_get_main_queue(), {
//            // Set image based on connection status
//            if let isConnected: Bool = userInfo["isConnected"] {
//                if isConnected {
//                    self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Connected")
//                    
//                    // Send current slider position
//                    self.sendPosition(UInt8( self.positionSlider.value))
//                } else {
//                    self.imgBluetoothStatus.image = UIImage(named: "Bluetooth_Disconnected")
//                }
//            }
//        });
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    /**
    * Line chart delegate method.
    */
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {
        label.text = "x: \(x)     y: \(yValues)"
    }
    
    
    
    /**
    * Redraw chart on device rotation.
    */
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        if let chart = lineChart {
            chart.setNeedsDisplay()
        }
    }

    
    
}

