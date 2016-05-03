//
//  SudokuBoard.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class SudokuBoard: SudokuItem, Nester {
    
    typealias T = Box
    
    var boxes: [Box] = []
    
    var readyCount = 0
    
    var ready: Bool {
        return readyCount == 9
    }
    
    override var controller: SudokuControllerDelegate? {
        didSet {
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        for index in 0...8 {
            let aBox = Box(index: index, withParent: self)
            boxes.append(aBox)
        }
    
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for index in 0...8 {
            let aBox = Box(index: index, withParent: self)
            boxes.append(aBox)
        }
    
    }
    
   /* override func layoutSubviews() {
        
    }*/
    
    
    func makeRow(row: Int)-> [Box] {
        switch row {
        case 1:
            return [boxes[0], boxes[1], boxes[2]]
        case 2:
            return [boxes[3], boxes[4], boxes[5]]
        default:
            return [boxes[6], boxes[7], boxes[8]]
        }
    }
    
    func makeColumn(column: Int) -> [Box]{
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
        print("preparing boxes")
        for box in boxes {
            
            self.addSubview(box)
            
            box.userInteractionEnabled = true
            box.translatesAutoresizingMaskIntoConstraints = false
            
            box.layer.borderColor = UIColor.blackColor().CGColor
            box.layer.borderWidth = 1.0
            
            box.prepareBoxes()
        }
        
        let constraints = BoxSetter().configureConstraintsForParentSquare(self)
        self.addConstraints(constraints)
        
    }
    
    
    
    func tilesReady() {
        readyCount += 1
        print("tiles ready")
        print("\(controller)")
        
        if ready {
            if let cntrlr = self.controller {
                cntrlr.boardReady()
            }

        }
    }
    
}

extension SudokuBoard {
    
    func getBoxAtIndex(index: Int) -> Box {
        let boxOfBoxes = self.boxes
        return boxOfBoxes[index-1]
    }
    
    func loadPuzzleWithIndexValues(valueList: [PuzzleCell]){
        if valueList.count != 81 {
            return
        }
        
        for cell in valueList {
            let index = getTileIndex(cell.row, column: cell.column)
            self.tileAtIndex(index).setValue(cell.value)
        }
        
        
    }
    
    func loadPuzzleWithNonNilIndexValues(valueList: [PuzzleCell]) {
        if valueList.count > 81 {
            return
        }
    }
    
    func tileAtIndex(_index: TileIndex) -> Tile {
        return self.getBoxAtIndex(_index.Box).getTileAtIndex(_index.Tile)
    }
    
    
    func getNilTiles() -> [Tile] {
        var nilTiles = [Tile]()
        for item in boxes {
            let box = item
            nilTiles += box.getNilTiles()
        }
        return nilTiles
    }
    
}
