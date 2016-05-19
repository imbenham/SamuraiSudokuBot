//
//  SamuraiViewController.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class SamuraiSudokuController: SudokuController, PlayPuzzleDelegate, UIPopoverPresentationControllerDelegate {
    @IBOutlet weak var puzzleMenuAnchor: UIView!
    
    @IBOutlet weak var board1: SudokuBoard!
    @IBOutlet weak var board2: SudokuBoard!
    @IBOutlet weak var board3: SudokuBoard!
    @IBOutlet weak var board4: SudokuBoard!
    @IBOutlet weak var middleBoard: MiddleBoard!
    
    @IBOutlet weak var undoPin: NSLayoutConstraint!
    @IBOutlet weak var redoPin: NSLayoutConstraint!
    
    @IBOutlet var xConstraints: [NSLayoutConstraint]!
    @IBOutlet var yConstraints: [NSLayoutConstraint]!

    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!
   
    @IBAction func handleNoteButtonTap(sender: AnyObject) {
        self.toggleNoteMode(sender)
    }
    
    @IBAction func handleOptionsButtonTap(sender: AnyObject) {
        
        showOptions(sender)
        
    }
   
    
    @IBAction func handleUndoButtonTap(sender: AnyObject) {
        managedObjectContext.undo()
    }
    @IBAction func handleRedoButtonTap(sender: AnyObject) {
        managedObjectContext.redo()
    }

    @IBAction func handleHintButtonTap(sender: AnyObject) {
        showHelpMenu(sender)
    }
    
    
    @IBAction func handleClearButtonTap(sender: AnyObject) {
        clearSolution()
    }
    
    var undoOffset: CGFloat {
        get {
            return undoButton.frame.size.width + 12
        }
    }
    
    var redoOffset: CGFloat {
        get {
            return undoOffset - 4
        }
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
    
    var tileMap: [Int: [String: Tile]] {
        get {
            var map = [Int: [String: Tile]]()
            for board in self.boards {
                map[board.index] = board.tileMap
            }
            return map
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
    
    var puzzle: Puzzle? {
        didSet {
            if let old = oldValue {
                if puzzle == nil {
                    managedObjectContext.deleteObject(old)
                    CoreDataStack.sharedStack.saveMainContext()
                }
                
            }
        }
    }
    
    var puzzleIsSolved:Bool {
        if nilTiles.count == 0 {
            if wrongTiles.count == 0 {
                return true
            }
        }
        return false
    }
    
    var difficulty: PuzzleDifficulty = .Medium
    
    var allButtons: [UIButton] {
        get {
            return [clearButton, noteButton, optionsButton, hintButton, undoButton, redoButton]
        }
    }
    
    var managedObjectContext: NSManagedObjectContext {
        get {
            return CoreDataStack.sharedStack.managedObjectContext
        }
    }

    
    override var noteMode: Bool  {
        didSet {
            noteButton.selected = noteMode
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
        
        puzzleMenuAnchor.backgroundColor = UIColor.clearColor()
        puzzleMenuAnchor.userInteractionEnabled = false
        
        for (index, board) in boards.enumerate() {
            board.controller = self
            board.prepareBoxes()
            
            board.defaultIndex = index
        }
        
        for button in numPad.buttons {
            button.addTarget(self, action: #selector(valueSelected(_:)), forControlEvents: .TouchUpInside)
        }
        
        numPad.delegate = self

        lastOffset = offset
        
        undoButton.alpha = 0
        redoButton.alpha = 0
        
    }
    
    override func viewDidLayoutSubviews() {
        
        
        for board in outerBoards {
            board.layer.borderColor = UIColor.blackColor().CGColor

        }
        
        view.sendSubviewToBack(middleBoard)
        middleBoard.layer.borderColor = UIColor.blackColor().CGColor
        middleBoard.layer.borderWidth = 2.0
    
        middleBoard.isMiddle = true
        
        let configs = Utils.ButtonConfigs()
        
        let hintTitle = configs.getAttributedTitle("?")
        hintButton.setAttributedTitle(hintTitle, forState: .Normal)
        hintButton.setAttributedTitle(hintTitle, forState: .Selected)
        let clearTitle = configs.getAttributedTitle("Clear")
        clearButton.setAttributedTitle(clearTitle, forState: .Normal)
        clearButton.setAttributedTitle(clearTitle, forState: .Selected)
        let noteTitle = configs.getAttributedTitle("Note+")
        noteButton.setAttributedTitle(noteTitle, forState: .Normal)
        noteButton.setAttributedTitle(noteTitle, forState: .Selected)
        let optionsTitle = configs.getAttributedTitle("Options")
        optionsButton.setAttributedTitle(optionsTitle, forState: .Normal)
        optionsButton.setAttributedTitle(optionsTitle, forState: .Selected)
        
        
        for button in allButtons {
            
            button.backgroundColor = UIColor.clearColor()
            
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
    
    func configureButton(button: UIButton) {
        let size = button.frame.size
        
        let configs = Utils.ButtonConfigs()
        
        button.setBackgroundImage(configs.backgroundImageForSize(size, selected: true), forState: .Selected)
        button.setBackgroundImage(configs.backgroundImageForSize(size, selected:true), forState: .Highlighted)
        
        button.layer.borderColor = configs.baseColor.CGColor

    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: Utils.Constants.Identifiers.colorTheme, options: .New, context: nil)

        
        lastOffset = offset
        view.setNeedsUpdateConstraints()
        
        if readyCount == 5 && self.presentedViewController == nil {
            //fetchPuzzle()
            // give protocol a default function for popping the play menu and call it here
            
            showChoosePuzzleController()
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let symbs = defaults.objectForKey(Utils.Constants.Identifiers.symbolSetKey) as? Int {
            if symbs != 0 {
                noteButton.hidden = true
            } else {
                noteButton.hidden = false
            }
        }
        
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: #selector(self.handleManagedObjectChange(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.handleManagedObjectSaveNotification(_:)), name: NSManagedObjectContextWillSaveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.handleUndoNotification(_:)), name: NSUndoManagerDidUndoChangeNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(self.handleRedoNotification(_:)), name: NSUndoManagerDidRedoChangeNotification, object: nil)
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
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let path = keyPath {
            if path == Utils.Constants.Identifiers.symbolSetKey {
                for tile in tiles {
                    tile.refreshLabel()
                }
                numPad.configureButtonTitles()
                numPad.setNeedsDisplay()
            } else if path == Utils.Constants.Identifiers.colorTheme {
                if let bgView = self.view as? SSBBackgroundView {
                    bgView.setNeedsDisplay()
                }
                
                for button in self.allButtons {
                    self.configureButton(button)
                }
                
                self.numPad.configureButtonsForSelected()

                
            }
        }
    }
    
    func fetchPuzzle() {
        
        for board in boards {
            board.userInteractionEnabled = false
        }
        
       
        
        let handler: (Puzzle -> ()) = {
            puzzle -> () in
            
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            
            self.puzzle = puzzle
            
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
            self.managedObjectContext.undoManager!.removeAllActions()
            self.hideUndoRedo()
            self.puzzleReady()
            self.playPuzzleFetched()
            
        }
        
        PuzzleStore.sharedInstance.getPuzzleForController(self, withCompletionHandler: handler)
    }
    
    //MARK: PlayPuzzleDelegate
    
    override func toggleNoteMode(sender: AnyObject?) {
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
            return
        } else {
            playValueSelected()
        }
        
        if let selected = selectedTile?.backingCell {
            if selected.assignedValue?.integerValue == value {
                selected.assignValue(0)
            } else {
                selected.assignValue(value)
            }
        }
        
        checkSolution()
        numPad.refresh()
        
    }
    
    override func noteValueChanged(value: Int) {
        if let selected = selectedTile?.backingCell {
            var notes = Set(selected.notesArray)
            notes.insert(value)
            numPad.refresh()
        }
        
    }
    
    //MARK: show/hide undo/redo buttons
    
    func hideUndoRedo() {
        hideUndoButton()
        hideRedoButton()
    }
    
    func hideUndoButton() {
        if undoButton.alpha == 0 {
            return
        }
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.undoButton.alpha = 0
            self.undoPin.constant -= self.undoOffset
            self.view.layoutIfNeeded()
        })

    }
    
    func showUndoButton() {
        if undoButton.alpha == 1 {
            return
        }
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.undoButton.alpha = 1
            self.undoPin.constant += self.undoOffset
            self.view.layoutIfNeeded()
        })
    }
    
    func hideRedoButton() {
        if redoButton.alpha == 0 {
            return
        }
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.redoButton.alpha = 0
            self.redoPin.constant -= self.redoOffset
            self.view.layoutIfNeeded()
        })
    }
    
    func showRedoButton() {
        if redoButton.alpha == 1 {
            return
        }
        view.layoutIfNeeded()
        UIView.animateWithDuration(0.4, animations: {
            self.redoButton.alpha = 1
            self.redoPin.constant += self.redoOffset
            self.view.layoutIfNeeded()
        })

    }
    
    //MARK: managedObjectContext handlers
    
    func handleManagedObjectChange(notification: NSNotification) {
        
        guard let infoDict = notification.userInfo as? [String: AnyObject] else {
            print("downcasting failed")
            return
        }
        
        if let updates = infoDict[NSUpdatedObjectsKey] as? Set<BackingCell> where updates.count > 0  {
            print(infoDict)
            for cell in updates {
                if let tile = tileWithBackingCell(cell) {
                    tile.refreshLabel()
                    numPad.refresh()
                }
            }
        }
        if managedObjectContext.undoManager!.canUndo {
            if undoButton.alpha == 0 {
                showUndoButton()
              
            }
        }
        
        if managedObjectContext.undoManager!.canRedo {
            self.view.setNeedsLayout()
            if redoButton.alpha == 0 {
                showRedoButton()
            }
        }
        
    }
    
    func handleManagedObjectSaveNotification(notification: NSNotification) {
        guard let context = notification.object as? NSManagedObjectContext where context.deletedObjects.count > 0 else {
            return
        }
        
        if puzzle == nil {
            for tile in tiles {
                tile.backingCell = nil
            }

        }
       
    }
    
    func handleUndoNotification(notification: NSNotification) {
        if let nm = notification.object as? NSUndoManager where !nm.canUndo {
            if undoButton.alpha == 1 {
                hideUndoButton()
            }
        }
    }
    
    func handleRedoNotification(notification: NSNotification) {
        if let nm = notification.object as? NSUndoManager where !nm.canRedo {
            if redoButton.alpha == 1 {
               hideRedoButton()
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
    
    // MARK: POPOVERpresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if let button = popoverPresentationController.sourceView as? UIButton {
            button.selected = false
        }
        
        let symbols = NSUserDefaults.standardUserDefaults().objectForKey(Utils.Constants.Identifiers.symbolSetKey) as! Int
        
        noteButton.hidden = symbols > 0
        
        
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
    
        if self.presentedViewController!.isKindOfClass(ChoosePuzzleController) && (puzzle == nil || puzzleIsSolved) {
            return false
        } else if self.presentedViewController!.isKindOfClass(PuzzleOptionsViewController){
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        return true
    }
    
}

