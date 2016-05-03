//
//  SamuraiViewController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class SamuraiSudokuController: SudokuController, PlayPuzzleDelegate {
    
    @IBOutlet weak var board1: SudokuBoard!
    @IBOutlet weak var board2: SudokuBoard!
    @IBOutlet weak var board3: SudokuBoard!
    @IBOutlet weak var board4: SudokuBoard!
    @IBOutlet weak var middleBoard: SudokuBoard!
    
    
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
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    @IBOutlet weak var containerHeight: NSLayoutConstraint!
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    
   
    @IBAction func handleNoteButtonTap(sender: AnyObject) {
        self.toggleNoteMode(sender)
    }
    
    var backgroundView: SSBBackgroundView {
        get {
            return self.view as! SSBBackgroundView
        }
        set {
            self.view = newValue
        }
    }
    
    var boards: [SudokuBoard] {
        return [board1, board2, board3, board4, middleBoard]
    }
    
    var containerSubviews: (front: UIView, back: UIView)!
    
    let hintButton = UIButton()
    let playAgainButton = UIButton()
    
    var alertController: UIAlertController?
    
    
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
    
    override var noteMode: Bool  {
        didSet {
            noteButton.selected = !noteButton.selected
            let nbBGColor = noteButton.backgroundColor
            let nbTextColor = noteButton.titleColorForState(.Normal)
            
            noteButton.backgroundColor = nbTextColor
            noteButton.setTitleColor(nbBGColor, forState: .Normal)
            noteButton.layer.borderColor = nbBGColor?.CGColor
            if noteMode {
                if let selectedTile = selectedTile {
                    if selectedTile.displayValue.rawValue != 0 {
                        selectedTile.addNote(selectedTile.displayValue.rawValue)
                        selectedTile.clearValue()
                        selectedTile.refreshLabel()
                    }
                }
            }
           
            numPad.refresh()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerSubviews = (hintButton, playAgainButton)
        
        for board in boards {
            board.controller = self
            board.prepareBoxes()
        }
        
        for button in numPad.buttons {
            button.addTarget(self, action: #selector(valueSelected(_:)), forControlEvents: .TouchUpInside)
        }
        
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        
        for board in outerBoards {
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
        
        numPad.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        return
    }
    
    
    override func boardReady() {
        readyCount += 1
        print("\(readyCount)")
        if readyCount == 5 {
            print("fetching puzzle")
            fetchPuzzle()
        }
    }
    
    func fetchPuzzle() {
        print("fetching from controller!")
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
            
            self.puzzleReady()
            
        }
        
        PuzzleStore.sharedInstance.getPuzzleForController(self, withCompletionHandler: handler)
    }
    
    //MARK: PlayPuzzleDelegate
    
    func toggleNoteMode(sender: AnyObject?) {
        print("note mode toggled!")
        if let press = sender as? UILongPressGestureRecognizer {
            if press.state == .Began {
                if let tile = (sender as! UIGestureRecognizer).view as? Tile {
                    if tile.symbolSet != .Standard {
                        return
                    }
                    if tile != selectedTile {
                        selectedTile = tile
                        noteMode = true
                    } else {
                        noteMode = false
                    }
                }
            }
        } else {
            if let selected = selectedTile {
                if selected.symbolSet != .Standard {
                    noteMode = false
                    return
                }
               
                noteMode = !noteMode
            } else {
                noteMode = false
                return
            }
        }
    }
    
    //MARK: NumPadDelegate methods
    override func valueSelected(value: UIButton) {
        let value = value.tag
        if noteMode {
            noteValueChanged(value)
            numPad.refresh()
            return
        }
        
        if let selected = selectedTile {
            if selected.displayValue.rawValue == value {
                selected.setValue(0)
            } else {
                selected.setValue(value)
                print("setting value to: \(value)")
            }
        }
        
        checkSolution()
        
        numPad.refresh()
        
        
        
    }
    
    func noteValueChanged(value: Int) {
        if let selected = selectedTile {
            if selected.noteValues.contains(value) {
                selected.removeNoteValue(value)
            } else {
                selected.addNoteValue(value)
            }
        }
    }
    
    
    func noteValues() -> [Int]? {
        let selected = selectedTile
        if selected == nil {
            return nil
        }
        if selected?.noteMode == false {
            return nil
        } else {
            return selected?.noteValues
        }
    }

    var currentValue: Int {
        guard let selected = selectedTile else {
            return 0
        }
        
        return selected.displayValue.rawValue
    }
}

