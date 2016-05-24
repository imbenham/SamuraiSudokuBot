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
    var difficulty: PuzzleDifficulty? {
        didSet {
            if difficulty != nil {
                recentRequested = false
            }
        }
    }
    
    var sfHeight:CGFloat = 0

    let recentAvailable = PuzzleStore.sharedInstance.hasRecents
    
    var customAvailable: Bool {
        get {
            guard let difficulty = puzzleController?.difficulty else {
                return false
            }
            return (successfullyCompleted && !(difficulty == .Insane)) || (gaveUp && !(difficulty == .Easy))
        }
    }
    
    var previousDifficulty: Int?
    
    var recentRequested: Bool = false
    
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
        
        tableView.tableHeaderView = PopOverMenuHeader(frame: CGRectMake(0, 0, headerWidth, headerHeight), title: "Choose a difficulty \n level to get started.")
        
        sfHeight = preferredContentSize.height - tableView.layoutMargins.bottom - (CGFloat(self.tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))) * CGFloat(self.tableView(tableView, numberOfRowsInSection: 0))) - headerHeight
       
        
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
            return recentAvailable ? 5 : 4
        }
        
        
        
        var extras = (successfullyCompleted && !(difficulty == .Insane)) || (gaveUp && !(difficulty == .Easy)) ? 1 : 0
        extras += recentAvailable ? 1: 0
        
        return 4 + extras
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        var attributedTitle: NSAttributedString
        
        let row = indexPath.row
        
        if row < 4 {
            attributedTitle = difficulties[row].stylizedDescriptor()
        } else if row == 4 {
            let configs = Utils.ButtonConfigs()
            if customAvailable {
                attributedTitle = successfullyCompleted ? configs.getAttributedBodyText("SLIGHTLY HARDER") : configs.getAttributedBodyText("SLIGHTLY EASIER")
            } else {
                attributedTitle = configs.getAttributedBodyText("MOST RECENT")
            }
        } else {
            let configs = Utils.ButtonConfigs()
            attributedTitle = configs.getAttributedBodyText("MOST RECENT")
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
        
        return (preferredContentSize.height - headerHeight - ftHeight - tableView.layoutMargins.bottom - 0.5) / CGFloat(self.tableView(tableView, numberOfRowsInSection: indexPath.section))
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath
        // do some more stuff
        if indexPath.row < 4 {
            difficulty = difficulties[indexPath.row]
        } else if indexPath.row == 4 {
            
            
            guard customAvailable else {
                recentRequested = true
                showFooter()
                return
            }
            
            guard let oldDiff = previousDifficulty else {
                return
            }
            
            if successfullyCompleted {
                difficulty = oldDiff + 40 > PuzzleDifficulty.maxInsaneThreshold ? PuzzleDifficulty.Insane : PuzzleDifficulty.Custom(oldDiff + 40)
            } else if gaveUp {
                difficulty = oldDiff - 40 < PuzzleDifficulty.minEasyThreshold ? PuzzleDifficulty.Easy : PuzzleDifficulty.Custom(oldDiff - 40)
            } else {
                return
            }
        } else {
            recentRequested = true
        }
        showFooter()
    }
    
    func showFooter() {
        if tableView.tableFooterView!.hidden {
            let footer = tableView.tableFooterView as! PopOverMenuFooter
            
            UIView.animateWithDuration(0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.25, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.preferredContentSize.height += self.footerHeight
                footer.hidden = false
                self.tableView.reloadData()
                }, completion: nil)
        }

    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        print(sfHeight)
        
        return sfHeight
    }
    
    func saveAndPop(sender: AnyObject?) {
        
        
        if recentRequested {
            dismiss(true)
        }
        
        guard let diff = difficulty else {
            return
        }
        
        puzzleController?.difficulty = diff
        
        dismiss()
        
    }
    
    func dismiss(recent: Bool=false) {
        if let ppd = puzzleController as? SudokuController {
            ppd.dismissViewControllerAnimated(true) {
                self.puzzleController!.fetchPuzzle(recent)
            }
        }
    }
}