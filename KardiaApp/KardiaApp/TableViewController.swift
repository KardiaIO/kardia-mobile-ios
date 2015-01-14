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
        /*
        var header = UILabel()
        header.text = "Abnormal Events"
        self.arrhythmiaTable.tableHeaderView = header
        // View constraints for table
        
        let viewContainer = UIView(frame: view.frame)
        view.addSubview(viewContainer)
        self.arrhythmiaTable.setTranslatesAutoresizingMaskIntoConstraints(false);
        var TableViewConstraintX = NSLayoutConstraint(
            item: self.arrhythmiaTable,
            attribute: NSLayoutAttribute.CenterX,
            relatedBy: NSLayoutRelation.Equal,
            toItem: viewContainer,
            attribute: NSLayoutAttribute.CenterX,
            multiplier: 1,
            constant: 0
        )
        var TableViewConstraintY = NSLayoutConstraint(
            item: self.arrhythmiaTable,
            attribute: NSLayoutAttribute.CenterY,
            relatedBy: NSLayoutRelation.Equal,
            toItem: viewContainer,
            attribute: NSLayoutAttribute.CenterY,
            multiplier: 1,
            constant: 0
        )
        var TableViewConstraintHeight = NSLayoutConstraint(
            item: self.arrhythmiaTable,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: viewContainer,
            attribute: NSLayoutAttribute.Height,
            multiplier: 0.9,
            constant: 0
        )
        var TableViewConstraintWidth = NSLayoutConstraint(
            item: self.arrhythmiaTable,
            attribute: NSLayoutAttribute.Width,
            relatedBy: NSLayoutRelation.Equal,
            toItem: viewContainer,
            attribute: NSLayoutAttribute.Width,
            multiplier: 1,
            constant: 0
        )
        view.addConstraints([TableViewConstraintX, TableViewConstraintY, TableViewConstraintHeight, TableViewConstraintWidth])
        */
    }
    

    
    // Register table cell behavior
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrhythmiaEvents.count

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell = self.arrhythmiaTable?.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = TimestampFromDate(arrhythmiaTimes[indexPath.row])
        cell.textLabel?.font = UIFont(name: "STHeitiTC-Light", size: 16)
        cell.detailTextLabel?.text = "Arrhythmia"
        cell.detailTextLabel?.font = UIFont(name: "Helvetica-LightOblique", size: 12)
        cell.detailTextLabel?.textColor = UIColor.redColor()
        dispatch_async(dispatch_get_main_queue()) {
            cell.backgroundColor = UIColor.clearColor()
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
}