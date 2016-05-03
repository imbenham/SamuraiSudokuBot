//
//  SudokuBox.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

import UIKit

class Box: SudokuItem, Nester{
    
    typealias T = Tile
    
    var boxes: [Tile] = []
    
    override var controller: SudokuControllerDelegate? {
        get {
            return parentSquare?.controller
        }
        set {
            parentSquare?.controller = newValue
            didSetController()
        }
    
    }
    
    override init(index: Int) {
        super.init(index:index)
        if boxes.count == 0 {
            for ind in 0...8 {
                let aBox = Tile(index: ind, withParent: self)
                boxes.append(aBox)
            }
        }
    }
    
    convenience init (index withIndex: Int, withParent parent: SudokuBoard){
        self.init(index: withIndex)
        self.parentSquare = parent
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for index in 0...8 {
            let aBox = Tile(index: index)
            boxes.append(aBox)
        }
    }
    
   /* override func layoutSubviews() {
        
        self.prepareBoxes()
    }*/
    
    
    override func didSetController() {
        print("did set ctrller called")
        if let ctrl = controller as? SudokuController {
            for box in boxes {
                let tapRecognizer = UITapGestureRecognizer(target: ctrl, action: #selector(SudokuController.tileTapped(_:)))
                box.addGestureRecognizer(tapRecognizer)
                if let controller = controller as? BasicSudokuController {
                    let longPressRecognizer = UILongPressGestureRecognizer(target: controller, action: #selector(BasicSudokuController.toggleNoteMode(_:)))
                    tapRecognizer.requireGestureRecognizerToFail(longPressRecognizer)
                    box.addGestureRecognizer(longPressRecognizer)
                }
                
                
            }
            
        }
    }
    
    func makeRow(row: Int)-> [Tile] {
        switch row {
        case 1:
            return [boxes[0], boxes[1], boxes[2]]
        case 2:
            return [boxes[3], boxes[4], boxes[5]]
        default:
            return [boxes[6], boxes[7], boxes[8]]
        }
    }
    
    
    func makeColumn(column: Int) -> [Tile]{
        switch column {
        case 1:
            return [boxes[0], boxes[3], boxes[6]]
        case 2:
            return [boxes[1], boxes[4], boxes[7]]
        default:
            return [boxes[2], boxes[5], boxes[8]]
        }
    }
    
    func prepareBoxes() {
        
        for box in boxes {
            self.addSubview(box)
            box.userInteractionEnabled = true
            box.layer.borderColor = UIColor.lightGrayColor().CGColor
            box.layer.borderWidth = 1
            box.translatesAutoresizingMaskIntoConstraints = false
            
            if let ctrl = controller as? SudokuController {
                for box in boxes {
                    let tapRecognizer = UITapGestureRecognizer(target: ctrl, action: #selector(SudokuController.tileTapped(_:)))
                    box.addGestureRecognizer(tapRecognizer)
                    if let controller = controller as? BasicSudokuController {
                        let longPressRecognizer = UILongPressGestureRecognizer(target: controller, action: #selector(BasicSudokuController.toggleNoteMode(_:)))
                        tapRecognizer.requireGestureRecognizerToFail(longPressRecognizer)
                        box.addGestureRecognizer(longPressRecognizer)
                    }
                    
                    
                }
                
            }

        }
        
        let constraints:[NSLayoutConstraint] = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
        
        
        if let parent = self.parentSquare as? SudokuBoard {
            parent.tilesReady()
        }
        
        
    }
    
}

extension Box {
    // add game-logic related methods
    
    func getTileAtIndex(index: Int) -> Tile {
        return boxes[index]
    }
    
    
    func getNilTiles() -> [Tile] {
        var nilTiles = [Tile]()
        for box in boxes {
            let tile = box
            if tile.displayValue == TileValue.Nil {
                nilTiles.append(tile)
            }
        }
        return nilTiles
    }
}

