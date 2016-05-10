//
//  PuzzleOptionsController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class PuzzleOptionsViewController: PopUpTableViewController {
    
    var selectedIndex:NSIndexPath = NSIndexPath(forRow: 100, inSection: 100) {
        willSet {
            if selectedIndex != newValue {
                let cell = tableView.cellForRowAtIndexPath(selectedIndex)
                cell?.accessoryType = .None
                cell?.textLabel?.textColor = Utils.Palette.green
            }
        }
        didSet {
            if selectedIndex != oldValue {
                let cell = tableView.cellForRowAtIndexPath(selectedIndex)
                cell?.accessoryType = .Checkmark
                cell?.textLabel?.textColor = UIColor.blackColor()
            }
        }
    }
    
    var timedStatus = true {
        didSet {
            let indexPath = NSIndexPath(forRow: 0, inSection: 1)
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.textLabel!.text = timedStatusString
        }
    }
    var timedStatusString: String {
        get {
            return timedStatus ? "On" : "Off"
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(OptionMenuFooter.self, forHeaderFooterViewReuseIdentifier: "OptionFooter")
        
    }
    
 
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        let selected = defaults.integerForKey(symbolSetKey)
        
        let index = NSIndexPath(forRow: selected, inSection: 0)
        selectedIndex = index
        
        tableView.selectRowAtIndexPath(selectedIndex, animated: false, scrollPosition: UITableViewScrollPosition.None)
    }
    
    
    
    override func numberOfSectionsInTableView(_: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Change Symbol Set"
        default:
            return "Timer"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section{
        case 0:
            return 3
        default:
            return 1
            
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        let theme = Utils.Palette.green
        cell.textLabel?.textColor = selectedIndex == indexPath ? UIColor.blackColor() : theme
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Standard: 1-9"
            case 1:
                cell.textLabel?.text = "Critters:🐥-🐌"
            default:
                cell.textLabel?.text = "Flags:🇨🇭-🇲🇽"
            }
        default:
            cell.textLabel?.text = timedStatusString
        }
        
       return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            selectedIndex = indexPath
        } else {
            timedStatus = !timedStatus
        }
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self.tableView.numberOfSections - 1 {
            return 50.0
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self.tableView.numberOfSections - 1 {
            let footerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("OptionFooter") as! OptionMenuFooter
            footerView.saveButton.addTarget(self, action: #selector(PuzzleOptionsViewController.saveAndDismiss), forControlEvents: .TouchUpInside)
            footerView.userInteractionEnabled = true
            return footerView
           
        }
        return nil
    }
    
    
    // saving changes
    
    func saveAndDismiss() {
        
        let selected = selectedIndex.row
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(selected, forKey: "symbolSet")
        defaults.setBool(timedStatus, forKey: "timed")
        
        defaults.synchronize()
        
        presentingViewController!.dismissViewControllerAnimated(true) {
            
        }
        
    }
}