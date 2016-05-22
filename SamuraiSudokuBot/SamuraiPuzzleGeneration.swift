//
//  SamuraiPuzzleGeneration.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

// this file is for initial set up of the matrix


// this file is for initial set up of the matrix

class SamuraiMatrix: Matrix {
    
    // Constructing matrix
    //static let sharedInstance = SamuraiMatrix()
    override func constructMatrix() {
        
        
        let opQueue = NSOperationQueue()
        let op1 = NSBlockOperation(block: self.buildRowChoices)
        let op2 = NSBlockOperation(block: self.buildConstraintColumns)
        let op3 = NSBlockOperation(block: self.buildOutMatrix)
        op3.addDependency(op1)
        op3.addDependency(op2)
        opQueue.qualityOfService = .UserInitiated
        opQueue.addOperations([op1, op2, op3], waitUntilFinished: true)
        
        
        // matrix.enumerateRows()
        //matrix.enumerateColumns()
    }
    
    private func buildConstraintColumns() {
        
        let helperQueue2 = dispatch_queue_create(
            "com.isaacbenham.SudokuCheat.helperQueue2", DISPATCH_QUEUE_CONCURRENT)
        
        var components: [SudokuMatrix<PuzzleKey>] = []
        
        
        var operations:[NSOperation] = []
        let opQueue = NSOperationQueue()
        opQueue.qualityOfService = .UserInitiated
        
        for board in 0...4 {
            let helperMatrix = SudokuMatrix<PuzzleKey>()
            helperMatrix.latOrderOffset = 324 * board
            
            
            let operation = NSBlockOperation() {
                for columnIndex in 1...9 {
                    for rowIndex in 1...9 {
                        let header = ColumnHeader(row: rowIndex, column: columnIndex, boardIndex:board)
                        let node = PuzzleKey(header: header)
                        helperMatrix.addLateralLink(node)
                        
                    }
                }
                
                
                for aValue in 1...9 {
                    for columnIndex in 1...9 {
                        let header = ColumnHeader(value: aValue, column: columnIndex, boardIndex:board)
                        let node = PuzzleKey(header: header)
                        helperMatrix.addLateralLink(node)
                    }
                }
                
                for aValue in 1...9 {
                    for rowIndex in 1...9 {
                        let header = ColumnHeader(value: aValue, row: rowIndex, boardIndex:board)
                        let node = PuzzleKey(header: header)
                        helperMatrix.addLateralLink(node)
                        
                    }
                }
                
                for aValue in 1...9 {
                    for boxIndex in 1...9 {
                        let header = ColumnHeader(value: aValue, box: boxIndex, boardIndex:board)
                        let node = PuzzleKey(header: header)
                        helperMatrix.addLateralLink(node)
                    }
                }
                
                
                dispatch_barrier_sync(helperQueue2) {
                    
                    components.append(helperMatrix)
                    
                    if components.count == 5 {
                        
                        let comps = components.sort({$0.latOrderOffset < $1.latOrderOffset})
                        for (index, item) in comps.enumerate() {
                            if index < comps.count - 1 {
                                item.lateralHead.latJump = comps[index + 1].lateralHead
                            }
                            
                            self.matrix +- item
                        }
                        
                    }
                    
                }
                
            }
            
            operations.append(operation)
            
            if operations.count == 5 {
                opQueue.addOperations(operations, waitUntilFinished: true)
            }
            
        }
        
        
    }
    
    
    
    private func buildRowChoices() {
        
        var operations: [NSBlockOperation] = []
        var components:[SudokuMatrix<PuzzleKey>] = []
        let helperQueue = dispatch_queue_create(
            "com.isaacbenham.SudokuCheat.helperQueue", DISPATCH_QUEUE_CONCURRENT)
        
        
        
        let opQueue = NSOperationQueue()
        opQueue.qualityOfService = .UserInitiated
        
        var companionDict: [Int: LinkedNode<PuzzleKey>] = [:]
        
        
        func addNode(row: Int, column:Int, value: Int, board:Int, matrix:SudokuMatrix<PuzzleKey>) {
            let cell = PuzzleCell(row: row, column: column, value: value, boardIndex: board)
            let node = PuzzleKey(cell: cell)
            
            let callback = { (node: LinkedNode<PuzzleKey>) -> () in
                let cell = node.key!.cell!
                if let companion = cell.companionCell {
                    let hash = cell.boardIndex == 0 ? cell.hashValue : companion.hashValue
                    dispatch_barrier_sync(helperQueue){
                        if let patientFriend = companionDict[hash] {
                            patientFriend.companion = node
                            node.companion = patientFriend
                        } else {
                            companionDict[hash] = node
                        }
                        
                    }
                }
                
            }
            
            matrix.addVerticalLink(node, callback: callback)
        }
        
        for board in 0...4 {
            let newMatrix = SudokuMatrix<PuzzleKey>()
            newMatrix.vertOrderOffset = 729 * board
            let operation = NSBlockOperation() {
                for rowIndex in 1...9 {
                    for columnIndex in 1...9 {
                        for aValue in 1...9 {
                            addNode(rowIndex, column: columnIndex, value: aValue, board: board, matrix: newMatrix)
                        }
                    }
                }
                
                dispatch_barrier_sync(helperQueue){
                    
                    components.append(newMatrix)
                    
                    
                    if components.count == 5 {
                        let comps = components.sort({$0.vertOrderOffset < $1.vertOrderOffset})
                        for (index, item) in comps.enumerate(){
                            if index < comps.count - 1 {
                                item.verticalHead.vertJump = comps[index + 1].verticalHead
                            }
                            
                            self.matrix +| item
                        }
                        
                    }
                    
                }
                
            }
            
            operation.queuePriority = .High
            operations.append(operation)
            
            if operations.count == 5 {
                opQueue.addOperations(operations, waitUntilFinished: true)
            }
            
            
        }
        
    }
    
    
    private func buildOutMatrix() {
        
        var currentRow:LinkedNode<PuzzleKey>? = matrix.verticalHead
        var jumpPoints:[LinkedNode<PuzzleKey>] = []
        
        while currentRow != nil {
            jumpPoints.append(currentRow!)
            currentRow = currentRow!.vertJump
        }
        
        
        let opQueue = NSOperationQueue()
        opQueue.qualityOfService = .UserInitiated
        
        var operations: [NSOperation]  = []
        
        
        for (index, jump) in jumpPoints.enumerate() {
            let operation = NSBlockOperation() {
                var currentRow = jump
                while currentRow.key!.cell!.boardIndex == index {
                    self.connectMatchingConstraintsForRow(currentRow)
                    currentRow = currentRow.down!
                }
                
            }
            
            operations.append(operation)
            
        }
        
        
        opQueue.addOperations(operations, waitUntilFinished: true)
        
    }
    
    private func connectMatchingConstraintsForRow(row: LinkedNode<PuzzleKey>) {
        
        
        
        let board = row.key!.cell!.boardIndex
        var header:LinkedNode<PuzzleKey> = {
            
            var header = matrix.lateralHead
            
            while header.key!.header!.boardIndex != board {
                header = header.latJump!
            }
            
            
            return header
        }()
        
        
        repeat {
            if header.key == row.key {
                let newNode = LinkedNode(key: row.key!)
                self.matrix.addLateralLinkFromNode(row.left!, toNewNode: newNode)
                self.matrix.addVerticalLinkFromNode(header.up!, toNewNode: newNode)
                newNode.down = header
                newNode.right = row
            }
            header = header.right!
        } while header.key!.header!.boardIndex == board
    }
    
    
    
    // handy debugging function
    func printCompanions() -> Int {
        var current = matrix.verticalHead
        
        var count = 0
        
        repeat {
            if let comp = current.companion {
                print(comp.key!.cell!.companionHash!)
                count += 1
            } else {
                print("--")
            }
            current = current.down!
        } while current.vertOrder != 0
        
        print(count)
        
        return count
    }
    
    
    // puzzle algorithm
    
    override internal func findNextRowChoice()->(Node: LinkedNode<PuzzleKey>, Root:Int)? {
        
        if currentSolution.count == 0 {
            return nil
        }
        
        let lastChoice:Choice = currentSolution.removeLast()
        reinsertLast(lastChoice)
        //print(reinsertCount)
        
        let lcDown = lastChoice.Chosen.down!.vertOrder != 0 ? lastChoice.Chosen.down! : lastChoice.Chosen.down!.down!
        
        if lcDown.vertOrder == lastChoice.Root {
            return findNextRowChoice()
        }
        
        return (lcDown, lastChoice.Root)
    }
    
    
    
    override internal func removeRowFromMatrix(row: LinkedNode<PuzzleKey>) {
        
        
        func remove(current: LinkedNode<PuzzleKey>) {
            var current = current.getLateralHead().right!
            
            while current.latOrder != 0 {
                let col = current.getVerticalHead()  // go to the top of the column
                coverColumn(col)                     // "cover" the column
                current = current.right!
            }
            
        }
        
        
        if let comp = companionChoice(row) {
            remove(row)
            remove(comp)
        } else {
            remove(row)
        }
        
    }
    
    override internal func reinsertLast(last: Choice) {
        
        let current = last.Chosen
        func reinsert(current: LinkedNode<PuzzleKey>) {
            var current = current.getLateralTail() // start at last node and work back to the head reconnecting each node with its column
            
            while current.latOrder != 0 {
                uncoverColumn(current)
                current = current.left!
            }
        }
        
        
        
        if let first = companionChoice(current) {
            reinsert(first)
        }
        
        reinsert(current)
        
        
    }
    
    
    override internal func selectRowToSolve() -> LinkedNode<PuzzleKey>? {
        
        var currentColumn:LinkedNode<PuzzleKey> = matrix.lateralHead.left!
        var minColumns: [LinkedNode<PuzzleKey>] = []
        var minRows = currentColumn.countColumn()
        let last = currentColumn.key
        
        func repeatClosure() -> Bool {
            let count = currentColumn.countColumn()
            if count == 1 { // if we have a one-row column, we have an unsatisfiable constraint and therefore an invalid puzzle
                return false
            } else if count < minRows {
                minRows = count
                minColumns = [currentColumn]
            } else if count == minRows {
                minColumns.append(currentColumn)
                
            }
            currentColumn = currentColumn.right!
            return true
            
        }
        
        if matrix.lateralHead.key!.header!.boardIndex == 0 {
            repeat {
                if !repeatClosure() {
                    return nil
                }
            } while currentColumn.key!.header!.boardIndex == 0
        } else {
            repeat {
                if !repeatClosure() {
                    return nil
                }
            }  while currentColumn.key != last
            
        }
        
        func rowRandomizer() -> LinkedNode<PuzzleKey> {
            let random1 = Int(arc4random_uniform((UInt32(minColumns.count))))
            currentColumn = minColumns[random1]
            
            let random2 = Int(arc4random_uniform(UInt32(minRows-1)))+1
            var count = 0
            
            while count != random2 {
                currentColumn = currentColumn.down!
                count+=1
            }
            
            return currentColumn
            
        }
        
        return rowRandomizer()
        
    }
}
