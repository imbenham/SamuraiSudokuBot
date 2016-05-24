//
//  ClearMenuController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/24/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class ClearMenuController: PopUpTableViewController {
    
    var headerHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let inset = tableView.layer.borderWidth
        tableView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
        
        tableView.separatorStyle = .SingleLine
        tableView.separatorColor = Utils.Palette.getTheme()*/
        
        headerHeight = (preferredContentSize.height * 1/3) - tableView.layoutMargins.bottom - tableView.layoutMargins.top
        
        let header = PopOverMenuHeader(frame: CGRectMake(0, 0, headerWidth, headerHeight), title: "Humans sometimes \n need a fresh start.")
        tableView.tableHeaderView = header
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //let inset = tableView.layer.borderWidth
        
        return (preferredContentSize.height - headerHeight) / CGFloat(self.tableView(tableView, numberOfRowsInSection: indexPath.section))
    }
    
   override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
       
        return 0//preferredContentSize.height - headerHeight - (2 * tableView.layer.borderWidth) - (CGFloat(self.tableView(tableView, numberOfRowsInSection: section)) * self.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: section)))
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        var attributedTitle: NSAttributedString
        
        let configs = Utils.ButtonConfigs()
        
        let row = indexPath.row
        
        switch row {
        case 0:
            attributedTitle = configs.getAttributedBodyText("Start over")
        case 1:
            attributedTitle = configs.getAttributedBodyText("Give up")
        default:
            attributedTitle = configs.getAttributedBodyText("I hate this puzzle and want a new one.")
        }
        
        cell.textLabel?.attributedText = attributedTitle
        
        return cell

    }
    
}