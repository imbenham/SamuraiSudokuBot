//
//  HelpMenuController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/9/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class HelpMenuController: PopUpTableViewController {
    
    
  
    
    let instructionView = SSBInstructionSheet(frame: CGRectZero)
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        
        cell.textLabel?.textColor = Utils.Palette.getTheme()
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Hint, please!"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "I give up."
        } else {
            cell.textLabel?.text = "How do I play?"
        }
        
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tough, eh?"
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Request a hint to reveal a cell."
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        
        guard let pvc = presentingViewController as? SudokuController else {
            selectedIndex = nil
            return
        }
        
        
        
        switch indexPath.row {
        case 0:
            pvc.dismissViewControllerAnimated(true) {
                if let ppd = pvc as? PlayPuzzleDelegate {
                    ppd.showHint()
                    ppd.hintButton.selected = false
                }
            }
        case 1:
            pvc.dismissViewControllerAnimated(true) {
                if let ppd = pvc as? PlayPuzzleDelegate {
                    ppd.giveUp()
                    ppd.hintButton.selected = false
                }
            }
        default:
            pushInstructionSheet()
        }
    }
    
    func pushInstructionSheet() {
        
        tableView.bounces = false
        
        let newSize = CGSizeMake(self.preferredContentSize.width * 1.4, self.preferredContentSize.height * 1.5)
        
        let rect = CGRect(origin: CGPointMake(0, newSize.height), size: newSize)
        
        let beginningRect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(1, 1, 0, 3))
        
        
        instructionView.frame = beginningRect
        instructionView.backgroundColor = UIColor.blackColor()
        
        let animations: () -> () = {
            self.preferredContentSize = newSize
        }
        
        let endingRect = UIEdgeInsetsInsetRect(CGRect(origin: CGPointMake(0, 0), size:newSize), UIEdgeInsetsMake(1, 1, 1, 3))

        
        let animations2: () -> () = {
            self.instructionView.frame = endingRect
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animations) { (completed: Bool) -> () in
            if completed {
                self.tableView.addSubview(self.instructionView)
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: animations2, completion: nil)
            }
                
        }
    }
    
}
