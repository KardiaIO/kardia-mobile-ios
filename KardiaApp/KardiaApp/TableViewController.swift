//
//  TableViewController.swift
//  KardiaApp
//
//  Created by Bernie Chu on 1/13/15.
//  Copyright (c) 2015 Kardia. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

//    var arrhythmiaEvents : [String]?
    @IBOutlet var arrhythmiaTable: UITableView!
//    var arrhythmiaEvents: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.arrhythmiaTable?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        println(arrhythmiaEvents)
    }
    
    /*
    * Arrhythmia events table
    */
    
    // Register table cell behavior
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrhythmiaEvents.count

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.arrhythmiaTable?.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = arrhythmiaEvents[indexPath.row]
        cell.textLabel?.font = UIFont(name: "STHeitiTC-Light", size: 16)
        dispatch_async(dispatch_get_main_queue()) {
            cell.backgroundColor = UIColor.clearColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
}