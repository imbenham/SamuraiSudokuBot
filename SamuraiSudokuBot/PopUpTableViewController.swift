//
//  PopUpTableViewController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/9/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

// this is an abstract superclass

class PopUpTableViewController: UITableViewController {
    
    var selectedIndex:NSIndexPath? {
        didSet {
            if let selectedIndex = selectedIndex {
                let cell = tableView.cellForRowAtIndexPath(selectedIndex)
                cell?.textLabel?.textColor = UIColor.blackColor()
                if let old = oldValue {
                    if old == selectedIndex {
                        return
                    }
                    let cell = tableView.cellForRowAtIndexPath(old)
                    cell?.textLabel?.textColor = Utils.Palette.getTheme()
                    cell?.selected = false
                }
            } else {
                if let old = oldValue {
                    print("there was an old value")
                    let cell = tableView.cellForRowAtIndexPath(old)
                    cell?.textLabel?.textColor = Utils.Palette.getTheme()
                    cell?.selected = false
                }
            }
        }
    }
    
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        let theme = Utils.Palette.getTheme()
        
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.blackColor()
        tableView.tintColor = UIColor.whiteColor()
        tableView.layer.borderColor = theme.CGColor
        tableView.layer.borderWidth = 6.0
        tableView.separatorStyle = .None
        
        view.layoutMargins = UIEdgeInsetsMake(11, 11, 11, 11)
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = UIFont(name: "futura", size: UIFont.labelFontSize())
        
        let theme = Utils.Palette.getTheme()
        
        cell.backgroundColor = UIColor.blackColor()
        let selectedBG = UIView()
        selectedBG.backgroundColor = theme
        cell.selectedBackgroundView = selectedBG
        
        cell.layer.borderColor = theme.CGColor
        
        if indexPath.row % 2 == 0 {
            cell.layer.borderWidth = 1.0
        } else {
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        var frame = view.frame
        frame = CGRectInset(frame, 5, 0)
        view.frame = frame
    }
}
