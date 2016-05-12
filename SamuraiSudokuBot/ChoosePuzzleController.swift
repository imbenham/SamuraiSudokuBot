//
//  ChoosePuzzleController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/11/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class ChoosePuzzleController: PopUpTableViewController {
    var successfullyCompleted = false {
        didSet {
            if successfullyCompleted {
                gaveUp = false
            }
        }
    }
    var gaveUp = false {
        didSet {
            if gaveUp {
                successfullyCompleted = false
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return successfullyCompleted || gaveUp ? 5 : 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        var attributedTitle: NSAttributedString
        let configs = Utils.ButtonConfigs
        
        switch indexPath.row {
        case 0:
           attributedTitle = configs.getAttributedBodyText("EASY")
        case 1:
            attributedTitle = configs.getAttributedBodyText("MEDIUM")
        case 2:
            attributedTitle = configs.getAttributedBodyText("HARD")
        case 3:
            attributedTitle = configs.getAttributedBodyText("INSANE")
        default:
            attributedTitle = successfullyCompleted ? configs.getAttributedBodyText("SLIGHTLY HARDER") : configs.getAttributedBodyText("SLIGHLTY EASIER")
        }
        
        cell.textLabel?.attributedText = attributedTitle
        
        return cell
    }
}