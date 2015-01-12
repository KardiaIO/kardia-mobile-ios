//
//  ViewController.swift
//  KardiaApp
//
//  Created by Charlie Depman on 12/29/14.
//  Copyright (c) 2014 Kardia. All rights reserved.
//
import UIKit

let statusCodes: [String:String] = ["200":"NSR", "404":"ARR"]

class ViewController: UIViewController, LineChartDelegate, UITableViewDelegate, UITableViewDataSource {
    var statusView = UILabel()
    var lineChart: LineChart?
    var views: Dictionary<String, AnyObject> = [:]
    var socket: SocketIOClient!
    var arrhythmiaEvents: [String] = []
    var arrhythmiaTimes: [NSDate] = []
    var imgBluetoothStatus = UIImageView(image: UIImage(named:"Bluetooth-disconnected"))

    @IBOutlet var arrhythmiaTable: UITableView!
    
//    @IBOutlet weak var BLEDisconnected: UIImageView!
//    
//    @IBOutlet weak var BLEConnected: UIImageView!

    
    
    @IBOutlet weak var BPMLabel: UILabel!
    @IBOutlet weak var BPMView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set background gradient
        view.backgroundColor = UIColor.clearColor()
        var backgroundLayer = Colors().gl
        backgroundLayer.frame = view.frame
        view.layer.insertSublayer(backgroundLayer, atIndex: 0)

        // Draw polygons
        let hexagonContainerSquareSideLength = CGRectGetWidth(view.frame) / 4
        let hexagonVerticalPosition = CGRectGetHeight(view.frame) * 19 / 24
        let connectionStatusContainer = UIView(frame: CGRect(
            x: CGRectGetWidth(view.frame) * 3 / 8,
            y: hexagonVerticalPosition,
            width: hexagonContainerSquareSideLength,
            height: hexagonContainerSquareSideLength
        ))
        let connectionStatusHexagon = drawPolygonLayer(
            x: CGRectGetWidth(connectionStatusContainer.frame) / 2,
            y: CGRectGetHeight(connectionStatusContainer.frame) / 2,
            radius: CGRectGetWidth(connectionStatusContainer.frame) / 2,
            sides: 6,
            color: UIColor.blueColor()
        )
        connectionStatusContainer.layer.addSublayer(connectionStatusHexagon)
        
        let BPMContainer = UIView(frame: CGRect(
            x: CGRectGetWidth(view.frame) * 11 / 16,
            y: hexagonVerticalPosition,
            width: hexagonContainerSquareSideLength,
            height: hexagonContainerSquareSideLength
        ))
        let BPMHexagon = drawPolygonLayer(
            x: CGRectGetWidth(BPMContainer.frame) / 2,
            y: CGRectGetHeight(BPMContainer.frame) / 2,
            radius: CGRectGetWidth(BPMContainer.frame) / 2,
            sides: 6,
            color: UIColor.blueColor()
        )
        BPMContainer.layer.addSublayer(BPMHexagon)
        
        let statusViewContainer = UIView(frame: CGRect(
            x: CGRectGetWidth(view.frame) * 1 / 16,
            y: hexagonVerticalPosition,
            width: hexagonContainerSquareSideLength,
            height: hexagonContainerSquareSideLength
            
        ))
        let statusViewHexagon = drawPolygonLayer(
            x: CGRectGetWidth(statusViewContainer.frame) / 2,
            y: CGRectGetHeight(statusViewContainer.frame) / 2,
            radius: CGRectGetWidth(statusViewContainer.frame) / 2,
            sides: 6,
            color: UIColor.blueColor()
        )
        statusViewContainer.layer.addSublayer(statusViewHexagon)
        
        // Add polygons to view and give a low z-index
        view.addSubview(imgBluetoothStatus)
        view.insertSubview(connectionStatusContainer, belowSubview: imgBluetoothStatus)
        view.insertSubview(BPMContainer, belowSubview: imgBluetoothStatus)
        view.insertSubview(statusViewContainer, belowSubview: imgBluetoothStatus)

        views["connectionStatusContainer"] = connectionStatusContainer
        views["BPMContainer"] = BPMContainer
        views["statusViewContainer"] = statusViewContainer
        views["imgBluetoothStatus"] = imgBluetoothStatus

        // Center BT status view in hexagon
        imgBluetoothStatus.setTranslatesAutoresizingMaskIntoConstraints(false)
        var imgBTConstraintX = NSLayoutConstraint(item: imgBluetoothStatus, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: connectionStatusContainer, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        var imgBTConstraintY = NSLayoutConstraint(item: imgBluetoothStatus, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: connectionStatusContainer, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        view.addConstraints([imgBTConstraintX, imgBTConstraintY])
        
        // Register table cell behavior
        self.arrhythmiaTable?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Add listener for change in BT connection status
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("connectionChanged:"), name: BLEServiceChangedStatusNotification, object: nil)
        
        
        
        // Start the Bluetooth discovery process
        btDiscoverySharedInstance
        
        // Add subview for response code
        statusView.font = UIFont(name: "STHeitiTC-Light", size:30)
        statusView.textColor = UIColor.whiteColor()
        statusView.text = "N/A"
        statusView.setTranslatesAutoresizingMaskIntoConstraints(false)
        statusView.textAlignment = NSTextAlignment.Center
        self.view.addSubview(statusView)
        views["statusView"] = statusView
        var statusViewConstraintX = NSLayoutConstraint(item: statusView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: statusViewContainer, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        var statusViewConstraintY = NSLayoutConstraint(item: statusView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: statusViewContainer, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
        view.addConstraints([statusViewConstraintX, statusViewConstraintY])
        
        // Add timer to redraw arrhythmia events table
        var redrawTableTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("redrawTable"), userInfo: nil, repeats: true)
        
        // Listen for incoming data from Bluetooth
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("processData:"), name: GotBLEDataNotification, object: nil)
        
        // Open socket connection
        socket = SocketIOClient(socketURL: "http://10.8.26.235:8080")
//        socket = SocketIOClient(socketURL: "http://kardia.io")
        socket.connect()
        
        socket.on("node.js") {data in
            // Interpret status code and display appropriate description
            if let statusCode: NSObject = data!["statusCode"]! as? NSObject {
                let code = statusCode as String
                let description = statusCodes[String(code)]!
                //Update status view on main thread to get view to update
                dispatch_async(dispatch_get_main_queue()) {
                    if self.statusView.text?.rangeOfString("Arrhythmia") == nil && code == "404" {
                        let time = NSDate()
                        self.arrhythmiaTimes.append(time)
                    }
                    self.statusView.text = "Status: \(description)"
                    if code == "200" {
                        self.statusView.textColor = UIColor.whiteColor()
                    }
                    if code == "404" {
                        self.statusView.textColor = UIColor.redColor()
                    }
                }
            }
            
            // Display BPM
            if let BPM: NSObject = data!["heartRate"]! as? NSObject {
                let BPMnum = BPM as String
                dispatch_async(dispatch_get_main_queue()) {
                    self.BPMView.text = BPMnum
                }
            }
        }
        
        
        // Listen for charValue and pass to Node Server
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("socketCall:"), name: charValueNotification, object: nil)
    }
    
    
    func redrawTable() {
        self.arrhythmiaEvents = self.arrhythmiaTimes.map {
            timeAgoSinceDate($0, false)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.arrhythmiaTable.reloadData()
        }
    }
    
    /**
    * Table View Protocol Methods
    */
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrhythmiaEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.arrhythmiaTable?.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = self.arrhythmiaEvents[indexPath.row]
        cell.textLabel?.font = UIFont(name: "STHeitiTC-Light", size: 16)
        dispatch_async(dispatch_get_main_queue()) {
            cell.backgroundColor = UIColor.clearColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
                    self.imgBluetoothStatus.image = UIImage(named: "Bluetooth-connected")
                } else {
                    self.imgBluetoothStatus.image = UIImage(named: "Bluetooth-disconnected")
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
        
        // Draw graph with data. Dispatch_async is necessary to force execution on the main thread, which is responsible for UI (otherwise view will not update)
        dispatch_async(dispatch_get_main_queue()) {
            self.makeChart(cgFloatData)
        }
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    


    /**
    * Line Chart functionality
    */
    
    // Draw line when data is received
    func makeChart(data: [CGFloat]) {
        // if the chart is already defined, just clear it and add a line.
        if var chart: LineChart = lineChart {
            self.lineChart?.clear()
            chart.clear()
            chart.addLine(data)
            // otherwise initialize the chart and add a line.
        } else {
            lineChart = LineChart()
            lineChart!.animationEnabled = false
            lineChart!.gridVisible = false
            lineChart!.dotsVisible = false
            lineChart!.axesVisible = false
            lineChart!.lineWidth = 3
            lineChart!.axisInset = -30
            lineChart!.addLine(data)
            lineChart!.setTranslatesAutoresizingMaskIntoConstraints(false)
            lineChart!.delegate = self
            self.view.addSubview(lineChart!)
            views["chart"] = lineChart
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[chart]-|", options: nil, metrics: nil, views: views))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[statusView]-60-[chart(==100)]", options: nil, metrics: nil, views: views))
        }
    }
    
    /**
    * Line chart delegate method.
    */
    func didSelectDataPoint(x: CGFloat, yValues: Array<CGFloat>) {

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
    
    // Callback function for BLE incoming data that transmits to server
    func socketCall(notification: NSNotification) {
        var jsonData = notification.userInfo!["charData"]! as String
            
        socket.emit("message", args: [
            "amplitude": jsonData,
            "time": ISOStringFromDate(NSDate())
        ])
    
    }
}

class Colors {
    let colorTop = UIColor(red: 60.0/255.0, green: 120.0/255.0, blue: 216.0/255.0, alpha: 1.0).CGColor
    let colorBottom = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0).CGColor
    
    let gl: CAGradientLayer
    
    init() {
        gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
    }
}