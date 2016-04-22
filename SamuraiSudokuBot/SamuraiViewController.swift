//
//  SamuraiViewController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class SamuraiSudokuController: SudokuController, PlayPuzzleDelegate {
    
    @IBOutlet var board1: SudokuBoard!
    @IBOutlet var board2: SudokuBoard!
    @IBOutlet var board3: SudokuBoard!
    @IBOutlet var board4: SudokuBoard!
    @IBOutlet var middleBoard: MiddleBoard!
    
    
    @IBOutlet var xConstraints: [NSLayoutConstraint]!
    @IBOutlet var yConstraints: [NSLayoutConstraint]!
  /*
    @IBAction func modeSelected(sender: AnyObject) {
        if let sender = sender as? UISegmentedControl {
            if sender.selectedSegmentIndex == 0 {
                print("Play selected")
            } else {
                print("Cheat selected")
            }
        }
    }*/
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var containerWidth: NSLayoutConstraint!
    @IBOutlet var containerHeight: NSLayoutConstraint!
    @IBOutlet var noteButton: UIButton!
    @IBOutlet var optionsButton: UIButton!
    @IBOutlet var clearButton: UIButton!
    var backgroundView: SSBBackgroundView {
        get {
            return self.view as! SSBBackgroundView
        }
        set {
            self.view = newValue
        }
    }
    
    var containerSubviews: (front: UIView, back: UIView)!
    
    let hintButton = UIButton()
    let playAgainButton = UIButton()
    
    
    
    
    let longFetchLabel = UILabel()
    var outerBoards: [SudokuBoard] {
        get {
            return [board1, board2, board3, board4]
        }
    }
    
    var readyCount = 0
    
    var offset: CGFloat {
        get {
            
            return board1.frame.size.width * 1/3 + 0.5
        }
    }
    
    var puzzle: Puzzle?
    var difficulty: PuzzleDifficulty = .Medium
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerSubviews = (hintButton, playAgainButton)
        
        for board in boards {
            board.controller = self
        }
        
        for board in outerBoards {
            board.layer.zPosition = 1
        }
        
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        
        for board in [board1, board2, board3, board4] {
            board.layer.borderColor = UIColor.blackColor().CGColor
            board.layer.borderWidth = 2.0
            board.layer.zPosition = 1.0
        }
        
        middleBoard.layer.zPosition = 0
        middleBoard.layer.borderColor = UIColor.blackColor().CGColor
        middleBoard.layer.borderWidth = 2.0
        
        //TODO configure container view and subviews
        
        //TODO configure notes and clear buttons
        
        let configs = Utils.sharedUtils.ButtonConfigs
        
        
        for button in [clearButton, noteButton, optionsButton] {
            let size = button.frame.size
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected: false), forState: .Normal)
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected: true), forState: .Selected)
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected:true), forState: .Highlighted)
            
            button.layer.cornerRadius = clearButton.frame.size.height/2
            button.clipsToBounds = true
            
            button.layer.borderColor = configs.baseColor.CGColor
            button.layer.borderWidth = 2.0

        }
        
        clearButton.setAttributedTitle(configs.getAttributedTitle("Clear"), forState: .Normal)
        noteButton.setAttributedTitle(configs.getAttributedTitle("Note+"), forState: .Normal)
        optionsButton.setAttributedTitle(configs.getAttributedTitle("Options"), forState: .Normal)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        
        for constraint in xConstraints {
            if let identifier = constraint.identifier where (identifier == "board1X" || identifier == "board4X") {
                constraint.constant += offset
            } else {
                constraint.constant -= offset
            }
            
            
        }
        
        for constraint in yConstraints {
            if let identifier = constraint.identifier where (identifier == "board1Y" || identifier == "board2Y") {
                constraint.constant += offset
            } else {
                constraint.constant -= offset
            }
            
        }
        
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        return
    }
    
    
    override func boardReady() {
        readyCount += 1
        
        if readyCount == 5 {
            //fetchPuzzle()
        }
    }
    
    func fetchPuzzle() {
        print("fetchingcfrom controller!")
        bannerView.userInteractionEnabled = false
        
        for board in boards {
            board.userInteractionEnabled = false
        }
        
        let placeHolderColor = middleBoard.tileAtIndex((1,1)).selectedColor
        let middleTile = middleBoard.tileAtIndex((5,4))
        
        let handler: (Puzzle -> ()) = {
            puzzle -> () in
            self.spinner.stopAnimating()
            middleTile.selectedColor = placeHolderColor
            
            self.puzzle = puzzle
            
            print(puzzle.initialsArray().count)
            
            for cell in self.puzzle!.solutionArray() {
                let index = cell.board.integerValue
                let board = self.boards[index]
                let tile = board.tileAtIndex((cell.convertToTileIndex()))
                tile.backingCell = cell
                
            }
            for cell in self.puzzle!.initialsArray(){
                let index = cell.board.integerValue
                let board = self.boards[index]
                let tile = board.tileAtIndex(cell.convertToTileIndex())
                tile.backingCell = cell
                
            }
            
            for board in self.boards {
                board.userInteractionEnabled = true
            }
            UIView.animateWithDuration(0.35) {
                self.navigationController?.navigationBarHidden = false
                self.longFetchLabel.hidden = true
            }
            
            
            /*
             if let time = dict?["time"] as? Double {
             self.storedTime = time
             }
             */
            
            self.puzzleReady()
            
        }
        
        PuzzleStore.sharedInstance.getPuzzleForController(self, withCompletionHandler: handler)
    }
    
}

