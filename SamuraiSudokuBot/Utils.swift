//
//  Utils.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


struct Utils {
    
    //static let ButtonConfigs = ButtonConfig()
    
    struct TextConfigs {
        
        
        static func getAttributedTitle(text: String, withColor color: UIColor) -> NSAttributedString {
            let size: CGFloat = 18.0
            let font = UIFont(name: "Futura", size: size)!
            
            let attribs = [NSFontAttributeName:font, NSForegroundColorAttributeName:color]
            
            return NSAttributedString(string:text, attributes: attribs)
        }
        
        static func getAttributedBodyText(text: String) -> NSAttributedString {
            let size = UIFont.systemFontSize()
            let font = UIFont(name: "Futura", size: size)!
            
            let attribs = [NSFontAttributeName:font, NSForegroundColorAttributeName:Utils.Palette.getTheme()]
            
            return NSAttributedString(string:text, attributes: attribs)
        }
        
        
    }
    
    struct TileConfigs {
        
        static func backgroundImageForSize(size: CGSize, color: UIColor =  UIColor.lightGrayColor()) -> UIImage {
            let fillRect = CGRect(origin: CGPoint(x: 0,y: 0), size: size)
            
            UIGraphicsBeginImageContextWithOptions(fillRect.size, true, 0.0)
            
            guard let context = UIGraphicsGetCurrentContext() else {
                return UIImage.init()
            }
            
            func drawRadialInRect(context: CGContextRef, rect: CGRect) {
                let locations: [CGFloat] = [0.0, 1.0]
                let colorSpace =  CGColorSpaceCreateDeviceRGB()
                
                let outerGradientColor = color.CGColor
                let innerGradientColor = UIColor.whiteColor().CGColor
                
                let colors = [innerGradientColor, outerGradientColor]
                
                let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
                
                
                let startPoint = CGPoint(x: CGRectGetMidX(rect), y: CGRectGetMidY(rect))
                let endPoint = startPoint
                
                let startRadius:CGFloat = 0
                let endRadius = rect.size.width * 2
                
                CGContextDrawRadialGradient(context, gradient, startPoint,
                                            startRadius, endPoint, endRadius, CGGradientDrawingOptions(rawValue: 1))
            }
            
            drawRadialInRect(context, rect: fillRect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
            
        }

    }

    struct ButtonConfigs {
        
        var selectedColor = Utils.Palette.getTheme()
        var baseColor = UIColor.blackColor()
        
        func backgroundImageForSize(size: CGSize, selected: Bool) -> UIImage {
            let rect = CGRect(origin: CGPoint(x: 0,y: 0), size: size)
            let fillRect = CGRectInset(rect, 1, 1)
            UIGraphicsBeginImageContextWithOptions(fillRect.size, true, 0.0)
            
            guard let context = UIGraphicsGetCurrentContext() else {
                return UIImage.init()
            }
            
            func drawRadialInRect(context: CGContextRef, rect: CGRect) {
                let locations: [CGFloat] = [0.0, 1.0]
                let colorSpace =  CGColorSpaceCreateDeviceRGB()
                
                let outerGradientColor = selected ? selectedColor : baseColor
                let innerGradientColor = selected ? Utils.Palette.getThemeInnerGradient().CGColor : UIColor.whiteColor().CGColor
                
                let colors = [innerGradientColor, outerGradientColor.CGColor]
                
                let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
                
                
                let startPoint = CGPoint(x: rect.origin.x + rect.size.width/4, y: rect.origin.y + rect.size.height/4)
                let endPoint = CGPoint(x: rect.origin.x + rect.size.width/2 , y: rect.origin.y + rect.size.height/2)
                
                let startRadius:CGFloat = 0
                let endRadius = rect.size.width/2
                
                CGContextDrawRadialGradient(context, gradient, startPoint,
                                            startRadius, endPoint, endRadius, CGGradientDrawingOptions(rawValue: 1))
            }
            
            drawRadialInRect(context, rect: fillRect)
            
            baseColor.setStroke()
            CGContextStrokeEllipseInRect(context, fillRect)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return image
            
        }
    
        
        func getAttributedTitle(title: String) -> NSAttributedString {
            let size: CGFloat = 20.0
            let font = UIFont(name: "Futura", size: size)!
            let attribs = [NSFontAttributeName:font, NSStrokeColorAttributeName:selectedColor, NSStrokeWidthAttributeName: 3.0, NSForegroundColorAttributeName:baseColor, NSTextEffectAttributeName: NSTextEffectLetterpressStyle]
            return NSAttributedString(string: title, attributes: attribs)
        }
        
        
    }
    
    struct Palette {
        static func getTheme() -> UIColor {
            let defaults = NSUserDefaults.standardUserDefaults()
            let raw = defaults.integerForKey(Identifiers.colorTheme)
            
            let col = ColorPalette(rawValue: raw)!
            return col.color
        }
        
        static func getSelectedIndex() -> Int {
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.integerForKey(Identifiers.colorTheme)
        }
        
        static func getColorForRaw(raw:Int) -> UIColor {
            let rawVal = raw < 4 ? raw : 0
            
            return ColorPalette(rawValue: rawVal)!.color
        }
        
        static func getThemeInnerGradient() -> UIColor {
            let defaults = NSUserDefaults.standardUserDefaults()
            let raw = defaults.integerForKey(Identifiers.colorTheme)
            
            let col = ColorPalette(rawValue: raw)!
            
            return col.getInnerGradientColor()
        }
        enum ColorPalette: Int {
            case Green = 0
            case Orange = 1
            case Blue = 2
            case Yellow = 3
            
            var color: UIColor {
                switch self {
                case .Green:
                    return UIColor(red: 51/255, green: 204/255, blue: 51/255, alpha: 1)
                case .Orange:
                    return  UIColor(red: 1, green: 184/255, blue: 8/255, alpha: 1)
                case .Blue:
                    return  UIColor(red: 69/255, green: 208/255, blue: 1, alpha: 1)
                case .Yellow:
                    return  UIColor(red: 1, green: 1, blue: 0, alpha: 1)
                    
                }
            }
            
            func getInnerGradientColor() -> UIColor {
                switch self {
                case .Green:
                    return UIColor(red: 159/255, green: 1, blue: 0, alpha: 1)
                case .Orange:
                    return UIColor(red: 1, green: 230, blue: 145, alpha: 1)
                case .Blue:
                    return UIColor(red: 159/255, green: 1, blue: 1, alpha: 1)
                case .Yellow:
                    return UIColor(red: 1, green: 1, blue: 161/255, alpha: 1)
                
                }
            }

            
        }
        
    }
    
    struct Identifiers {
        static let colorTheme = "theme"
        static let symbolSetKey = "symbolSet"
        static let soundKey = "sound"
        
        static let coreDataModuleName = "SamuraiSudokuBot"
        
        static let easyPuzzleKey = "Easy"
        static let mediumPuzzleKey = "Medium"
        static let hardPuzzleKey = "Hard"
        static let insanePuzzleKey = "Insane"
        static let customPuzzleKey = "Custom"
    }

    
    struct Sounds {
        
       enum SoundType {
            case SelectedTileChanged
            case ValueSelected
            case PuzzleCompleted
            case PuzzleFetched
            case HintGiven
            case GiveUp
            case UndoRedo
            case StartOver
            case DiscardPuzzle
    
        
            
            var url: NSURL {
                get{
                    let bundle = NSBundle.mainBundle()
                    var path: String

                    switch self {
                    case .SelectedTileChanged:
                        path = bundle.pathForResource("tile_change", ofType: "caf")!
                    case .ValueSelected:
                        path = bundle.pathForResource("value_chosen", ofType: "caf")!
                    case .PuzzleCompleted:
                        path = bundle.pathForResource("puzzle_solved1", ofType: "caf")!
                    case .HintGiven:
                        path = bundle.pathForResource("hint_given", ofType: "caf")!
                    case .PuzzleFetched:
                        path = bundle.pathForResource("puzzle_fetched", ofType: "caf")!
                    case .GiveUp:
                        path = bundle.pathForResource("give_up", ofType: "caf")!
                    case .UndoRedo:
                        path = bundle.pathForResource("undo_redo", ofType: "caf")!
                    case .DiscardPuzzle:
                        path = bundle.pathForResource("discard_puzzle", ofType: "caf")!
                    case .StartOver:
                        path = bundle.pathForResource("start_over", ofType: "caf")!
                    }
                    
                 
                    return NSURL.fileURLWithPath(path)
                  
                }
            }
            
            
        }
    }
   
}

// row/column -> TileIndex ((Box: 0-8, Tile: 0-8))
func getBox(column: Int, row: Int) -> Int {
    switch column {
    case 1, 2, 3:
        switch row {
        case 1,2,3:
            return 1
        case 4,5,6:
            return 4
        default:
            return 7
        }
    case 4,5,6:
        switch row {
        case 1,2,3:
            return 2
        case 4,5,6:
            return 5
        default:
            return 8
        }
    default:
        switch row {
        case 1,2,3:
            return 3
        case 4,5,6:
            return 6
        default:
            return 9
        }
    }
}

func getTileIndex(row: Int, column: Int) -> TileIndex {
    let box = getBox(column, row: row)
    switch row {
    case 1,4,7:
        switch column {
        case 1,4,7:
            return (box, 0)
        case 2,5,8:
            return (box, 1)
        default:
            return (box, 2)
        }
    case 2,5,8:
        switch column {
        case 1,4,7:
            return (box, 3)
        case 2,5,8:
            return (box, 4)
        default:
            return (box, 5)
        }
    default:
        switch column {
        case 1,4,7:
            return (box, 6)
        case 2,5,8:
            return (box, 7)
        default:
            return (box, 8)
        }
    }
}


// Nodes <-> Cells

func cellsFromConstraints(constraints: [LinkedNode<PuzzleKey>]) -> [PuzzleCell] {
    var puzzleNodes: [PuzzleKey] = []
    for node in constraints {
        if node.key != nil {
            puzzleNodes.append(node.key!)
        }
    }
    var cells: [PuzzleCell] = []
    for node in puzzleNodes {
        let cell = node.cell!
        cells.append(cell)
    }
    return cells
}

func cellNodeDictFromNodes(nodes: [LinkedNode<PuzzleKey>]) -> [PuzzleCell: LinkedNode<PuzzleKey>]{
    var dict: [PuzzleCell: LinkedNode<PuzzleKey>] = [:]
    for node in nodes {
        let cell = node.key!.cell!
        dict[cell] = node
    }
    return dict
}

/*
func tileForConstraint(node: PuzzleKey, tiles:[Tile]) -> Tile? {
    if let cRow = node.cell?.row {
        if let cCol = node.cell?.column {
            for t in tiles {
                if t.getColumnIndex() == cCol && t.getRowIndex() == cRow {
                    return t
                }
            }
        }
    }
    return nil
}


func translateCellsToConstraintList(cells:[PuzzleCell])->[PuzzleKey] {
    var matrixRowArray = [PuzzleKey]()
    for cell in cells {
        let mRow:PuzzleKey = PuzzleKey(cell: cell)
        matrixRowArray.append(mRow)
    }
    return matrixRowArray
}

//tiles -> cells
func cellsFromTiles(tiles:[Tile]) -> [PuzzleCell] {
    var cells: [PuzzleCell] = []
    for tile in tiles {
        let val = tile.displayValue.rawValue
        let row = tile.getRowIndex()
        let column = tile.getColumnIndex()
        let pCell = PuzzleCell(row: row, column: column, value: val)
        cells.append(pCell)
    }
    
    return cells
}
*/
// other utils

var GlobalMainQueue: dispatch_queue_t {
    return dispatch_get_main_queue()
}

/*var GlobalUserInteractiveQueue: dispatch_queue_t {
 return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
 }
 
 var GlobalUserInitiatedQueue: dispatch_queue_t {
 return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
 }
 
 var GlobalUtilityQueue: dispatch_queue_t {
 return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
 }*/

var GlobalBackgroundQueue: dispatch_queue_t {
    return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
}

let concurrentPuzzleQueue = dispatch_queue_create(
    "com.isaacbenham.SudokuCheat.puzzleQueue", DISPATCH_QUEUE_CONCURRENT)

/*let concurrentPuzzleQueue1 = dispatch_queue_create(
 "com.isaacbenham.SudokuCheat.puzzleQueue1", DISPATCH_QUEUE_CONCURRENT)
 let concurrentPuzzleQueue2 = dispatch_queue_create(
 "com.isaacbenham.SudokuCheat.puzzleQueue2", DISPATCH_QUEUE_CONCURRENT)
 let concurrentPuzzleQueue3 = dispatch_queue_create(
 "com.isaacbenham.SudokuCheat.puzzleQueue3", DISPATCH_QUEUE_CONCURRENT)
 let concurrentPuzzleQueue4 = dispatch_queue_create(
 "com.isaacbenham.SudokuCheat.puzzleQueue4", DISPATCH_QUEUE_CONCURRENT)
 let concurrentPuzzleQueue5 = dispatch_queue_create(
 "com.isaacbenham.SudokuCheat.puzzleQueue5", DISPATCH_QUEUE_CONCURRENT)*/

//let concurrentBackupQueue = dispatch_queue_create("com.isaacbenham.SudokuCheat.backupQueue", DISPATCH_QUEUE_CONCURRENT)

extension UIButton {
    convenience init(tag: Int) {
        self.init()
        self.tag = tag
    }
}

extension UIView {
    convenience init(tag: Int) {
        self.init()
        self.tag = tag
    }
}

// user default constants



let currentHardPuzzleKey = "currentHardPuzzle"
let currentEasyPuzzleKey = "currentEasyPuzzle"
let currentMediumPuzzleKey = "currentMediumPuzzle"
let currentInsanePuzzleKey = "currentInsanePuzzle"
let currentPuzzleKey = "currentPuzzle"

let cachedNotification = "puzzleCached"

let easyCacheFilePath = (NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as NSURL).URLByAppendingPathComponent("easy/puzzle_cache.plist")

let mediumCacheFilePath = (NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as NSURL).URLByAppendingPathComponent("medium/puzzle_cache.plist")

let hardCacheFilePath = (NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as NSURL).URLByAppendingPathComponent("hard/puzzle_cache.plist")

let insaneCacheFilePath = (NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)[0] as NSURL).URLByAppendingPathComponent("insane/puzzle_cache.plist")

enum SymbolSet {
    case Standard, Critters, Flags
    
    
    func getSymbolForTyleValue(value: TileValue) -> String {
        switch self {
        case Standard:
            return String(value.rawValue)
        case Critters:
            let dict:[Int:String] = [1:"🐥", 2:"🙈", 3:"🐼", 4:"🐰", 5:"🐷", 6:"🐘", 7:"🐢", 8:"🐙", 9:"🐌"]
            return dict[value.rawValue]!
        case Flags:
            let dict = [1:"🇨🇭", 2:"🇿🇦", 3:"🇨🇱", 4:"🇨🇦", 5:"🇯🇵", 6:"🇹🇷", 7:"🇫🇮", 8:"🇰🇷", 9:"🇲🇽"]
            return dict[value.rawValue]!
        }
    }
    
    func getSymbolForValue(value: Int) -> String {
        switch self {
        case Standard:
            return String(value)
        case Critters:
            let dict:[Int:String] = [1:"🐥", 2:"🙈", 3:"🐼", 4:"🐰", 5:"🐷", 6:"🐘", 7:"🐢", 8:"🐙", 9:"🐌"]
            return dict[value]!
        case Flags:
            let dict = [1:"🇨🇭", 2:"🇸🇪", 3:"🇨🇱", 4:"🇨🇦", 5:"🇯🇵", 6:"🇹🇷", 7:"🇫🇮", 8:"🇰🇷", 9:"🇲🇽"]
            return dict[value]!
        }
    }
}

extension TileValue {
    func getSymbolForTyleValueforSet(symSet: SymbolSet) -> String {
        switch symSet {
        case .Standard:
            return String(self.rawValue)
        case .Critters:
            let dict:[Int:String] = [1:"🐥", 2:"🙈", 3:"🐼", 4:"🐰", 5:"🐷", 6:"🐘", 7:"🐢", 8:"🐙", 9:"🐌"]
            return dict[self.rawValue]!
        case .Flags:
            let dict = [1:"🇨🇭", 2:"🇿🇦", 3:"🇨🇱", 4:"🇨🇦", 5:"🇯🇵", 6:"🇹🇷", 7:"🇫🇮", 8:"🇰🇷", 9:"🇲🇽"]
            return dict[self.rawValue]!
        }
    }
    
}

//let cachableDifficulties: [PuzzleDifficulty] = [.Easy, .Medium, .Hard, .Insane]
extension UIView {
    
    func removeConstraints() {
        if let superView = self.superview {
            self.removeFromSuperview()
            superView.addSubview(self)
        }
    }
    
    
    
}


/*

extension UIViewController {
    func sections() -> Int {
        return 0
    }
    
    func rowsForSection(section: Int) -> Int {
        return 3
    }
}*/
