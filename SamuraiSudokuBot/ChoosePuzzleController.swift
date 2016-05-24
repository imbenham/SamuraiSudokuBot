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
    
    var previousDifficulty: Int?
    
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
    
    var headerHeight: CGFloat {
        get {
            return preferredContentSize.height * 1/5
        }
    }
    
    lazy var footerHeight: CGFloat  = {
        return self.preferredContentSize.height * 1/6
    }()
    
    
    
    init(style: UITableViewStyle, successfullyCompleted: Bool, gaveUp: Bool, previousDifficulty: Int? = nil) {
        super.init(style: style)
        
        self.successfullyCompleted = successfullyCompleted
        self.gaveUp = gaveUp
        self.previousDifficulty = previousDifficulty
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableHeaderView = ChoosePuzzleMenuHeader(frame: CGRectMake(0, 0, preferredContentSize.width, headerHeight))
        
        let footerRect = CGRectMake(0,0, preferredContentSize.width, footerHeight)
        
        let footer = PopOverMenuFooter(frame: footerRect, text:"Go!")
        
        tableView.tableFooterView = footer
        
        footer.hidden = true
        
        footer.button.addTarget(self, action: #selector(self.saveAndPop(_:)), forControlEvents: .TouchUpInside)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        puzzleController?.puzzle = nil
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let difficulty = puzzleController?.difficulty else {
            return 4
        }
        let num = (successfullyCompleted && !(difficulty == .Insane)) || (gaveUp && !(difficulty == .Easy)) ? 5 : 4
        
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
            attributedTitle = successfullyCompleted ? configs.getAttributedBodyText("SLIGHTLY HARDER") : configs.getAttributedBodyText("SLIGHTLY EASIER")

        }
        
        cell.textLabel?.attributedText = attributedTitle
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var ftHeight:CGFloat = 0
        if let footer = tableView.tableFooterView {
            if !footer.hidden {
                ftHeight = footerHeight
            }
        }
        
        return (preferredContentSize.height - headerHeight - ftHeight) / ((successfullyCompleted && !(difficulty == .Insane)) || (gaveUp && !(difficulty == .Easy)) ? 5 : 4)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        // do some more stuff
        if indexPath.row < 4 {
            difficulty = difficulties[indexPath.row]
        } else {
            // do some stuff
            
            // this causes a crash because the puzle controller's puzzle property has been set to nil
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
            //tableView.layoutIfNeeded()
            UIView.animateWithDuration(0.2) {
                self.tableView.tableFooterView!.hidden = false
                self.preferredContentSize.height += self.footerHeight + 6
                //self.tableView.layoutIfNeeded()
            }
        }
    }
    
    func saveAndPop(sender: AnyObject?) {
        guard let diff = difficulty, let ppd = presentingViewController as? PlayPuzzleDelegate else {
            return
        }
        
        puzzleController?.difficulty = diff
        
        
        if let pvc = ppd as? SudokuController {
            pvc.dismissViewControllerAnimated(true) {
                ppd.fetchPuzzle()
            }
        }
        
    }
    
}