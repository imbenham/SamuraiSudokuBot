//
//  KeyObjects.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation
import CoreData

struct ColumnHeader {
    let row:Int
    let column:Int
    let value:Int
    let box:Int
    let boardIndex: Int
    
    init(value:Int = 0, column:Int = 0, row:Int = 0, box:Int = 0, boardIndex:Int = 0) {
        
        self.value = value
        self.column = column
        self.box = box
        self.row = row
        self.boardIndex = boardIndex
    }
    
    var companion: ColumnHeader? {
        switch boardIndex {
        case 0:
            if row < 4 && column < 4 {
                return ColumnHeader(value: value, column: column + 6, row: row + 6, boardIndex: 1)
            } else if row < 4 && column > 6 {
                return ColumnHeader(value: value, column: column - 6 , row: row + 6,  boardIndex: 2)
            } else if row > 6 && column > 6 {
                return ColumnHeader(value: value, column: column - 6, row: row - 6,  boardIndex: 3)
            } else if row > 6 && column < 4 {
                return ColumnHeader(value: value, column: column + 6, row: row - 6,  boardIndex: 4)
            }
            return nil
            
        case 1:
            if row > 6 && column > 6 {
                return ColumnHeader(value: value, column: column - 6, row: row - 6,  boardIndex: 0)
            }
            return nil
        case 2:
            if row > 6 && column < 4 {
                return ColumnHeader(value: value, column: column + 6, row: row - 6,  boardIndex: 0)
            }
            return nil
        case 3:
            if row < 4 && column < 4 {
                return ColumnHeader(value: value, column: column + 6 , row: row + 6, boardIndex: 0)
            }
            return nil
        case 4:
            if row < 4 && column > 6 {
                return ColumnHeader(value: value, column: column - 6, row: row + 6, boardIndex: 0)
            }
            return nil
        default:
            return nil
        }
    }
    
    var hash: String? {
        get {
            if let companion = companion {
                if companion.boardIndex == 0 {
                    return  String(value)+String(column)+String(row)+String(box)+String(boardIndex)
                }
                
                return String(companion.value)+String(companion.column)+String(companion.row)+String(companion.box)+String(companion.boardIndex)
            }
            return nil
        }
    }
    
}

func == (lhs: ColumnHeader, rhs: ColumnHeader) -> Bool {
    if lhs.boardIndex != rhs.boardIndex {
        return false
    }
    
    if lhs.row != rhs.row {
        return false
    }
    
    
    if lhs.column != rhs.column {
        return false
    }
    
    if  lhs.value != rhs.value {
        return false
    }
    
    if lhs.box != rhs.box {
        return false
    }
    
    return true
}

extension ColumnHeader: Equatable{}

func == (lhs: ColumnHeader, rhs: PuzzleCell) -> Bool {
    
    guard lhs.boardIndex == rhs.boardIndex else {
        return false
    }
    
    var rhs = rhs
    
    if lhs.row > 0 && lhs.row != rhs.row {
        return false
    }
    
    if lhs.column > 0 && lhs.column != rhs.column {
        return false
    }
    
    if lhs.value > 0 && lhs.value != rhs.value {
        return false
    }
    
    if lhs.box > 0 && lhs.box != rhs.box {
        return false
    }
    
    return true
    
}
func == (lhs: PuzzleCell, rhs: ColumnHeader) -> Bool {
    return rhs == lhs
}


struct PuzzleCell: Hashable {
    
   static func getColumnIndexFromTileIndex(tileIndex: TileIndex) -> Int {
        switch tileIndex.Box{
        case 1,4,7:
            switch tileIndex.Tile{
            case 1,4,7:
                return 1
            case 2,5,8:
                return 2
            default:
                return 3
            }
        case 2,5,8:
            switch tileIndex.Tile{
            case 1,4,7:
                return 4
            case 2,5,8:
                return 5
            default:
                return 6
            }
        default:
            switch tileIndex.Tile {
            case 1,4,7:
                return 7
            case 2,5,8:
                return 8
            default:
                return 9
            }
        }
    }
    
    
    static func getRowIndexFromTileIndex(tileIndex: TileIndex) -> Int {
        switch tileIndex.Box{
        case 1,2,3:
            switch tileIndex.Tile{
            case 1,2,3:
                return 1
            case 4,5,6:
                return 2
            default:
                return 3
            }
        case 4,5,6:
            switch tileIndex.Tile{
            case 1,2,3:
                return 4
            case 4,5,6:
                return 5
            default:
                return 6
            }
        default:
            switch tileIndex.Tile {
            case 1,2,3:
                return 7
            case 4,5,6:
                return 8
            default:
                return 9
            }
        }
    }

    
    
    let row: Int
    let column: Int
    var value: Int
    let boardIndex: Int
    
    var companionCell: PuzzleCell? {
        get {
            
            if let tup = mapToMiddle() {
                return PuzzleCell(row: tup.row, column: tup.column, value: value, boardIndex: 0)
            }
            
            if let tup = mapOutward() {
                return PuzzleCell(row: tup.row, column: tup.column, value: value, boardIndex: tup.board)
            }
            
            return nil
        }
        
        
    }
    
    lazy var box: Int = {
        switch self.column {
        case 1, 2, 3:
            switch self.row {
            case 1,2,3:
                return 1
            case 4,5,6:
                return 4
            default:
                return 7
            }
        case 4,5,6:
            switch self.row {
            case 1,2,3:
                return 2
            case 4,5,6:
                return 5
            default:
                return 8
            }
        default:
            switch self.row {
            case 1,2,3:
                return 3
            case 4,5,6:
                return 6
            default:
                return 9
            }
        }
    }()
    
    
    
    init(row: Int, column:Int, value:Int = 0, boardIndex:Int = 0) {
        
        self.row = row
        self.column = column
        self.value = value
        self.boardIndex = boardIndex
    }
    
    init(tileIndex: TileIndex, value:Int, boardIndex:Int) {
        let row = PuzzleCell.getRowIndexFromTileIndex(tileIndex)
        let column = PuzzleCell.getColumnIndexFromTileIndex(tileIndex)
        
        self.init(row: row, column: column, value: value, boardIndex: boardIndex)
    }
    
    
    init(cell:PuzzleCell) {
        self.row = cell.row
        self.column = cell.column
        self.value = cell.value
        self.boardIndex = cell.boardIndex
    }
    
    
    // hashable conformance
    
    var hashValue: Int {
        
        return Int("\(boardIndex)\(row)\(column)\(value)")!
        
    }
    
    var companionHash: String? {
        if let companion = companionCell {
            if companion.boardIndex == 0 {
                return String(companion.row) + String(companion.column) + String(companion.value)
            }
            
            return String(row) + String(column) + String(value)
        }
        
        return nil
    }
    
    
    // conversion to managed backing cells
    
    func toBackingCell() -> BackingCell {
        
        return BackingCell(cell: self)
        
    }
    
    func mapToMiddle()->(row:Int, column:Int)? {
        switch boardIndex {
        case 1:
            if row > 6 && column > 6 {
                return (row - 6, column - 6)
            } else {
                return nil
            }
        case 2:
            if row > 6 && column < 4 {
                return (row - 6, column + 6)
            } else {
                return nil
            }
        case 3:
            if row < 4 && column < 4 {
                return (row + 6, column + 6)
            } else {
                return nil
            }
        case 4:
            if row < 4 && column > 6 {
                return (row + 6, column - 6)
            } else {
                return nil
            }
        default: return nil
        }
        
    }
    
    func mapOutward() -> (board:Int, row:Int, column:Int)? {
        
        guard boardIndex == 0 else {
            return nil
        }
        
        if row < 4 && column < 4 {
            return (1, row + 6, column + 6)
        } else if row < 4 && column > 6 {
            return (2, row + 6, column - 6)
        } else if row > 6 &&  column > 6 {
            return (3, row - 6, column - 6)
        } else if row > 6 && column < 4 {
            return (4, row - 6, column + 6)
        } else {
            return nil
        }
    }
    
}



func == (lhs: PuzzleCell, rhs: PuzzleCell) -> Bool {
    return lhs.hashValue == rhs.hashValue
}



extension PuzzleCell: Equatable {}
