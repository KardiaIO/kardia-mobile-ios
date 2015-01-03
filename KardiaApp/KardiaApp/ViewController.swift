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
    var statusView = UILabel()
    var lineChart: LineChart?
    var views: Dictionary<String, AnyObject> = [:]
    let uri = "http://10.6.29.229:8080/socket.io/"
    var socket: SocketIOSocket?

    @IBOutlet weak var BLEDisconnected: UIImageView!
    
    @IBOutlet weak var BLEConnected: UIImageView!

    func makeChart(data: [CGFloat]) {
        // if the chart is already defined, just clear it and add a line.
        if let chart: LineChart = lineChart {
            chart.clear();
            chart.addLine(data)
        // otherwise initialize the chart and add a line.
        } else {
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println(ISOStringFromDate(NSDate()))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance

        // Add subview for chart heading
        label.text = "Incoming Data"
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textAlignment = NSTextAlignment.Center
        self.view.addSubview(label)
        views["label"] = label
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-80-[label]", options: nil, metrics: nil, views: views))
        
        // Add subview for response code
        statusView.text = "Waiting for data"
        statusView.setTranslatesAutoresizingMaskIntoConstraints(false)
        statusView.textAlignment = NSTextAlignment.Center
        self.view.addSubview(statusView)
        views["statusView"] = statusView
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[statusView]-|", options: nil, metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-330-[statusView]", options: nil, metrics: nil, views: views))

        
        // Listen for incoming data from Bluetooth
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("processData:"), name: GotBLEDataNotification, object: nil)
        
        // Open socket connection
        var client = SocketIOClient(uri: uri, reconnect: true, timeout: 30)
        socket = client.socket("swift")
        let delegate = SocketIODelegate()
        socket!.delegate = delegate
        socket!.open()
        
        // Listen for charValue and pass to Node Server
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("socketCall:"), name: charValueNotification, object: nil)
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

    func processData(notification: NSNotification) {
        // Data passed along needs to be type converted to an array of CGFloats in order to be used by lineChart

        let data = notification.userInfo!["passData"]! as [String]        
        let cgFloatData = data.map {
            CGFloat(($0 as NSString).doubleValue)
        }
        
        // Draw graph with data
        dispatch_async(dispatch_get_main_queue()) {
            self.makeChart(cgFloatData)
        }
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
    
    /**
    * Socket.IO Connection
    */
    class SocketIODelegate: SocketIOSocketDelegate {
        
        init(){}
        
        internal func socketOnEvent(SocketIOSocket, event: String, data: AnyObject?) {
            NSLog("Socket on Event \(event), data \(data)")
        }
        
        internal func socketOnPacket(socket: SocketIOSocket, packet: SocketIOPacket) {
            NSLog("Socket on Packet \(packet)")
        }
        
        internal func socketOnOpen(socket: SocketIOSocket) {
            NSLog("Socket on open")
        }
        
        internal func socketOnError(socket: SocketIOSocket, error: String, description: String?) {
            NSLog("Socket on error: \(error)")
        }
    }
    

    func socketCall(notification: NSNotification) {

        let data = notification.userInfo!["charData"]! as String
        
        socket!.event("message", data: ["amplitude":data, "time":ISOStringFromDate(NSDate())]) { (packet: SocketIOPacket) -> Void in
            //println("Callback recieved from server")
            //println(packet.data)
        }
    
    }
}

public func ISOStringFromDate(date: NSDate) -> String {
    var dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
    return dateFormatter.stringFromDate(date).stringByAppendingString("Z")
}
    


