//
//  PuzzlePlayDelegateProtocol.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation
import UIKit

protocol NumPadDelegate {
    var currentValue: Int {get}
    var noteMode: Bool {get set}
    
    func valueSelected(value: UIButton)
    func noteValueChanged(value: Int)
    
    func noteValues() -> [Int]?
    
    
}

protocol SudokuControllerDelegate: class, NumPadDelegate {
    var topAnchorBoard: SudokuBoard {get}
    var bottomAnchorBoard: SudokuBoard {get}
    var board: SudokuBoard {get}
    var boards: [SudokuBoard] {get}
    
    var tiles:[Tile] {get}
    var givens:[Tile] {get}
    var startingNilTiles:[Tile] {get}
    var nilTiles:[Tile] {get}
    var nonNilTiles:[Tile] {get}
    var selectedTile:Tile? {get set}
    //var noteMode:Bool {get set}
    
    weak var numPad: SudokuNumberPad! {get}
    
    
    func tileAtIndex(index: TileIndex, forBoard board: SudokuBoard?) -> Tile?
    func boardSelectedTileChanged()

    func setUpBoard()
    func boardReady()
    
    func tileTapped(sender: AnyObject?)
    
    
    // (de)activate interface
    func activateInterface()
    func deactivateInterface()
   
    
    func wakeFromBackground()
    func goToBackground()
    
    
    // num pad delegate
    var currentValue: Int {get}
    var noteMode: Bool {get set}
    
    func valueSelected(value: UIButton)
    func noteValueChanged(value: Int)
    
    func noteValues() -> [Int]?
    
    
}

extension SudokuControllerDelegate {
    
    var givens: [Tile] {
        get {
            return tiles.filter({$0.backingCell!.puzzleSolution == nil})
        }
    }
    
    var startingNilTiles: [Tile] {
        get {
            return tiles.filter({$0.backingCell!.puzzleInitial == nil})
        }
    }
    
    var nilTiles: [Tile] {
        get {
            return tiles.filter({$0.displayValue == .Nil})
            
        }
    }
    
    var nonNilTiles: [Tile] {
        get {
            return tiles.filter({$0.displayValue != .Nil})
        }
    }
    
       
    func tileAtIndex(index: TileIndex, forBoard board: SudokuBoard?)->Tile? {
        if let suppliedBoard = board {
            return suppliedBoard.tileAtIndex(index)
        }
        
        return self.board.tileAtIndex(index)
    }
    
    func boardSelectedTileChanged() {
        numPad.refresh()
    }
    
    
    func wakeFromBackground() {
        activateInterface()
    }
    
    
    func goToBackground() {
        deactivateInterface()
        
    }

    
}







protocol PlayPuzzleDelegate:class, SudokuControllerDelegate {
    var puzzle:Puzzle? {get set}
    var difficulty: PuzzleDifficulty {get set}
    var wrongTiles: [Tile] {get}
    var annotatedTiles: [Tile] {get}
    var revealedTiles: [Tile] {get}
    var gameOver: Bool {get}
    var tileMap: [Int: [String: Tile]] {get}
    var userSolvedPuzzle: Bool? {get set}
    
    // required UI elements
    var longFetchLabel: UILabel {get}
    var spinner: UIActivityIndicatorView {get}
    var hintButton: UIButton! {get}
    var optionsButton: UIButton! {get}
    var noteButton: UIButton! {get set}
    var clearButton: UIButton! {get set}
    var alertController: UIAlertController? {get set}
    var puzzleMenuAnchor: UIView! {get}
   
    
    func tileWithBackingCell(cell: BackingCell) -> Tile?
    
    // managing interface
    func toggleNoteMode(sender: AnyObject?)
    func refreshNoteButton()
    func handleManagedObjectChange(notification: NSNotification)
    
    
    // initial puzzle loading
    func showChoosePuzzleController(currentDifficulty:Int?)
    func prepareForLongFetch()
    func fetchPuzzle(mostRecent:Bool)
    func puzzleReady()
    
    
    // hints
    func showHint()
    func animateDiscoveredTile(tile: Tile, wrong:Bool, delay: Double, handler: (()->Void)?)
    
    
    // handling puzzle completion
    func checkSolution()
    func puzzleSolved()
    func presentGiveUpAlert()
    func giveUp()
    func cleanUp()
    
    func replayCurrent()
    //func newPuzzleOfDifficulty(difficulty: PuzzleDifficulty, replay:Bool)
    
    // clearing content
    func showClearMenu(sender: AnyObject?)
    func presentClearSolutionAlert()
    func clearSolution()
    func presentClearPuzzleAlert()
    func clearPuzzle()
    
    // audioplayer functions
    
    func playSelectedTileChanged()
    
    func playValueSelected()
    
    func playPuzzleCompleted()
    func playPuzzleFetched()
    
    func playHintGiven()
    func playGiveUp()
    func playUndoRedo()
    func playDiscardPuzzle()
    func playStartOver()
    
    func playAudioAtURL(url:NSURL)
    
}

extension PlayPuzzleDelegate {
    
    var  wrongTiles: [Tile]{
        return startingNilTiles.filter({$0.displayValue.rawValue != 0 && $0.displayValue.rawValue != $0.solutionValue})
    }
    
    var annotatedTiles: [Tile] {
        return nilTiles.filter({$0.noteValues.count > 0})
    }
    
    var revealedTiles: [Tile] {
        return nonNilTiles.filter({$0.revealed})
    }
    
    var gameOver: Bool {
        return self.nilTiles.count == 0 && wrongTiles.count == 0
    }
    
    func tileWithBackingCell(cell: BackingCell) -> Tile? {
        // TODO
        
        let board = cell.board as Int
        let row = cell.row as Int
        let column = cell.column as Int
    
        return tileMap[board]?[String(row) + String(column)]
    }

    
    //MARK: managing interface
    
    func refreshNoteButton() {
        if let noteButton = noteButton {
            noteButton.backgroundColor = UIColor.whiteColor()
            noteButton.layer.borderColor = UIColor.blackColor().CGColor
            noteButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
            if let selected = selectedTile {
                if selected.noteMode {
                    noteButton.backgroundColor = UIColor.blackColor()
                    noteButton.layer.borderColor = UIColor.whiteColor().CGColor
                    noteButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
                }
            }
            
        }
    }
    
    
    func wakeFromBackground() {
        //TODO: saved puzzle handling
        activateInterface()
        
    }
    
    
    //MARK: initial puzzle loading
    
    func showChoosePuzzleController(currentDifficulty: Int? = nil) {
        guard let vc = self as? SudokuController else{
            return
        }
        
        var poController: ChoosePuzzleController
        
        if let success = userSolvedPuzzle {
            poController = ChoosePuzzleController(style: .Plain, successfullyCompleted:success, gaveUp: !success, previousDifficulty: currentDifficulty)
        } else {
            poController = ChoosePuzzleController(style: .Plain, successfullyCompleted:false, gaveUp: false, previousDifficulty: currentDifficulty)
        }
        
        
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(vc.view.frame.width * 2/5, vc.view.frame.height * 6/15)
        poController.puzzleController = self
        
        
        let ppc = poController.popoverPresentationController
        ppc?.permittedArrowDirections = .Up
        ppc?.backgroundColor = UIColor.clearColor()
        ppc?.sourceView = puzzleMenuAnchor
        ppc?.sourceRect = puzzleMenuAnchor.bounds
        
        
        if let popD = vc as? UIPopoverPresentationControllerDelegate {
            ppc?.delegate = popD
        }
        
        vc.presentViewController(poController, animated: true, completion: nil)
    }
    
    func prepareForLongFetch() {
        guard let vc = self as? UIViewController else {
            return
        }
        
        UIView.animateWithDuration(0.35) {
            vc.navigationController?.navigationBarHidden = true
            self.deactivateInterface()
            self.longFetchLabel.hidden = false
        }
        
        
        selectedTile = nil
        
        let middleTile = boards[0].tileAtIndex((5,4))
        let middleBoard = middleTile.superview as! Box
        
        if !spinner.isAnimating() {
            spinner.frame = middleBoard.bounds
            middleBoard.addSubview(spinner)
            spinner.color = UIColor.blackColor()
            spinner.backgroundColor = Utils.Palette.getTheme()
            spinner.startAnimating()
        }
        
        
    }
    
    func fetchPuzzle(mostRecent:Bool = false) {
        
        guard let vc = self as? UIViewController else {
            return
        }
        
        deactivateInterface()
        
        let handler: (Puzzle -> ()) = {
            puzzle -> () in
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
            
            for cell in self.puzzle!.solutionArray() {
                let tile = self.board.tileAtIndex((cell.convertToTileIndex()))
                tile.backingCell = cell
                
            }
            for cell in self.puzzle!.initialsArray(){
                let tile = self.board.tileAtIndex(cell.convertToTileIndex())
                tile.backingCell = cell
            }
            
            self.board.userInteractionEnabled = true
            UIView.animateWithDuration(0.35) {
                vc.navigationController?.navigationBarHidden = false
                self.longFetchLabel.hidden = true
            }
            
            self.puzzleReady()
            
        }
        
        PuzzleStore.sharedInstance.getPuzzleForController(self, withCompletionHandler: handler)
    }
    
    
    func puzzleReady() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let placekeeper = defaults.objectForKey(Utils.Identifiers.soundKey) as! Bool
        
        
        defaults.setBool(false, forKey: Utils.Identifiers.soundKey)
        
        if startingNilTiles.count != 0 {
            selectedTile = startingNilTiles[0]
        }
        
        defaults.setBool(placekeeper, forKey: Utils.Identifiers.soundKey)
        
        dispatch_async(concurrentPuzzleQueue, {self.playPuzzleFetched()})
        
        userSolvedPuzzle = nil

        activateInterface()
        
        if let undoManager = CoreDataStack.sharedStack.managedObjectContext.undoManager {
            
            if !undoManager.undoRegistrationEnabled {
                CoreDataStack.sharedStack.managedObjectContext.processPendingChanges()
                undoManager.removeAllActions()
                undoManager.enableUndoRegistration()
                undoManager.removeAllActions()
            } else {
                undoManager.removeAllActions()
                CoreDataStack.sharedStack.managedObjectContext.processPendingChanges()
                undoManager.removeAllActions()
            }
        }
        
    }
    
    //MARK: hints
    
    func showHint() {
        
        guard let vc = self as? UIViewController else {
            return
        }
        
        // pull a value from the puzzle solution and animate it onto the board
        let nils = nilTiles
        let nilsCount = nils.count
        
        let wrongs = wrongTiles
        let wrongsCount = wrongs.count
        
        if nilsCount < 2 && wrongsCount == 0 {
            alertController = UIAlertController(title: "Try harder.", message: "I think you can do this...", preferredStyle: .Alert)
            guard let alertController = alertController else {
                return
            }
            
            let oKay =  UIAlertAction(title: "OK", style: .Cancel) {
                (_) in
                self.activateInterface()
            }
            alertController.addAction(oKay)
            
            vc.presentViewController(alertController, animated: true, completion: nil)
            
            return
        }
        
        let tile = nils[Int(arc4random_uniform((UInt32(nils.count))))]
        
        dispatch_async(concurrentPuzzleQueue, {self.playHintGiven()})
        
        let context = CoreDataStack.sharedStack.managedObjectContext
        if context.undoManager!.undoRegistrationEnabled {
            context.processPendingChanges()
            context.undoManager?.removeAllActions()
            context.undoManager!.disableUndoRegistration()
        }
        

        animateDiscoveredTile(tile, handler: {
            context.processPendingChanges()
            if !context.undoManager!.undoRegistrationEnabled {
                context.processPendingChanges()
                context.undoManager!.enableUndoRegistration()
            }
            
        })
        
    }
    
    func animateDiscoveredTile(tile: Tile, wrong:Bool = false, delay: Double = 0, handler: (()->Void)? = nil) {
        
        selectedTile = nil
        
        let label = tile.valueLabel
        
        tile.revealed = true
        
        tile.labelColor = UIColor.whiteColor()
        
        let flickerBlock: () -> Void = { () in
            UIView.setAnimationRepeatCount(1.0)
            label.alpha = 0
            label.alpha = 1
        }
        
       
        if wrong {
            tile.backgroundColor = tile.wrongColor
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.Repeat, .CurveEaseIn, .Autoreverse], animations: flickerBlock) { (finished) in
            
            if finished {
                let endBlock: () -> Void = { () in
                    label.alpha = 1
                }
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: endBlock) { (finished) in
                    if finished {
                        if let completionHandler = handler {
                            completionHandler()
                    
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    
    //MARK: replay / new puzzle
    
    func replayCurrent() {
        if puzzle == nil {
            return
        }
        
        
        UIView.animateWithDuration(0.5) {
            for tile in self.startingNilTiles {
                tile.userInteractionEnabled = true
                tile.backingCell?.assignValue(0)
            }
        }
        
        
        for tile in givens {
            tile.userInteractionEnabled = false
        }
        
    }


 /*   func newPuzzleOfDifficulty(difficulty: PuzzleDifficulty, replay:Bool = false) {
        if replay {
            replayCurrent()
            activateInterface()
            for tile in nilTiles {
                tile.userInteractionEnabled = true
            }
            
        } else {
            clearPuzzle()
            self.difficulty = difficulty
            
            fetchPuzzle()
        }
    }*/
    
    
    
    //MARK: clearing content
    
    func showClearMenu(sender: AnyObject?) {
        guard let vc = self as? SudokuController else{
            return
        }
        
        if let button = sender as? UIButton {
            button.selected = true
        }
        
        let poController:ClearMenuController = ClearMenuController(style: .Plain)
        
        
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(vc.view.frame.width * 2/5, vc.view.frame.height * 1/4)
        
        let ppc = poController.popoverPresentationController
        ppc?.permittedArrowDirections = .Up
        ppc?.backgroundColor = UIColor.clearColor()
        ppc?.sourceView = puzzleMenuAnchor
        ppc?.sourceRect = puzzleMenuAnchor.bounds
        
        
        if let popD = vc as? UIPopoverPresentationControllerDelegate {
            ppc?.delegate = popD
        }
        
        vc.presentViewController(poController, animated: true, completion: nil)

    }
    
    func clearSolution() {
        let context = PuzzleStore.sharedInstance.managedObjectContext
        
        context.processPendingChanges()
        context.undoManager!.removeAllActions()
        if context.undoManager!.undoRegistrationEnabled {
            context.undoManager!.disableUndoRegistration()
            if let ssb = self as? SamuraiSudokuController {
                ssb.hideUndoRedo()
            }
        }

        dispatch_async(concurrentPuzzleQueue, {
            self.playStartOver()
        })
        for tile in self.startingNilTiles {
            tile.backingCell?.assignValue(0)
        }
        
        if !context.undoManager!.undoRegistrationEnabled {
            context.processPendingChanges()
            context.undoManager!.removeAllActions()
            if !context.undoManager!.undoRegistrationEnabled {
                print("about to enable from clearSolution")
                context.undoManager!.enableUndoRegistration()
            }
            
        }
        
    }
    
    func clearPuzzle() {
        let context = PuzzleStore.sharedInstance.managedObjectContext
        
        context.processPendingChanges()
        context.undoManager!.removeAllActions()
        if context.undoManager!.undoRegistrationEnabled {
            context.undoManager!.disableUndoRegistration()
            if let ssb = self as? SamuraiSudokuController {
                ssb.hideUndoRedo()
            }
        }
        
        dispatch_async(concurrentPuzzleQueue, {
            self.playDiscardPuzzle()
        })
        
        for tile in self.tiles {
            tile.backingCell = nil
        }
        
        self.puzzle = nil
    }
    
    func presentClearSolutionAlert() {
        
        guard let vc = self as? UIViewController else {
            return
        }
        
        alertController = UIAlertController(title: "Are you sure?", message: "This will cause all of the values you've entered to be removed and cannot be undone.", preferredStyle: .Alert)
        
       
        let oKay = UIAlertAction(title: "Clear", style: .Default) { (_) in
            
            self.clearSolution()
            self.activateInterface()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Default) {(_) in
            self.activateInterface()
        }
        
        alertController!.addAction(oKay)
        alertController!.addAction(cancel)
        
        vc.presentViewController(alertController!, animated: true) { (_) in
            self.deactivateInterface()
        }
        
    }
    
    func presentClearPuzzleAlert() {
        guard let vc = self as? UIViewController else {
            return
        }
        
        alertController = UIAlertController(title: "Are you sure?", message: "This will nuke this puzzle and cannot be undone.", preferredStyle: .Alert)
        
        
        let oKay = UIAlertAction(title: "Get on with it", style: .Default) { (_) in
            self.clearPuzzle()
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Default) {(_) in
            self.activateInterface()
        }
        
        alertController!.addAction(oKay)
        alertController!.addAction(cancel)
        
        vc.presentViewController(alertController!, animated: true) { (_) in
            self.deactivateInterface()
        }

    }
    
    //MARK: handling puzzle completion
    
    func giveUp() {
        
        
        let context = CoreDataStack.sharedStack.managedObjectContext
        
        if context.undoManager!.undoRegistrationEnabled {
            context.processPendingChanges()
            context.undoManager!.removeAllActions()
            context.undoManager!.disableUndoRegistration()
            context.processPendingChanges()
        }

        
        deactivateInterface()
        var lastTile: Tile?
        if !nilTiles.isEmpty {
            lastTile = nilTiles[nilTiles.count-1]
        }
        
        
        let completion: (()->()) = {
            
            for wrongTile in self.wrongTiles {
                self.animateDiscoveredTile(wrongTile, wrong: true)
            }
            
            self.userSolvedPuzzle = false
            
        }
        
        dispatch_async(concurrentPuzzleQueue, {self.playGiveUp()})
        
        for nilTile in nilTiles {
            if nilTile == lastTile {
                animateDiscoveredTile(nilTile, handler: completion)
                
            } else {
                animateDiscoveredTile(nilTile)
            }
        }
    }
    
    
    func presentGiveUpAlert() {
        guard let vc = self as? UIViewController else {
            return
        }
        
        alertController = UIAlertController(title: "Throwing in the towel?", message: "Say the word and I'll show you where all the numbers belong.", preferredStyle: .Alert)
        
        
        let oKay = UIAlertAction(title: "Do it.", style: .Default) { (_) in
            
            self.giveUp()
        
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .Default) {(_) in
            self.activateInterface()
        }
        
        alertController!.addAction(oKay)
        alertController!.addAction(cancel)
        
        vc.presentViewController(alertController!, animated: true) { (_) in
            self.deactivateInterface()
        }

    }
    
    func checkSolution() {
        print(nilTiles.count)
        if nilTiles.count == 0 {
            if wrongTiles.count == 0 {
                puzzleSolved()
            }
        }
    }
    
 
    func puzzleSolved() {
        
        selectedTile = nil
        
        numPad.userInteractionEnabled = false
        
        for tile in tiles {
            tile.userInteractionEnabled = false
            //tile.backgroundColor = tile.defaultBackgroundColor
        }
        
        
        var doneCount = 0
        func flashBoxAnimationsWithBoxes(boxes: [Box]) {
            var boxes = boxes
            let tiles = boxes[0].boxes
            UIView.animateWithDuration(0.15, animations: {
                for tile in tiles {
                    tile.prepareForPuzzleSolvedAnimation()
                }
            }) { finished in
                boxes.removeAtIndex(0)
                if finished {
                    UIView.animateWithDuration(0.15, animations: {
                        for tile in tiles {
                            tile.prepareForPuzzleSolvedAnimation()
                        }
                    }) { finished in
                        if finished {
                            if boxes.isEmpty {
                                UIView.animateWithDuration(0.15, animations: {
                                    for tile in self.tiles {
                                         tile.finishPuzzleSolvedAnimation()
                                    }
                                }) { finished in
                                    if finished {
                                        doneCount += 1
                                        if doneCount == 5 { self.userSolvedPuzzle = true}
                                    }
                                }
                                
                            } else {
                                flashBoxAnimationsWithBoxes(boxes)
                            }
                            
                        }
                    }
                }
            }
        }
        
        for board in boards {
            var boxes:[Box] = []
            
            let indices = [4,2,6,5,3,1,8,0,7]
            
            for index in indices {
                let aBox = board.boxes[index]
                boxes.append(aBox)
            }
            
            boxes = boxes.reverse()
            
            flashBoxAnimationsWithBoxes(boxes)
            
        }
        playPuzzleCompleted()
        deactivateInterface()
        
    }
    
    
  
    
}