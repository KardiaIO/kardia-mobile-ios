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

    @IBOutlet weak var BLEDisconnected: UIImageView!
    
    @IBOutlet weak var BLEConnected: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
        

        println(view)

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
        lineChart!.addLine(data)
        lineChart!.setTranslatesAutoresizingMaskIntoConstraints(false)
        lineChart!.delegate = self
        self.view.addSubview(lineChart!)
        views["chart"] = lineChart
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==200)]", options: nil, metrics: nil, views: views))
        
//        var delta: Int64 = 4 * Int64(NSEC_PER_SEC)
//        var time = dispatch_time(DISPATCH_TIME_NOW, delta)
//        
//        dispatch_after(time, dispatch_get_main_queue(), {
//            if let bleService = btDiscoverySharedInstance.bleService {
//                self.lineChart!.clear()
//                println("foo")
//            }
//        });
        
        // Listen for incoming data from Bluetooth
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("drawGraph:"), name: GotBLEDataNotification, object: nil)
    }

    
    override func shouldAutorotate() -> Bool {
        return false
    }   
    
    func connectionChanged(notification: NSNotification) {
        // Connection status changed. Indicate on GUI.
        let userInfo = notification.userInfo as [String: Bool]
        
        dispatch_async(dispatch_get_main_queue(), {
            // Set image based on connection status
            if let isConnected: Bool = userInfo["isConnected"] {
                if isConnected {
                    self.BLEDisconnected.image = UIImage(named: "Bluetooth_Connected")
                } else {
                    self.BLEConnected.image = UIImage(named: "Bluetooth_Disconnected")
                }
            }
        });
    }
    


    // Callback function called when ViewController learns of incoming data

    func drawGraph(notification: NSNotification) {
        // Data passed along needs to be type converted to an array of CGFloats in order to be used by lineChart

        let data = notification.userInfo!["passData"]! as [String]
        let cgFloatData = data.map {
            CGFloat(($0 as NSString).doubleValue)
        }
        println(cgFloatData)
        
        // Draw new graph
        lineChart!.clear()
        lineChart!.addLine(cgFloatData)
        lineChart!.setTranslatesAutoresizingMaskIntoConstraints(false)
        println("before")
        println(views["chart"])
        views["chart"] = lineChart
        println("after")
        println(views["chart"])
        lineChart!.addLine(cgFloatData)
        lineChart!.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[label]-[chart(==200)]", options: nil, metrics: nil, views: views))

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

