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
   
    @IBOutlet weak var playAgainButton: UIButton!
    @IBAction func handleNoteButtonTap(sender: AnyObject) {
        self.toggleNoteMode(sender)
    }
    
    @IBAction func handleOptionsButtonTap(sender: AnyObject) {
        noteMode = false
        showOptions(sender)
        
    }
    @IBAction func handlePlayAgainButtonTap(sender: AnyObject) {
        let currentScore = puzzle?.rawScore as? Int
        cleanUp()
        showChoosePuzzleController(currentScore)
    }
   
    @IBAction func handleUndoButtonTap(sender: AnyObject) {
        noteMode = false
        managedObjectContext.undo()
        playUndoRedo()
    }
    @IBAction func handleRedoButtonTap(sender: AnyObject) {
        noteMode = false
        managedObjectContext.redo()
        playUndoRedo()
    }

    @IBAction func handleHintButtonTap(sender: AnyObject) {
        noteMode = false
        showHelpMenu(sender)
    }
    
    
    @IBAction func handleClearButtonTap(sender: AnyObject) {
        noteMode = false
        showClearMenu(sender)
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
    
    var userSolvedPuzzle: Bool? {
        didSet {
            if userSolvedPuzzle == nil {
                playAgainButton.hidden = true
            } else {
                playAgainButton.hidden = false
            }
        }
    }
    
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
                    if presentedViewController == nil {
                        dispatch_async(dispatch_get_main_queue(), {
                            UIView.animateWithDuration(0.2, animations: {self.playAgainButton.alpha = 1}, completion: {completed in
                                if completed {
                                    self.playAgainButton.hidden = false
                                }
                            })
                            
                            
                        })
                    }
                    
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
    
    var allButtons: Set<UIButton>{
        get {
            return Set([clearButton, noteButton, optionsButton, hintButton, undoButton, redoButton, playAgainButton])
        }
    }
    
    var managedObjectContext: NSManagedObjectContext {
        get {
            return CoreDataStack.sharedStack.managedObjectContext
        }
    }

    var undoHidden = true {
        didSet {
            if undoHidden {
                dispatch_async(dispatch_get_main_queue(), {
                    print("hide undo called")
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.2, animations: {
                        self.undoButton.alpha = 0
                        self.undoPin.constant -= self.undoOffset
                        self.view.layoutIfNeeded()
                    })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("show undo called")
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.2, animations: {
                        self.undoButton.alpha = 1
                        self.undoPin.constant += self.undoOffset
                        self.view.layoutIfNeeded()
                    })
                })

            }
            

        }
    }
    var redoHidden = true {
        didSet {
            if redoHidden {
                dispatch_async(dispatch_get_main_queue(), {
                    print("hide redo button called")
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.2, animations: {
                        self.redoButton.alpha = 0
                        self.redoPin.constant -= self.redoOffset
                        self.view.layoutIfNeeded()
                    })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    print("show redo button called")
                    self.view.layoutIfNeeded()
                    UIView.animateWithDuration(0.2, animations: {
                        self.redoButton.alpha = 1
                        self.redoPin.constant += self.redoOffset
                        self.view.layoutIfNeeded()
                    })
                })
            }
        }
    }
    
    override var noteMode: Bool  {
        didSet {
            if noteMode != oldValue {
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
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext.processPendingChanges()
        managedObjectContext.undoManager?.removeAllActions()
        managedObjectContext.undoManager?.disableUndoRegistration()
        managedObjectContext.processPendingChanges()
        
        
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
        
        playAgainButton.hidden = true
        
    }
    
    private func styleButtons() {
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
        
        let playAgainTitle = configs.getAttributedTitle("PLAY")
        playAgainButton.setAttributedTitle(playAgainTitle, forState: .Normal)
        playAgainButton.setAttributedTitle(playAgainTitle, forState: .Selected)
        
        
        for button in allButtons {
            
            let size = button.frame.size
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected: false), forState: .Normal)
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected: true), forState: .Selected)
            button.setBackgroundImage(configs.backgroundImageForSize(size, selected:true), forState: .Highlighted)
            
            button.backgroundColor = UIColor.blackColor()
            
            button.layer.cornerRadius = button.frame.size.height/2
            button.clipsToBounds = true
            
            button.layer.borderColor = configs.baseColor.CGColor
            button.layer.borderWidth = 2.0
            
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleEdgeInsets = button == optionsButton ? UIEdgeInsetsMake(0, 5.0, 8.0, 5.0) : UIEdgeInsetsMake(0, 5.0, 0, 5.0)
            
        }

    }
    
    override func viewDidLayoutSubviews() {
        
        
        for board in outerBoards {
            board.layer.borderColor = UIColor.blackColor().CGColor

        }
        
        view.sendSubviewToBack(middleBoard)
        middleBoard.layer.borderColor = UIColor.blackColor().CGColor
        middleBoard.layer.borderWidth = 2.0
    
        middleBoard.isMiddle = true
        
        styleButtons()
        
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
        
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: Utils.Identifiers.colorTheme, options: .New, context: nil)

        
        lastOffset = offset
        view.setNeedsUpdateConstraints()
        
        if readyCount == 5 && puzzle == nil && self.presentedViewController == nil {
            showChoosePuzzleController()
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if let symbs = defaults.objectForKey(Utils.Identifiers.symbolSetKey) as? Int {
            if symbs != 0 {
                noteButton.hidden = true
            } else {
                noteButton.hidden = false
            }
        }
        
        
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
            if path == Utils.Identifiers.symbolSetKey {
                for tile in tiles {
                    tile.refreshLabel()
                }
                numPad.configureButtonTitles()
                numPad.setNeedsDisplay()
            } else if path == Utils.Identifiers.colorTheme {
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
    
    func fetchPuzzle(mostRecent: Bool = false) {
        
        for board in boards {
            board.userInteractionEnabled = false
        }
        
        
        let handler: (Puzzle -> ()) = {
            puzzle -> () in
            
            if self.managedObjectContext.undoManager!.undoRegistrationEnabled {
                self.managedObjectContext.undoManager?.disableUndoRegistration()
            }
            self.managedObjectContext.processPendingChanges()
            self.managedObjectContext.undoManager!.removeAllActions()

            
            
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: #selector(self.handleManagedObjectChange(_:)), name: NSManagedObjectContextObjectsDidChangeNotification, object: nil)
            
            notificationCenter.addObserver(self, selector: #selector(self.handleManagedObjectSaveNotification(_:)), name: NSManagedObjectContextWillSaveNotification, object: nil)
            
            notificationCenter.addObserver(self, selector: #selector(self.handleUndoNotification(_:)), name: NSUndoManagerDidUndoChangeNotification, object: nil)
            
            notificationCenter.addObserver(self, selector: #selector(self.handleRedoNotification(_:)), name: NSUndoManagerDidRedoChangeNotification, object: nil)
            
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
            
            
            self.puzzleReady()

        }
        
        if mostRecent {
            PuzzleStore.sharedInstance.getMostRecentPuzzleForController(self, withCompletionHandler: handler)
        } else {
            PuzzleStore.sharedInstance.getPuzzleForController(self, withCompletionHandler: handler)
        }
        
    }
    
    //MARK: PlayPuzzleDelegate
    
    override func deactivateInterface() {
        
        numPad.userInteractionEnabled = false
        board.userInteractionEnabled = false
        
        var buttons = allButtons
        for removable in [playAgainButton, undoButton, redoButton] {
            buttons.remove(removable)
        }
        
        UIView.animateWithDuration(0.25) {
            
            for button in buttons {
                button.userInteractionEnabled = false
                button.alpha = 0.75
            }
            
            self.numPad.alpha = 0.75
        }
        
        self.hideUndoRedo()
        self.hideRedoButton()
    }
    
    override func activateInterface() {
        numPad.userInteractionEnabled = true
        board.userInteractionEnabled = true
        numPad.refresh()
        
        var buttons = allButtons
        for removable in [playAgainButton, undoButton, redoButton] {
            buttons.remove(removable)
        }
        
        UIView.animateWithDuration(0.25) {
            
            for button in buttons {
                button.userInteractionEnabled = true
                button.alpha = 1
            }
            
            self.numPad.alpha = 1.0
        }
    }
    
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
            if notes.contains(value){
                notes.remove(value)
            } else {
                notes.insert(value)
            }
            selected.notesArray = Array(notes)
            numPad.refresh()
        }
        
    }
    
    //MARK: show/hide undo/redo buttons
    
    func hideUndoRedo() {
        print("calling undo changed from hideUndoRedo")
        dispatch_async(dispatch_get_main_queue(), {
            self.hideUndoButton()
            self.hideRedoButton()
        })
        
    }
    
    func hideUndoButton() {
        
        if undoHidden {
            return
        }
        
        undoHidden = true
        
      

    }
    
    func showUndoButton() {
        
        if !undoHidden {
            return
        }
        
        undoHidden = false
    }
    
    func hideRedoButton() {
        if redoHidden {
            return
        }
        
        redoHidden = true
    
    }
    
    func showRedoButton() {
        if !redoHidden {
            return
        }
        
        redoHidden = false
        
    }
    
    //MARK: managedObjectContext handlers
    
    func handleManagedObjectChange(notification: NSNotification) {
        
        guard let infoDict = notification.userInfo as? [String: AnyObject] else {
            return
        }
        
        if let updates = infoDict[NSUpdatedObjectsKey] as? Set<BackingCell> where updates.count > 0  {
            for cell in updates {
                if let tile = tileWithBackingCell(cell) {
                    tile.refreshLabel()
                    numPad.refresh()
                }
            }
        }
        if managedObjectContext.undoManager!.canUndo {
            if undoButton.alpha == 0 {
                print("calling show undo from handleManagedObjectChange")
                showUndoButton()
            }
        } else {
            if undoButton.alpha == 1 {
                hideUndoButton()
            }
        }
        if managedObjectContext.undoManager!.canRedo {
            if redoButton.alpha == 0  {
                showRedoButton()
            }
        } else {
            if redoButton.alpha == 1 {
                hideRedoButton()
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
        managedObjectContext.processPendingChanges()
        if !managedObjectContext.undoManager!.canUndo {
            if undoButton.alpha == 1 {
                hideUndoButton()
            }
        }
    }
    
    func handleRedoNotification(notification: NSNotification) {
        managedObjectContext.processPendingChanges()
        if !managedObjectContext.undoManager!.canRedo {
            if redoButton.alpha == 1 {
               hideRedoButton()
            }
        }
    }
    
    func cleanUp() {
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.removeObserver(self)
        
       
        if managedObjectContext.undoManager!.undoRegistrationEnabled {
            managedObjectContext.undoManager!.disableUndoRegistration()
        }
        
        managedObjectContext.processPendingChanges()
        managedObjectContext.undoManager!.removeAllActions()

        CoreDataStack.sharedStack.saveMainContext()
        clearPuzzle()
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
        
        let symbols = NSUserDefaults.standardUserDefaults().objectForKey(Utils.Identifiers.symbolSetKey) as! Int
        
        noteButton.hidden = symbols > 0
        
        
    }
    
    func popoverPresentationControllerShouldDismissPopover(popoverPresentationController: UIPopoverPresentationController) -> Bool {
    
        if self.presentedViewController!.isKindOfClass(ChoosePuzzleController) && (puzzle == nil || puzzleIsSolved) {
            return false
        } else if self.presentedViewController!.isKindOfClass(PuzzleOptionsViewController){
            NSUserDefaults.standardUserDefaults().synchronize()
        } else if self.presentedViewController!.isKindOfClass(ClearMenuController){
            clearButton.selected = false
        }
        
        return true
    }
    
    
    //MARK: popover management
    func showOptions(sender: AnyObject) {
        
        let poController = PuzzleOptionsViewController(style: .Plain)
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(self.view.frame.width * 4/9, self.view.frame.height * 4/9)
        
        let sender = sender as! UIButton
        sender.selected = true
        let ppc = poController.popoverPresentationController
        ppc?.sourceView = sender
        ppc?.sourceRect = sender.bounds
        ppc?.permittedArrowDirections = .Left
        ppc?.backgroundColor = Utils.Palette.getTheme()
        
        ppc?.delegate = self
        
        self.presentViewController(poController, animated: true, completion: nil)
        
    }
    
    func showHelpMenu(sender: AnyObject) {
        
        
        let poController = HelpMenuController(style: .Grouped)
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(225, 250)
        
        let sender = sender as! UIButton
        sender.selected = true
        let ppc = poController.popoverPresentationController
        ppc?.sourceView = sender
        ppc?.sourceRect = sender.bounds
        ppc?.permittedArrowDirections = .Down
        ppc?.backgroundColor = Utils.Palette.getTheme()
        
        ppc?.delegate = self
        
        self.presentViewController(poController, animated: true, completion: nil)
        
    }
}

