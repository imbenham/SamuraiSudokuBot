//
//  SudokuViewControllers.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//


import UIKit
import iAd
//import AVFoundation

extension UINavigationController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if let presented = self.topViewController {
            return presented.supportedInterfaceOrientations()
        } else {
            return .AllButUpsideDown
        }
    }
}



/* This is intended as an abstract superclass and should not be instantiated and used directly. */

class SudokuController: UIViewController, SudokuControllerDelegate, NumPadDelegate, AVAudioPlayerDelegate {
    
    var noteMode = false
    
    let board: SudokuBoard = SudokuBoard(frame: CGRectZero)
    
    var topAnchorBoard: SudokuBoard{
        get {
            return board
        }
    }
    var bottomAnchorBoard: SudokuBoard {
        get {
            return board
        }
    }
    
    var tiles:[Tile] {
        get {
            return board.tiles
        }
    }
    
    // hackish solution to lack of optional properties in Swift protocols. 
    var boards: [SudokuBoard] {
        get {
            return [board]
        }
    }
    
    var audioPlayer: AVAudioPlayer?
    
    var soundOn: Bool {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let soundKey = Utils.Constants.Identifiers.soundKey
            guard let soundOn = defaults.objectForKey(soundKey) as? Bool else {
                return false
            }
            return soundOn
            
        }
        set {
            let defaults = NSUserDefaults.standardUserDefaults()
            let soundKey = Utils.Constants.Identifiers.soundKey
            defaults.setBool(!soundOn, forKey: soundKey)
        }
        
    }

    
    @IBOutlet weak var numPad: SudokuNumberPad!
    
    var selectedTile: Tile? {
        didSet {
            
            if selectedTile != oldValue {
                if noteMode {
                    noteMode = false
                }
                if selectedTile != nil {
                    playSelectedTileChanged()
                }

            }
            
            if let selected = selectedTile {
                selected.refreshLabel()
            }
            
            if let old = oldValue {
                old.refreshLabel()
            }
            
            numPad.refresh()
        }
    }

    
    var bannerPin: NSLayoutConstraint?
    var bannerLayoutComplete = false
    let spinner: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numPad.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*if  !canDisplayBannerAds {
            canDisplayBannerAds = true
            bannerView.userInteractionEnabled = true
        }*/
        
        activateInterface()
        
        // register to receive notifications when user defaults change
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: Utils.Constants.Identifiers.symbolSetKey, options: .New, context: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = selectedTile  {
            if selected.symbolSet != .Standard {
                noteMode = false
            }
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        /*if canDisplayBannerAds {
            let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.banner = nil
            canDisplayBannerAds = false
            bannerLayoutComplete = false
            layoutAnimated(false)
        }*/
        
    }
    
    
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    func setUpBoard() {
        
        board.translatesAutoresizingMaskIntoConstraints = false
        numPad.translatesAutoresizingMaskIntoConstraints = false
        
        let topPin = NSLayoutConstraint(item: board, attribute: .Top, relatedBy: .Equal, toItem: self.topLayoutGuide, attribute: .Bottom, multiplier: 1, constant: 10)
        let centerPin = NSLayoutConstraint(item: board, attribute: .CenterX, relatedBy: .Equal, toItem: originalContentView, attribute: .CenterX, multiplier: 1, constant: 0)
        let boardWidth = NSLayoutConstraint(item: board, attribute: .Width, relatedBy: .Equal, toItem: originalContentView, attribute: .Width, multiplier: 0.95, constant: 0)
        let boardHeight = NSLayoutConstraint(item: board, attribute: .Height, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1, constant: 0)
        
        let constraints = [topPin, centerPin, boardWidth, boardHeight]
        originalContentView.addConstraints(constraints)
        
        
        let numPadWidth = NSLayoutConstraint(item: numPad, attribute: .Width, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1, constant: 0)
        let numPadHeight = NSLayoutConstraint(item: numPad, attribute: .Height, relatedBy: .Equal, toItem: board, attribute: .Width, multiplier: 1/9, constant: 0)
        let numPadCenterX = NSLayoutConstraint(item: numPad, attribute: .CenterX, relatedBy: .Equal, toItem: board, attribute: .CenterX, multiplier: 1, constant: 0)
        let numPadTopSpace = NSLayoutConstraint(item: numPad, attribute: .Top, relatedBy: .Equal, toItem: board, attribute: .Bottom, multiplier: 1, constant: 8)
       
        originalContentView.addConstraints([numPadWidth, numPadHeight, numPadCenterX, numPadTopSpace])
        
        
        
        board.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1)
        
        
    }
    
   func tileTapped(sender: AnyObject?) {
    print("tile was tapperooed")
      if let tile = (sender as! UIGestureRecognizer).view as? Tile {
        
        print("box: \((tile.parentSquare! as! Box).index) tile: \(tile.index)")
         selectedTile = tile
      }
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let path = keyPath {
            if path == Utils.Constants.Identifiers.symbolSetKey {
                for tile in tiles {
                    tile.refreshLabel()
                }
                
            }
        }
    }
    
    deinit {
        
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: Utils.Constants.Identifiers.symbolSetKey)
        
    }
    
    func boardReady() {
        //override to provide any set up that depends on the board being initialized
        //this function is called by the board on its controller once the board is finished
        //initializing and laying out all of its sub-views
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
        print("Using SamController implementation")
        guard noteMode, let selected = selectedTile else {
            return nil
        }
        
        return selected.noteValues
    }
    
    var currentValue: Int {
        guard let selected = selectedTile else {
            return 0
        }
        
        return selected.displayValue.rawValue
    }

    
    func valueSelected(value: UIButton) {
        let value = value.tag
        if let selected = selectedTile?.backingCell {
            if selected.assignedValue?.integerValue == value {
                selected.assignValue(0)
            } else {
                selected.assignValue(value)
            }
        }
        
        numPad.refresh()
    }
    
    
    //MARK: audioplayer delegate and related functions
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
    }
    
     func playSelectedTileChanged() {
        guard soundOn else{return}
        let url = Utils.Sounds.SoundType.SelectedTileChanged.url
        playAudioAtURL(url)
    }
    
     func playValueSelected() {
        guard soundOn else{return}
        let url = Utils.Sounds.SoundType.ValueSelected.url
        playAudioAtURL(url)
    }
    
    func playPuzzleCompleted() {
        guard soundOn else{return}
        let url = Utils.Sounds.SoundType.PuzzleCompleted.url
        playAudioAtURL(url)
    }
    
    func playPuzzleFetched() {
        guard soundOn else{return}
        let url = Utils.Sounds.SoundType.PuzzleFetched.url
        playAudioAtURL(url)
    }
    
    func playHintGiven() {
        guard soundOn else{return}
        let url = Utils.Sounds.SoundType.HintGiven.url
        playAudioAtURL(url)
    }
    
    func playAudioAtURL(url:NSURL) {
        guard soundOn else{return}
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: url)
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            fatalError("audioplayer could not be initialized! \(error)")
        }

    }

    
}



class BasicSudokuController: SudokuController, PlayPuzzleDelegate {
    
    let containerView: UIView! = UIView(tag: 4)
    var puzzle: Puzzle?
    var difficulty: PuzzleDifficulty = .Medium
    
    let longFetchLabel = UILabel()
    var clearButton:UIButton! = UIButton(tag: 0)
    var hintButton: UIButton! = UIButton(tag: 1)
    let optionsButton: UIButton! = UIButton(tag: 2)
    let playAgainButton: UIButton = UIButton(tag: 3)
    var noteButton:UIButton! =  UIButton(tag: 5)
    var containerSubviews: (front: UIView, back: UIView)!
    var puzzleMenuAnchor: UIView! = UIView()
    
    var containerWidth: NSLayoutConstraint!
    var containerHeight: NSLayoutConstraint!
    
    var numPadHeight: CGFloat {
        get {
            return self.board.frame.size.width * 1/9
        }
    }
    
    var alertController:UIAlertController?
    
    var tileMap: [Int: [String: Tile]] {
        get {
            var map = [Int: [String: Tile]]()
            for board in self.boards {
                map[board.index] = board.tileMap
            }
            return map
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        containerSubviews = (front: hintButton, back:playAgainButton)
        
        
        containerView.backgroundColor = UIColor.clearColor()
        containerView.clipsToBounds = true
        containerView.layer.cornerRadius = containerView.frame.size.height/2
        containerView.layer.borderWidth = 3.0
        
        
        let nestedButtons = [hintButton, playAgainButton]
        
        for button in nestedButtons {
            button.frame = containerView.bounds
        }
        
        
        board.controller = self
        numPad.delegate = self
        view.addSubview(board)
        view.addSubview(numPad)
        boards[0].boxes[4].addSubview(spinner)
        longFetchLabel.hidden = true
        longFetchLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        board.addSubview(longFetchLabel)
        longFetchLabel.layer.zPosition = 1
        spinner.layer.zPosition = 1
        setUpBoard()
        setUpButtons()
        configureButtons()
        
       /* if self.canDisplayBannerAds  && !bannerLayoutComplete {
            view.addSubview(bannerView)
            
            bannerView.translatesAutoresizingMaskIntoConstraints = false
            
            originalContentView.removeConstraints()
            originalContentView.translatesAutoresizingMaskIntoConstraints = false
            
            
            bannerPin = NSLayoutConstraint(item: bannerView, attribute: .Top, relatedBy: .Equal, toItem: bottomLayoutGuide, attribute: .Top, multiplier: 1, constant: 0)
            bannerPin!.priority = 1000
            let bannerLeft = NSLayoutConstraint(item: bannerView, attribute: .Leading, relatedBy: .Equal, toItem:view, attribute: .Leading, multiplier: 1, constant: 0)
            let bannerRight = NSLayoutConstraint(item: bannerView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
            
            
            let contentBottom = NSLayoutConstraint(item: originalContentView, attribute: .Bottom, relatedBy: .Equal, toItem: bannerView, attribute: .Top, multiplier: 1, constant: 0)
            contentBottom.priority = 1000
            let contentLeft = NSLayoutConstraint(item: originalContentView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
            let contentRight = NSLayoutConstraint(item: originalContentView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
            let contentTop = NSLayoutConstraint(item: originalContentView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
            view.addConstraints([contentBottom, contentLeft, contentRight, contentTop, bannerPin!, bannerLeft, bannerRight])
            
            bannerLayoutComplete = true
            
            board.removeConstraints()
            setUpBoard()
            containerView.removeConstraints()
            setUpButtons()
            
        }*/
        
        longFetchLabel.layer.backgroundColor = UIColor.blackColor().CGColor
        longFetchLabel.textColor = UIColor.whiteColor()
        longFetchLabel.textAlignment = .Center
        longFetchLabel.numberOfLines = 2
        longFetchLabel.font = UIFont.systemFontOfSize(UIFont.labelFontSize())
        longFetchLabel.adjustsFontSizeToFitWidth = true
        
        longFetchLabel.text = "SudokuBot is cooking up a custom puzzle just for you!  It will be ready in a sec."
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        /*if self.puzzle != nil && !canDisplayBannerAds {
            canDisplayBannerAds = true
            bannerView.userInteractionEnabled = true
        }*/
        
        if self.puzzle == nil {
            let middleTile = self.board.tileAtIndex((5,4))
            middleTile.selectedColor = UIColor.blackColor()
            self.selectedTile = middleTile
            
            self.spinner.startAnimating()
            fetchPuzzle()
        }
        
        activateInterface()
        
        
        
        
        // register to receive notifications when user defaults change
        NSUserDefaults.standardUserDefaults().addObserver(self, forKeyPath: Utils.Constants.Identifiers.symbolSetKey, options: .New, context: nil)
           }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let symType = defaults.integerForKey(Utils.Constants.Identifiers.symbolSetKey)
        if symType == 0 {
            noteButton!.hidden = false
        } else {
            noteButton!.hidden = true
            noteMode = false
            
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        /*if canDisplayBannerAds {
            let delegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.banner = nil
            canDisplayBannerAds = false
            bannerLayoutComplete = false
            layoutAnimated(false)
        }*/
        
        deactivateInterface()
        if !gameOver {
            if self.navigationController!.viewControllers.indexOf(self) == nil {
                
                // TO-DO: save the puzzle
            }
        }
        
        
    }
    
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let path = keyPath {
            if path == Utils.Constants.Identifiers.symbolSetKey {
                for tile in tiles {
                    tile.refreshLabel()
                }
            } else if path == Utils.Constants.Identifiers.colorTheme {
                print("color path changed")
                if let bgView = self.view as? SSBBackgroundView {
                    print("right kind of view")
                    bgView.drawRect(self.view.bounds)
                }
            }
        }
    }
    
    func tileAtIndex(_index: TileIndex) -> Tile? {
        return board.getBoxAtIndex(_index.Box).getTileAtIndex(_index.Tile)
    }
    
    
    func handleManagedObjectChange(notification: NSNotification) {
        print("handled change to managed object: \(notification)")
    }
    
    
    deinit {
        
        NSUserDefaults.standardUserDefaults().removeObserver(self, forKeyPath: Utils.Constants.Identifiers.symbolSetKey)
        
    }
    
    
    
    func setUpButtons() {
        
        let buttons:[UIView] = [clearButton!, containerView, optionsButton]
        
        for viewItem in buttons {
            let tag = viewItem.tag
            
            originalContentView.addSubview(viewItem)
            
            viewItem.translatesAutoresizingMaskIntoConstraints = false
            
            let pinAttribute: NSLayoutAttribute = tag == 0 ? .Leading : .Trailing
            
            let widthMultiplier: CGFloat = tag == 4 ? 1/8 : 1/4
            
            let bottomPinOffset: CGFloat = tag == 4 ? -40 : -8
            
            let bottomPinRelation: NSLayoutRelation = tag == 4 ? .GreaterThanOrEqual : .Equal
            
            
            // lay out the buttons
            
            
            let bottomPin = NSLayoutConstraint(item: viewItem, attribute: .Bottom, relatedBy: bottomPinRelation, toItem: originalContentView, attribute: .Bottom, multiplier: 1, constant: bottomPinOffset)
            bottomPin.priority = 1000
            
            
            var constraints:[NSLayoutConstraint] = []
            
            if tag != 4 {
                let sidePin =  NSLayoutConstraint(item: viewItem, attribute: pinAttribute, relatedBy: .Equal, toItem: numPad, attribute: pinAttribute, multiplier: 1, constant: 0)
                let height =  NSLayoutConstraint(item: viewItem, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Height, multiplier: 1, constant: 0)
                let width = NSLayoutConstraint(item: viewItem, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: widthMultiplier, constant: 0)
                
                constraints = [width, height, bottomPin, sidePin]
                
            }
            
            if tag == 4 {
                let multiplier = containerSubviews.front == hintButton ? widthMultiplier : widthMultiplier * 2
                
                containerHeight = NSLayoutConstraint(item: viewItem, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: multiplier, constant: 0)
                containerHeight.priority = 999
                containerWidth = NSLayoutConstraint(item: viewItem, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: multiplier, constant: 0)
                containerWidth.priority = 999
                let topPin = NSLayoutConstraint(item: viewItem, attribute: .Top, relatedBy: .GreaterThanOrEqual, toItem: numPad, attribute: .Bottom, multiplier: 1, constant: 8)
                topPin.priority = 1000
                let bottomLimiter = NSLayoutConstraint(item: viewItem, attribute: .Bottom, relatedBy: .LessThanOrEqual, toItem: originalContentView, attribute: .Bottom, multiplier: 1, constant: -5)
                bottomLimiter.priority = 1000
                let centerY = NSLayoutConstraint(item: viewItem, attribute: .CenterY, relatedBy: .Equal, toItem: clearButton, attribute: .Top, multiplier: 1, constant: -15)
                centerY.priority = 500
                let centerX = NSLayoutConstraint(item: viewItem, attribute: .CenterX, relatedBy: .Equal, toItem: numPad, attribute: .CenterX, multiplier: 1, constant: 0)
                constraints = [containerWidth, containerHeight, bottomPin, topPin, bottomLimiter, centerX, centerY]
                
            }
            
            originalContentView.addConstraints(constraints)
            
            originalContentView.addSubview(noteButton!)
            noteButton!.translatesAutoresizingMaskIntoConstraints = false
            
            let nbTop =  NSLayoutConstraint(item: noteButton!, attribute: .Top, relatedBy: .Equal, toItem: numPad, attribute: .Bottom, multiplier: 1, constant: 8)
            let nbRightEdge = NSLayoutConstraint(item: noteButton!, attribute: .Trailing, relatedBy: .Equal, toItem: numPad, attribute: .Trailing, multiplier: 1, constant: 0)
            let nbHeight = NSLayoutConstraint(item: noteButton!, attribute: .Height, relatedBy: .Equal, toItem: numPad, attribute: .Height, multiplier: 1, constant: 0)
            let nbWidth = NSLayoutConstraint(item: noteButton!, attribute: .Width, relatedBy: .Equal, toItem: numPad, attribute: .Width, multiplier: 2/9, constant: 0)
            
            originalContentView.addConstraints([nbTop, nbRightEdge, nbHeight, nbWidth])
            
            
            
            // configure the buttons
            
            if tag != 4 {
                let button = viewItem as! UIButton
                let buttonInfo = buttonInfoForTag(tag)
                
                button.setTitleColor(UIColor.blackColor(), forState: .Normal)
                button.setTitle(buttonInfo.title, forState: .Normal)
                button.addTarget(self, action: Selector(buttonInfo.action), forControlEvents: .TouchUpInside)
                
                let npHeight = self.numPadHeight
                let buttonRadius:CGFloat = tag == 1 || tag == 3 ? npHeight/2 : 5.0
                button.layer.cornerRadius = buttonRadius
                button.layer.borderColor = UIColor.blackColor().CGColor
                button.layer.borderWidth = 3.0
            }
            
        }
        
    }
    
    
    func configureButtons() {
        
        let someButtons = [clearButton!, optionsButton, hintButton, playAgainButton, noteButton!]
        
        for button in someButtons {
            let tag = button.tag
            let buttonInfo = buttonInfoForTag(tag)
            
            let titleColor = tag == 3 ? UIColor.whiteColor() : UIColor.blackColor()
            button.setTitleColor(titleColor, forState: .Normal)
            let bgColor = tag == 3 ? UIColor.blackColor() : UIColor.whiteColor()
            button.backgroundColor = bgColor
            
            if tag == 2 || tag == 0 || tag == 5 {
                button.layer.cornerRadius = 5.0
                button.layer.borderColor = UIColor.blackColor().CGColor
                button.layer.borderWidth = 3.0
            } else {
                button.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            }
            
            
            button.setTitle(buttonInfo.title, forState: .Normal)
            button.addTarget(self, action: Selector(buttonInfo.action), forControlEvents: .TouchUpInside)
            
            
        }
        
        
        playAgainButton.titleLabel?.adjustsFontSizeToFitWidth = false
        playAgainButton.titleLabel?.numberOfLines = 0
        playAgainButton.titleLabel?.textAlignment = .Center
        
        containerView.layer.borderColor = hintButton == containerSubviews.front ? UIColor.blackColor().CGColor : UIColor.whiteColor().CGColor
        
    }
    
    
    private func buttonInfoForTag(tag: Int) -> (title: String, action: String) {
        switch tag {
        case 0:
            return ("Clear", "clearSolution")
        case 1:
            let title =  "?"
            return (title, "showHelpMenu:")
        case 2:
            return ("Settings", "showOptions:")
        case 5:
            return ("Note+", "toggleNoteMode:")
        default:
            return ("Play Again", "playAgain:")
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == UIEventSubtype.MotionShake {
            clearSolution()
        }
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
                    }
                    numPad.refresh()
                }
            }
        } else {
            if let selected = selectedTile {
                if selected.symbolSet != .Standard {
                    return
                }
                let nButton = sender as! UIButton
                let nbBGColor = nButton.backgroundColor
                let nbTextColor = nButton.titleColorForState(.Normal)
                
                nButton.backgroundColor = nbTextColor
                nButton.setTitleColor(nbBGColor, forState: .Normal)
                nButton.layer.borderColor = nbBGColor?.CGColor
                
                noteMode = !noteMode
                numPad.refresh()
            } else {
                return
            }
        }
    }
    
}