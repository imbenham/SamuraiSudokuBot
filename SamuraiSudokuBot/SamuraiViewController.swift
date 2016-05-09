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
    @IBOutlet weak var middleBoard: MiddleBoard!
    
    
    @IBOutlet var xConstraints: [NSLayoutConstraint]!
    @IBOutlet var yConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
   
    @IBAction func handleNoteButtonTap(sender: AnyObject) {
        self.toggleNoteMode(sender)
    }
    
    @IBAction func handleOptionsButtonTap(sender: AnyObject) {
        
        
        let poController = PuzzleOptionsViewController(style: .Grouped)
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(300, 350)
        
        let sender = sender as! UIButton
        let ppc = poController.popoverPresentationController
        ppc?.sourceView = sender
        ppc?.sourceRect = sender.bounds
        ppc?.permittedArrowDirections = .Left
        ppc?.backgroundColor = Utils.Palette.green
        
    
        
        presentViewController(poController, animated: true, completion: nil)
        
        
    }
   
    
    @IBAction func handleUndoButtonTap(sender: AnyObject) {
        print("undo button tapped")
    }

    @IBAction func handleHintButtonTap(sender: AnyObject) {
        showHelpMenu(sender)
    }
    
    
    @IBAction func handleClearButtonTap(sender: AnyObject) {
        clearSolution()
    }
    
    
    
    var backgroundView: SSBBackgroundView {
        get {
            return self.view as! SSBBackgroundView
        }
        set {
            self.view = newValue
        }
    }
    
    override var boards: [SudokuBoard] {
        return [middleBoard, board1, board2, board3, board4]
    }
    
    override var tiles: [Tile] {
        get {
            var tiles: [Tile] = []
            for board in boards {
                tiles += board.tiles
            }
            return tiles
        }
    }
    
    var alertController: UIAlertController?
    
    
    let longFetchLabel = UILabel()
    var outerBoards: [SudokuBoard] {
        get {
            return [board1, board2, board3, board4]
        }
    }
    
    var readyCount = 0
    
    var needsRefresh = false
    
    var lastOffset: CGFloat = 0 {
        willSet {
            if lastOffset == newValue {
                needsRefresh = false
            } else {
                needsRefresh = true
            }
        }
    }
    
    var offset: CGFloat {
        get {
            return middleBoard.frame.size.width/3
        }
    }
    
    var puzzle: Puzzle?
    var difficulty: PuzzleDifficulty = .Medium
    
    override var noteMode: Bool  {
        didSet {
            noteButton.selected = !noteButton.selected
            let nbBGColor = noteMode ? UIColor.clearColor() : noteButton.backgroundColor
            let nbTextColor = noteButton.titleColorForState(.Normal)
            
            noteButton.backgroundColor = nbBGColor
            noteButton.setTitleColor(nbTextColor, forState: .Normal)
            noteButton.layer.borderColor = nbBGColor?.CGColor
            if noteMode {
                if let selectedTile = selectedTile {
                    if selectedTile.displayValue.rawValue != 0 {
                        selectedTile.addNote(selectedTile.displayValue.rawValue)
                        selectedTile.clearValue()
                    }
                    selectedTile.refreshLabel()
                }
            } else {
                if let selectedTile = selectedTile {
                    selectedTile.refreshLabel()
                }
            }
           
            numPad.refresh()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        for board in boards {
            board.controller = self
            board.prepareBoxes()
        }
        
        for button in numPad.buttons {
            button.addTarget(self, action: #selector(valueSelected(_:)), forControlEvents: .TouchUpInside)
        }
        
        numPad.delegate = self

        lastOffset = offset
        
    }
    
    override func viewDidLayoutSubviews() {
        
        
        for board in outerBoards {
            board.layer.borderColor = UIColor.blackColor().CGColor

        }
        
        view.sendSubviewToBack(middleBoard)
        middleBoard.layer.borderColor = UIColor.blackColor().CGColor
        middleBoard.layer.borderWidth = 2.0
    
        middleBoard.isMiddle = true
        
        let configs = Utils.ButtonConfigs
        
        hintButton.setAttributedTitle(configs.getAttributedTitle("?"), forState: .Normal)
        clearButton.setAttributedTitle(configs.getAttributedTitle("Clear"), forState: .Normal)
        noteButton.setAttributedTitle(configs.getAttributedTitle("Note+"), forState: .Normal)
        optionsButton.setAttributedTitle(configs.getAttributedTitle("Options"), forState: .Normal)
        
        
        for button in [clearButton, noteButton, optionsButton, hintButton, undoButton] {
            let size = button.frame.size
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected: false), forState: .Normal)
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected: true), forState: .Selected)
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected:true), forState: .Highlighted)
            
            button.layer.cornerRadius = button.frame.size.height/2
            button.clipsToBounds = true
            
            button.layer.borderColor = configs.baseColor.CGColor
            button.layer.borderWidth = 2.0
            
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleEdgeInsets = button == optionsButton ? UIEdgeInsetsMake(0, 5.0, 8.0, 5.0) : UIEdgeInsetsMake(0, 5.0, 0, 5.0)
        
            
            
        }
        
        
        lastOffset = offset
        view.setNeedsUpdateConstraints()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        lastOffset = offset
        view.setNeedsUpdateConstraints()
    }
    

    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        guard needsRefresh else {
            return
        }
        
        for constraint in xConstraints {
            if let identifier = constraint.identifier where (identifier == "board1X" || identifier == "board4X") {
                constraint.constant = offset
            } else {
                constraint.constant = offset * -1
            }
            
            
        }
        
        for constraint in yConstraints {
            if let identifier = constraint.identifier where (identifier == "board1Y" || identifier == "board2Y") {
                constraint.constant = offset
            } else {
                constraint.constant = offset * -1
            }
            
        }
        

    }
    
    override func boardReady() {
        readyCount += 1
        if readyCount == 5 {
            fetchPuzzle()
        }
    }
    
    func fetchPuzzle() {
        
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
    
    override func toggleNoteMode(sender: AnyObject?) {
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
    
    override func noteValueChanged(value: Int) {
        if let selected = selectedTile {
            if selected.noteValues.contains(value) {
                selected.removeNoteValue(value)
            } else {
                selected.addNoteValue(value)
            }
        }
    }
    
    
    
    override func noteValues() -> [Int]? {
        print("Using SamController implementation")
        guard noteMode, let selected = selectedTile else {
            return nil
        }
        
        return selected.noteValues
    }

    override var currentValue: Int {
        guard let selected = selectedTile else {
            return 0
        }
        
        return selected.displayValue.rawValue
    }
    
   
}

