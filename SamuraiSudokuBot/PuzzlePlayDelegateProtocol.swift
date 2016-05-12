//
//  PuzzlePlayDelegateProtocol.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation
import iAd

/*protocol BannerViewDelegate: class {
    var bannerView: ADBannerView {get}
    var bannerPin: NSLayoutConstraint? {get set}
    var bannerLayoutComplete: Bool {get set}
    
    var canDisplayBannerAds: Bool {get set}
    
    func layoutAnimated(animated: Bool)
    
    func bannerViewDidLoadAd(banner: ADBannerView!)
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!)
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool
}

extension BannerViewDelegate {
    var bannerView: ADBannerView {
        get {
            let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let bv = delegate.banner {
                return bv
            }
            
            delegate.banner = ADBannerView(adType: .Banner)
            delegate.banner?.delegate = delegate
            return delegate.banner!
        }
        
    }
    
    func layoutAnimated(animated: Bool) {
        guard let vc = self as? UIViewController, view = vc.view else {
            return
        }
        if !canDisplayBannerAds {
            if bannerPin?.constant != 0 {
                view.layoutIfNeeded()
                UIView.animateWithDuration(0.25) {
                    self.bannerPin?.constant = 0
                    view.layoutIfNeeded()
                }
            }
            return
        }
        
        if bannerView.bannerLoaded  {
            if bannerPin?.constant == 0 {
                view.layoutIfNeeded()
                UIView.animateWithDuration(0.25) {
                    self.bannerPin?.constant = -self.bannerView.frame.size.height
                    view.layoutIfNeeded()
                }
            }
        } else {
            if bannerPin?.constant != 0 {
                view.layoutIfNeeded()
                UIView.animateWithDuration(0.25) {
                    self.bannerPin?.constant = 0
                    view.layoutIfNeeded()
                }
                
            }
            
        }
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        
        layoutAnimated(true)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        
        layoutAnimated(true)
    }
    
    
}*/

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
    //func setUpButtons()
    func setUpBoard()
    func boardReady()
    
    func tileTapped(sender: AnyObject?)
    
   // func refreshNoteButton()
    
    // (de)activate interface
    func activateInterface()
    func deactivateInterface()
    func bannerViewActionDidFinish(banner: ADBannerView!)
    
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
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        activateInterface()
        
    }
    
    func activateInterface() {
        board.userInteractionEnabled = true
    }
    
    func deactivateInterface() {
        board.userInteractionEnabled = false
    }
    
    func wakeFromBackground() {
        activateInterface()
    }
    
    
    func goToBackground() {
        deactivateInterface()
        
        /*if canDisplayBannerAds {
            bannerView.removeFromSuperview()
            canDisplayBannerAds = false
            bannerLayoutComplete = false
            layoutAnimated(false)
        }*/
    }
    
    
    //MARK: BannerViewDelegate
    /*func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        if banner.bannerLoaded {
            return true
        } else {
            activateInterface()
            layoutAnimated(true)
            return false
        }
    }*/
    
    //MARK: NumPadDelegate
    var currentValue: Int {
        get {
            if selectedTile?.noteMode == true {
                return 0
            }
            if let sel = selectedTile {
                let val = sel.displayValue.rawValue
                return val
            }
            return 0
        }
    }
    
}







protocol PlayPuzzleDelegate:class, SudokuControllerDelegate {
    var puzzle:Puzzle? {get set}
    var difficulty: PuzzleDifficulty {get set}
    var wrongTiles: [Tile] {get}
    var annotatedTiles: [Tile] {get}
    var revealedTiles: [Tile] {get}
    var gameOver: Bool {get}
    
    // required UI elements
    var longFetchLabel: UILabel {get}
    var spinner: UIActivityIndicatorView {get}
    var hintButton: UIButton! {get}
    var optionsButton: UIButton! {get}
    var noteButton: UIButton! {get set}
    var clearButton: UIButton! {get set}
    var alertController: UIAlertController? {get set}
    var puzzleMenuAnchor: UIView! {get}
   
    
    //func tileWithBackingCell(cell: BackingCell) -> Tile?
    
    // managing interface
    func toggleNoteMode(sender: AnyObject?)
    func refreshNoteButton()
    
    // overrides default implementation of activateInterface(), deactivateInterface() & wakeFromBackground()
    
    
    // initial puzzle loading
    func showChoosePuzzleController()
    func prepareForLongFetch()
    func fetchPuzzle()
    func puzzleReady()
    
    
    
    // hints
    func showHint()
    func animateDiscoveredTile(tile: Tile, wrong:Bool, delay: Double, handler: (()->Void)?)
    
    
    // handling puzzle completion
    func checkSolution()
    func puzzleSolved()
    func giveUp()
    
    func replayCurrent()
    func playAgain(sender: AnyObject)
    func newPuzzleOfDifficulty(difficulty: PuzzleDifficulty, replay:Bool)
    
    
    func clearAll()
    func clearSolution()
    
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
        return nil
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
    
    func deactivateInterface() {
        board.userInteractionEnabled = false
        
        UIView.animateWithDuration(0.25) {

            self.noteButton?.alpha = 0.5
            self.optionsButton.alpha = 0.5
            self.clearButton?.alpha = 0.5
            
        }
    }
    
    func activateInterface() {
        numPad.userInteractionEnabled = true
        board.userInteractionEnabled = true
        numPad.refresh()
        
        UIView.animateWithDuration(0.25) {
          
            self.noteButton?.alpha = 1.0
            self.optionsButton.alpha = 1.0
            self.clearButton?.alpha = 1.0
            
        }
        
    }
    
    func wakeFromBackground() {
        //TODO: saved puzzle handling
        
        activateInterface()
        
        /*if self.puzzle != nil && !canDisplayBannerAds {
            bannerLayoutComplete = false
            canDisplayBannerAds = true
        }*/
    }
    
    
    //MARK: initial puzzle loading
    
    func showChoosePuzzleController() {
        guard let vc = self as? SudokuController else{
            return
        }
        
        let poController = ChoosePuzzleController(style: .Grouped)
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(vc.view.frame.width * 1/4, vc.view.frame.height * 1/4)
    
        
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
            self.longFetchLabel.frame = CGRectMake(0, 0, self.topAnchorBoard.frame.width, self.topAnchorBoard.frame.height * 0.25)
        }
        
        
        
        
        let middleTile = topAnchorBoard.tileAtIndex((5,4))
        if !spinner.isAnimating() {
            middleTile.selectedColor = UIColor.blackColor()
            selectedTile = middleTile
            spinner.startAnimating()
        }
        
        
    }
    
    func fetchPuzzle() {
        
        print("fetchPuzzle default PPCD implementation called")
        
        guard let vc = self as? UIViewController else {
            return
        }
        
        deactivateInterface()
        
        let middleBoard = boards[0]
        
        let placeHolderColor = middleBoard.tileAtIndex((1,1)).selectedColor
        let middleTile = middleBoard.tileAtIndex((5,4))
        
        let handler: (Puzzle -> ()) = {
            puzzle -> () in
            self.spinner.stopAnimating()
            middleTile.selectedColor = placeHolderColor
            
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
        for tile in givens {
            tile.userInteractionEnabled = false
        }
        
        if startingNilTiles.count != 0 {
            selectedTile = startingNilTiles[0]
        }
        
        
        for tile in startingNilTiles {
            tile.userInteractionEnabled = true
        }
        
        activateInterface()
        /*if !canDisplayBannerAds {
            bannerView.userInteractionEnabled = true
            bannerLayoutComplete = false
            canDisplayBannerAds = true
        }*/
        
        
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
        
        
        let tile = wrongsCount > 0 ? wrongs[0] : nils[Int(arc4random_uniform((UInt32(nils.count))))]
        
        animateDiscoveredTile(tile)
        
    }
    
    func animateDiscoveredTile(tile: Tile, wrong:Bool = false, delay: Double = 0, handler: (()->Void)? = nil) {
        
        let lastSelected = selectedTile
        
        selectedTile = nil
        
        let label = tile.valueLabel
        
        tile.labelColor = UIColor.whiteColor()
        
        let flickerBlock: () -> Void = { () in
            UIView.setAnimationRepeatCount(1.0)
            label.alpha = 0
            label.alpha = 1
        }
        
        if let tv = tile.solutionValue {
            tile.setValue(tv)
        }
        if wrong {
            tile.backgroundColor = tile.wrongColor
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, options: [.Repeat, .CurveEaseIn, .Autoreverse], animations: flickerBlock) { (finished) in
            
            if finished {
                let colorBlock: () -> Void = { () in
                    label.alpha = 1
                }
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: colorBlock) { (finished) in
                    
                    UIView.animateWithDuration(0.5) { () in
                        //tile.backgroundColor = wrong ? tile.wrongColor : tile.defaultBackgroundColor
                        //tile.labelColor = wrong ? tile.defaultTextColor : tile.chosenTextColor
                        //tile.valueLabel.textColor = tile.labelColor
                        tile.revealed = true
                    }
                    
                    if finished {
                        let nils = self.nilTiles
                        let nilsCount = nils.count
                        let toSelect:Tile? = nilsCount > 0 ? nils[0] : nil
                        self.selectedTile = lastSelected?.displayValue == .Nil ? lastSelected : toSelect
                        if let completionHandler = handler {
                            completionHandler()
                        }
                    }
                    
                }
            }
            
        }
        
    }
    
    func giveUp() {
        
        deactivateInterface()
        var lastTile: Tile?
        if !nilTiles.isEmpty {
            lastTile = nilTiles[nilTiles.count-1]
        }
        
        let completion: (()->()) = {
            for wrongTile in self.wrongTiles {
                self.animateDiscoveredTile(wrongTile, wrong: true)
                wrongTile.userInteractionEnabled = false
            }

            self.board.userInteractionEnabled = false
            self.board.alpha = 1.0
            for tile in self.tiles {
                tile.userInteractionEnabled = false
            }
        }
        
        for nilTile in nilTiles {
            if lastTile == nil {
                animateDiscoveredTile(nilTile, handler: completion)
                
            } else {
                if nilTile == lastTile {
                    animateDiscoveredTile(nilTile, handler: completion)
                    
                } else {
                    animateDiscoveredTile(nilTile)
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
                tile.setValue(0)
            }
        }
        
        
        
        for tile in givens {
            tile.userInteractionEnabled = false
        }
        
    }
    
    func playAgain(sender: AnyObject) {
        
        guard let vc = self as? UIViewController else {
            return
        }
        
        alertController = UIAlertController(title: "New Game", message: "Select a difficulty level, or choose replay puzzle", preferredStyle: .Alert)
        
        guard let puzzleSelectAlert = alertController else{
            return
        }
        
        let easy = UIAlertAction(title: "Easy", style: UIAlertActionStyle.Default) { (_) in
            self.newPuzzleOfDifficulty(.Easy)
        }
        let medium = UIAlertAction(title: "Medium", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(.Medium)
        }
        let hard = UIAlertAction(title: "Hard", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(.Hard)
        }
        let insane = UIAlertAction(title: "Insane", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(.Insane)
        }
        
        for action in [easy, medium, hard, insane] {
            puzzleSelectAlert.addAction(action)
        }
        
        
        if difficulty != .Easy {
            let pStore = PuzzleStore.sharedInstance
            let current = pStore.getPuzzleDifficulty()
            pStore.setPuzzleDifficulty(.Easy)
            let min = pStore.getPuzzleDifficulty()
            let newLevel = current - 10 < min ? PuzzleDifficulty.Easy : PuzzleDifficulty.Custom(current-10)
            
            let easier = UIAlertAction(title: "Slightly easier", style: .Default) { (_) in
                self.difficulty = newLevel
                self.clearPuzzle()
                self.fetchPuzzle()
            }
            
            puzzleSelectAlert.addAction(easier)
        }
        
        let replay = UIAlertAction(title: "Re-play puzzle", style: .Default) { (_) in
            self.newPuzzleOfDifficulty(self.difficulty, replay: true)
        }
        
        puzzleSelectAlert.addAction(replay)
        
        vc.presentViewController(puzzleSelectAlert, animated: true, completion: nil)
    }
    
    
    func newPuzzleOfDifficulty(difficulty: PuzzleDifficulty, replay:Bool = false) {
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
    }
    
    
    
    //MARK: clearing input
    
    func clearAll() {
        for tile in self.startingNilTiles {
            tile.setValue(0)
        }
    }
    
    func clearPuzzle() {
        for tile in self.tiles {
            tile.backingCell = nil
        }
    }
    
    func clearSolution() {
        
        guard let vc = self as? UIViewController else {
            return
        }
        
        alertController = UIAlertController(title: "Are you sure?", message: "This will cause all of the values you've entered to be removed and cannot be undone.", preferredStyle: .Alert)
        let oKay = UIAlertAction(title: "Clear", style: .Default) { (_) in
           self.clearAll()
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
            tile.backgroundColor = tile.defaultBackgroundColor
        }
        
        alertController = UIAlertController(title: "Puzzle Solved", message: "Well done!", preferredStyle: .Alert)
        
        guard let alertController = self.alertController, let vc = self as? SudokuController else {
            return
        }
        
        
        let newPuzz = UIAlertAction(title: "Play Again!", style: .Default) {(_) in
            self.clearPuzzle()
            self.fetchPuzzle()
        }
        
        alertController.addAction(newPuzz)
        
        
        if difficulty != .Insane {
            let pStore = PuzzleStore.sharedInstance
            let current = pStore.getPuzzleDifficulty()
            pStore.setPuzzleDifficulty(.Insane)
            let max = pStore.getPuzzleDifficulty()
            let newLevel = current + 10 > max ? PuzzleDifficulty.Insane : PuzzleDifficulty.Custom(current+10)
            
            
            let harderPuzz = UIAlertAction(title: "Slightly tougher", style: .Default) { (_) in
                self.clearPuzzle()
                self.difficulty = newLevel
                self.fetchPuzzle()
            }
            alertController.addAction(harderPuzz)
        }
        
        
        
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (_) in
            self.clearPuzzle()
            self.fetchPuzzle()
        }
        alertController.addAction(OKAction)
        
        var doneCount = 0
        func flashBoxAnimationsWithBoxes(boxes: [Box]) {
            var boxes = boxes
            let tiles = boxes[0].boxes
            UIView.animateWithDuration(0.15, animations: {
                for tile in tiles {
                    tile.backgroundColor = tile.assignedBackgroundColor
                }
            }) { finished in
                boxes.removeAtIndex(0)
                if finished {
                    UIView.animateWithDuration(0.15, animations: {
                        for tile in tiles {
                            tile.backgroundColor = tile.defaultBackgroundColor
                        }
                    }) { finished in
                        if finished {
                            if boxes.isEmpty {
                                UIView.animateWithDuration(0.15, animations: {
                                    for tile in self.tiles {
                                        tile.backgroundColor = tile.assignedBackgroundColor
                                    }
                                }) { finished in
                                    if finished {
                                        doneCount += 1
                                        if doneCount == self.boards.count {
                                            vc.presentViewController(self.alertController!, animated: true, completion: nil)
                                            
                                        }
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
        
    }
    
    //MARK: settings and help
    
    func showOptions(sender: AnyObject) {
        
        guard let vc = self as? UIViewController else {
            return
        }
        
        let poController = PuzzleOptionsViewController(style: .Grouped)
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(300, 350)
        
        let sender = sender as! UIButton
        sender.selected = true
        let ppc = poController.popoverPresentationController
        ppc?.sourceView = sender
        ppc?.sourceRect = sender.bounds
        ppc?.permittedArrowDirections = .Left
        ppc?.backgroundColor = Utils.Palette.green
        
        if let popD = vc as? UIPopoverPresentationControllerDelegate {
            ppc?.delegate = popD
        }
        
        vc.presentViewController(poController, animated: true, completion: nil)
        
    }
    
    func showHelpMenu(sender: AnyObject) {
        guard let vc = self as? UIViewController else {
            return
        }
        
        let poController = HelpMenuController(style: .Grouped)
        poController.modalPresentationStyle = .Popover
        poController.preferredContentSize = CGSizeMake(225, 225)
        
        let sender = sender as! UIButton
        sender.selected = true
        let ppc = poController.popoverPresentationController
        ppc?.sourceView = sender
        ppc?.sourceRect = sender.bounds
        ppc?.permittedArrowDirections = .Down
        ppc?.backgroundColor = Utils.Palette.green
        
        if let popD = vc as? UIPopoverPresentationControllerDelegate {
            ppc?.delegate = popD
        }
        
        vc.presentViewController(poController, animated: true, completion: nil)
        
    }
    
}