//
//  PuzzleOptionsController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class PuzzleOptionsViewController: PopUpTableViewController {
    
    var soundOn: Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let soundKey = Utils.Constants.Identifiers.soundKey
            guard let soundOn = defaults.objectForKey(soundKey) as? Bool else {
                return false
            }
            return soundOn

        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            let soundKey = Utils.Constants.Identifiers.soundKey
            defaults.setBool(!soundOn, forKey: soundKey)

            let sections = NSIndexSet(index: 2)
            tableView.reloadSections(sections, withRowAnimation: .Fade)
        }
        
    }
    
    override var selectedIndex:NSIndexPath? {
        willSet {
            if selectedIndex != newValue && selectedIndex != nil {
                let cell = tableView.cellForRowAtIndexPath(selectedIndex!)
                cell?.accessoryType = .None
                cell?.textLabel?.textColor = Utils.Palette.getTheme()
            }
        }
        didSet {
            if selectedIndex != oldValue {
                if let selectedIndex = selectedIndex {
                    let cell = tableView.cellForRowAtIndexPath(selectedIndex)
                    cell?.accessoryType = .Checkmark
                    cell?.textLabel?.textColor = UIColor.blackColor()
                    dispatch_async(concurrentPuzzleQueue){
                        self.updateSymbols()
                    }
                    
                }
            }
        }
    }
    
    var selectedColor = Utils.Palette.getSelectedIndex()
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelection = true
        tableView.registerClass(ColorPickerCell.self, forCellReuseIdentifier: "ColorPickerCell")
        
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 35

        
    }
    
    func calculateHeight() -> CGFloat {
        let numSects = numberOfSectionsInTableView(tableView)
        let sections = CGFloat(numSects)
        
        let headerHeight = sections * tableView.sectionHeaderHeight
        //let footerHeight = tableView(tableView, heightForFooterInSection: numSects-1)
        
        var cellsCount = 0
        
        for index in  0...numSects-1 {
            cellsCount += tableView.numberOfRowsInSection(index)
        }
        
        let cellsHeight = CGFloat(cellsCount) * tableView.rowHeight
        
        print("header height: \(headerHeight) cellsHeight: \(cellsHeight)")
        
        return 6 + headerHeight + cellsHeight
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let height = calculateHeight()
        
        self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: height)
        

        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = NSUserDefaults.standardUserDefaults()
        let selected = defaults.integerForKey(Utils.Constants.Identifiers.symbolSetKey)
        
        let index = NSIndexPath(forRow: selected, inSection: 0)
        selectedIndex = index
        
        tableView.selectRowAtIndexPath(selectedIndex, animated: false, scrollPosition: UITableViewScrollPosition.None)
        
       
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func numberOfSectionsInTableView(_: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0:
            return "Change Symbol Set"
        case 1:
            return "Choose Color"
        default:
            return "Sound"
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = PopOverSectionHeaderView(frame: tableView.rectForHeaderInSection(section), title:self.tableView(tableView, titleForHeaderInSection: section)!)
    
       // view.layer.borderColor = Utils.Palette.getTheme().CGColor
       // view.layer.borderWidth = 2.0
        return view
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
        
        let cell = indexPath.section != 1 ? super.tableView(tableView, cellForRowAtIndexPath: indexPath) : tableView.dequeueReusableCellWithIdentifier("ColorPickerCell", forIndexPath: indexPath)
        
        let theme = Utils.Palette.getTheme()
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
        case 1:
            let cell = cell as! ColorPickerCell
            
            cell.layer.borderColor = theme.CGColor
            
            cell.selectedTab = selectedColor
            
            for tab in cell.tabs {
                
                if tab.gestureRecognizers == nil {
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tabSelected(_:)))
                    gestureRecognizer.cancelsTouchesInView = true
                    tab.addGestureRecognizer(gestureRecognizer)
                } else if tab.gestureRecognizers!.count == 0 {
                    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tabSelected(_:)))
                    gestureRecognizer.cancelsTouchesInView = true
                    tab.addGestureRecognizer(gestureRecognizer)
                }
                
            }
        default:
        
            cell.textLabel?.text = soundOn ? "ON" : "OFF"
        }
        
        print(cell.frame.height)
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            selectedIndex = indexPath
        } else if indexPath.section == 2 {
            print("uh oh")
        }
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 {
            return tableView.indexPathForSelectedRow
        } else if indexPath.section == 2 {
            soundOn = !soundOn
            return tableView.indexPathForSelectedRow
        }
        

        return indexPath
    }
    
    
    func tabSelected(sender: AnyObject) {
        guard let gr = sender as? UITapGestureRecognizer, let tab = gr.view, let cell = tab.superview as? ColorPickerCell else{
            return
        }
        
        cell.selectedTab = tab.tag
        
        selectedColor = tab.tag

        updateColor()
        
        
    }
    
    func updateColor() {
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let colorID = Utils.Constants.Identifiers.colorTheme
        defaults.setInteger(selectedColor, forKey: colorID)
        
        let color = Utils.Palette.getTheme()
        tableView.backgroundColor = color
        tableView.layer.borderColor = color.CGColor
        
        tableView.reloadData()
        
        tableView.selectRowAtIndexPath(selectedIndex, animated: false, scrollPosition: .None)
        
        if let poc = self.popoverPresentationController {
            poc.backgroundColor = color
        }
    }
    
    func updateSymbols() {
        guard let selectedIndex = selectedIndex else {
            return
        }
        
        let selected = selectedIndex.row
        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaults.setInteger(selected, forKey: Utils.Constants.Identifiers.symbolSetKey)
    }
    
    // saving changes
    
}