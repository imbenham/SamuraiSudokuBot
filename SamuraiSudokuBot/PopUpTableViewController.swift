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
    override func viewDidLoad() {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        let theme = Utils.Palette.green
        
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.blackColor()
        tableView.tintColor = UIColor.whiteColor()
        tableView.layer.borderColor = theme.CGColor
        tableView.layer.borderWidth = 5.0
        tableView.separatorStyle = .None
        
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.font = UIFont(name: "futura", size: UIFont.labelFontSize())
        
        let theme = Utils.Palette.green
        
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
