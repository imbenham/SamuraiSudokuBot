//
//  SudokuTile.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class Tile: SudokuItem {
    
    var displayValue: TileValue {
        get {
            
            guard let bc = backingCell else {
                return .Nil
            }
            
            if let solutionValue = solutionValue {
                if revealed {
                    return TileValue(rawValue: solutionValue)!
                } else  if let assignedVal = bc.assignedValue {
                    return TileValue(rawValue: Int(assignedVal))!
                }
                return .Nil
            } else {
                return TileValue(rawValue:Int(bc.value.intValue))!
            }
            
        }
    }
    var revealed = false {
        didSet {
            if revealed == true {
                backingCell?.revealed = true
                userInteractionEnabled = false
            } else {
                backingCell?.revealed = false
                userInteractionEnabled = true
            }
            refreshLabel()
        }
    }
    var valueLabel = UILabel()
    var labelColor = UIColor.blackColor()
    let defaultTextColor = UIColor.blackColor()
    let chosenTextColor = UIColor.redColor()
    var selected = false {
        didSet {
            if !selected {
                noteMode = false
            }
            refreshLabel()
        }
    }
    var symbolSet: SymbolSet {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let symType = defaults.integerForKey(symbolSetKey)
            switch symType {
            case 0:
                return .Standard
            case 1:
                return .Critters
            default:
                return .Flags
            }
        }
        
    }
    
    let noteLabels: [TableCell]
    let noteModeColor = UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 0.3)
    var backingCell: BackingCell? {
        didSet {
            refreshLabel()
        }
    }
    let defaultBackgroundColor = UIColor.whiteColor()
    let assignedBackgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0, alpha: 0.3)
    let wrongColor = UIColor(red: 1.0, green: 0.0, blue: 0, alpha: 0.3)
    var selectedColor = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.2)
    let noteBackground = UIView()
    var noteMode = false {
        didSet {
            if noteMode == true {
                if displayValue != .Nil {
                    addNoteValue(displayValue.rawValue)
                }
                self.selected = true
                
            } else {
                if noteValues.count > 0 {
                    setValue(0)
                }
            }
            refreshBackground()
            controller?.refreshNoteButton()
        }
    }
    var noteValues: [Int] {
        get {
            guard let backingCell = backingCell else {
                return []
            }
            return backingCell.notesArray
        }
    }
    
    var tvNoteValues: [TileValue] {
        get {
            return noteValues.map({TileValue(rawValue: $0)!})
        }
    }
    
    var solutionValue: Int? {
        get {
            if backingCell?.puzzleSolution != nil {
                return Int(backingCell!.value)
            }
            
            return nil
        }
    }
    
    override init (index: Int) {
        var labels: [TableCell] = []
        while labels.count < 9 {
            let tc = TableCell()
            tc.label = UILabel()
            tc.label?.textAlignment = .Center
            labels.append(tc)
        }
        noteLabels = labels
        super.init(index: index)
        
    }
    
    convenience init (index: Int, withParent parent: UIView) {
        self.init(index: index)
        self.parentSquare = parent
        // let tileIndex: TileIndex = (parent.index, self.index)
        let cells = cellsFromTiles([self])
        self.backingCell = BackingCell(cell:cells[0])
    }
    
    
    required init(coder aDecoder: NSCoder) {
        var labels: [TableCell] = []
        while labels.count < 9 {
            let tc = TableCell()
            tc.label = UILabel()
            tc.label?.textAlignment = .Center
            labels.append(tc)
        }
        noteLabels = labels
        super.init(coder: aDecoder)
    }
    
    
    
    override func layoutSubviews() {
        self.addSubview(valueLabel)
        valueLabel.frame = self.bounds
        valueLabel.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        valueLabel.textAlignment = .Center
        valueLabel.font = UIFont.boldSystemFontOfSize(UIFont.labelFontSize()+2)
        
        noteBackground.frame = self.bounds
        addSubview(noteBackground)
        noteBackground.backgroundColor = UIColor.clearColor()
        for label in noteLabels {
            label.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            label.backgroundColor = UIColor.clearColor()
            noteBackground.addSubview(label)
        }
        layoutNoteViews()
        
        refreshLabel()
    }
    
    
    func getValueText()->String {
        return self.displayValue != .Nil ? symbolSet.getSymbolForTyleValue(displayValue) : ""
    }
    
    func setValue(value: Int) {
        if displayValue != .Nil {
            backingCell?.notesArray = []
        }
        backingCell?.assignedValue = value
        refreshLabel()
        
    }
    
    func refreshLabel() {
        if backingCell!.revealed.boolValue {
            valueLabel.textColor = chosenTextColor
            userInteractionEnabled = false
        } else {
            valueLabel.textColor = labelColor
            userInteractionEnabled = true
        }
        
        valueLabel.text = noteMode ? "" : self.getValueText()
        refreshBackground()
        configureNoteViews()
    }
    
    func refreshBackground() {
        if noteMode {
            if selected {
                self.backgroundColor = noteModeColor
                for lv in noteLabels {
                    lv.layer.borderWidth = 0.25
                }
                return
            }
        }
        
        if displayValue != .Nil && solutionValue != nil {
            backgroundColor = selected ? selectedColor : assignedBackgroundColor
        } else if revealed {
            backgroundColor = defaultBackgroundColor
        } else {
            backgroundColor = selected ? selectedColor : defaultBackgroundColor
        }
        
        for lv in noteLabels {
            lv.layer.borderWidth = 0.0
        }
    }
    
    func removeNoteValue(value: Int) {
        var newNotes = backingCell!.notesArray
        let index = newNotes.indexOf(value)!
        newNotes.removeAtIndex(index)
        backingCell!.notesArray = newNotes
        configureNoteViews()
    }
    
    func addNoteValue(value: Int) {
        var newNotes = backingCell!.notesArray
        newNotes.append(value)
        backingCell!.notesArray = newNotes
        configureNoteViews()
    }
    
    func layoutNoteViews() {
        
        for index in 0...8 {
            let noteLabel = noteLabels[index]
            var rect = self.noteBackground.bounds
            rect.size.width *= 1/3
            rect.size.height *= 1/3
            
            if index > 2 {
                if index < 6 {
                    rect.origin.y = noteLabels[0].frame.size.height
                } else {
                    rect.origin.y = noteLabels[0].frame.size.height*2
                }
            }
            
            if index == 1 || index == 4 || index == 7 {
                rect.origin.x = noteLabels[0].frame.size.width
            } else if index == 2 || index == 5 || index == 8 {
                rect.origin.x = noteLabels[0].frame.size.width*2
            }
            
            noteLabel.frame = rect
            
            noteLabel.layer.borderColor = selectedColor.CGColor
            let fontHeight = noteLabel.frame.size.height * 9/10
            noteLabel.label?.font = UIFont(name: "futura", size: fontHeight)
            noteLabel.label?.textColor = UIColor.darkGrayColor()
            
        }
    }
    
    func configureNoteViews() {
        let numNotes = noteValues.count
        for index in 0...noteLabels.count-1 {
            let noteLabel = noteLabels[index]
            if symbolSet != .Standard {
                noteLabel.label?.text = ""
            } else {
                noteLabel.label?.text = index < numNotes ? symbolSet.getSymbolForTyleValue(tvNoteValues[index]) : ""
            }
            
        }
    }
}

extension Tile {
    // add game-logic related methods
    
    var tileIndex: TileIndex {
        get {
            guard let pSquare = parentSquare as? Box else {
                return (0,index)
            }
            return (pSquare.index, index)
        }
        
    }
    
    
    
    func indexString() -> String {
        let box = tileIndex.Box
        let tile = tileIndex.Tile
        return "This tile's index is: \(box).\(tile) "
    }
    
    func getColumnIndex() -> Int {
        switch self.tileIndex.Box{
        case 0,3,6:
            switch self.tileIndex.Tile{
            case 0,3,6:
                return 1
            case 1,4,7:
                return 2
            default:
                return 3
            }
        case 1,4,7:
            switch self.tileIndex.Tile{
            case 0,3,6:
                return 4
            case 1,4,7:
                return 5
            default:
                return 6
            }
        default:
            switch self.tileIndex.Tile {
            case 0,3,6:
                return 7
            case 1,4,7:
                return 8
            default:
                return 9
            }
        }
    }
    
    
    func getRowIndex() -> Int {
        switch self.tileIndex.Box{
        case 0,1,2:
            switch self.tileIndex.Tile{
            case 0,1,2:
                return 1
            case 3,4,5:
                return 2
            default:
                return 3
            }
        case 3,4,5:
            switch self.tileIndex.Tile{
            case 0,1,2:
                return 4
            case 3,4,5:
                return 5
            default:
                return 6
            }
        default:
            switch self.tileIndex.Tile {
            case 0,1,2:
                return 7
            case 3,4,5:
                return 8
            default:
                return 9
            }
        }
    }
    
}