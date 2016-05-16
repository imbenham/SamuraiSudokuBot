//
//  ChoosePuzzleController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/11/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class ChoosePuzzleController: PopUpTableViewController {
    weak var puzzleController: PlayPuzzleDelegate?
    
    var difficulties: [PuzzleDifficulty] = [.Easy, .Medium, .Hard, .Insane]
    var difficulty: PuzzleDifficulty?
    
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
    
    
    
    init(style: UITableViewStyle, successfullyCompleted: Bool, gaveUp: Bool) {
        super.init(style: style)
        
        self.successfullyCompleted = successfullyCompleted
        self.gaveUp = gaveUp
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = ChoosePuzzleMenuHeader(frame: CGRectMake(0, 0, preferredContentSize.width, 65))
        
        let footerRect = CGRectMake(0,0, preferredContentSize.width, 50)
        
        let footer = PopOverMenuFooter(frame: footerRect, text:"Go!")
        
        tableView.tableFooterView = footer
        
        footer.hidden = true
        
        footer.button.addTarget(self, action: #selector(self.saveAndPop(_:)), forControlEvents: .TouchUpInside)
        
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let difficulty = puzzleController?.difficulty else {
            print("returning 4")
            return 4
        }
        let num = (successfullyCompleted && !(difficulty == .Insane)) || (gaveUp && !(difficulty == .Easy)) ? 5 : 4
        
        print("num rows: \(num)")
        
        return num
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        var attributedTitle: NSAttributedString
        
        let row = indexPath.row
        
        if row < 4 {
            attributedTitle = difficulties[row].stylizedDescriptor()
        } else {
            print("row 4")
            let configs = Utils.ButtonConfigs()
            attributedTitle = successfullyCompleted ? configs.getAttributedBodyText("SLIGHTLY HARDER") : configs.getAttributedBodyText("SLIGHLTY EASIER")

        }
        
        cell.textLabel?.attributedText = attributedTitle
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (preferredContentSize.height - 65) / ((successfullyCompleted && !(difficulty == .Insane)) || (gaveUp && !(difficulty == .Easy)) ? 5 : 4)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        // do some more stuff
        if indexPath.row < 4 {
            difficulty = difficulties[indexPath.row]
        } else {
            // do some stuff
            let current = Int(puzzleController!.puzzle!.rawScore)
            var newLevel: PuzzleDifficulty? = difficulty
            
            if successfullyCompleted {
                newLevel = current + 10 > PuzzleDifficulty.maxInsaneThreshold ? PuzzleDifficulty.Insane : PuzzleDifficulty.Custom(current + 10)
            } else if gaveUp {
                newLevel = current - 10 < PuzzleDifficulty.minEasyThreshold ? PuzzleDifficulty.Easy : PuzzleDifficulty.Custom(current - 10)
            }
            
            difficulty = newLevel
            
        }
        if tableView.tableFooterView!.hidden {
            // do some special stuff
            UIView.animateWithDuration(0.4) {
                self.preferredContentSize.height += 56
                self.tableView.tableFooterView!.hidden = false
            }
        }
    }
    
    func saveAndPop(sender: AnyObject?) {
        guard let diff = difficulty, let ppd = presentingViewController as? PlayPuzzleDelegate else {
            return
        }
        
        puzzleController?.difficulty = diff
        
        puzzleController?.puzzle = nil
        //puzzleController?.clearAll()
        
        if let pvc = ppd as? SudokuController {
            pvc.dismissViewControllerAnimated(true) {
                ppd.fetchPuzzle()
            }
        }
        
    }
    
}