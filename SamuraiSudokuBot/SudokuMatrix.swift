//
//  SudokuMatrix.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

class Matrix {
    
    var matrix = SudokuMatrix<PuzzleKey>()
    typealias Choice = (Chosen: LinkedNode<PuzzleKey>, Root:Int)
    internal var currentSolution = [Choice]()
    internal var eliminated = [Choice]()
    typealias Solution = [LinkedNode<PuzzleKey>]
    internal var solutions = [Solution]()
    internal var solutionDict: [PuzzleCell: LinkedNode<PuzzleKey>]?
    var rawDifficultyForPuzzle:Int {
        get {
            return PuzzleStore.sharedInstance.difficulty.rawDifficultyThreshold
        }
    }
    var isSolved: Bool {
        get {
            
            return matrix.lateralHead.key == nil
        }
    }
    
    
    init() {
        constructMatrix()
    }
    
    
    func rebuild() {
        
        while currentSolution.count != 0 {
            let lastChoice:Choice = currentSolution.removeLast()
            reinsertLast(lastChoice)
        }
        while eliminated.count != 0 {
            let lastChoice:Choice = eliminated.removeLast()
            reinsertLast(lastChoice)
        }
        
        
        solutions = []
    }
    
    
    
    func resetSolution() {
        while currentSolution.count != 0 {
            let lastChoice:Choice = currentSolution.removeLast()
            reinsertLast(lastChoice)
        }
        solutions = []
    }
    
    
    
    // Constructing matrix
    func constructMatrix() {
        
        buildRowChoices()
        
        buildCellConstraints()
        buildColumnConstraints()
        buildRowConstraints()
        buildBoxConstraints()
        
        buildOutMatrix()
        
        
        
    }
    
    private func buildCellConstraints(){
        
        for columnIndex in 1...9 {
            for rowIndex in 1...9 {
                let header = ColumnHeader(row: rowIndex, column: columnIndex)
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
        
        
    }
    
    private func buildColumnConstraints(){
        
        for aValue in 1...9 {
            for columnIndex in 1...9 {
                let header = ColumnHeader(value: aValue, column: columnIndex)
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
    }
    
    private func buildRowConstraints() {
        
        for aValue in 1...9 {
            for rowIndex in 1...9 {
                let header = ColumnHeader(value: aValue, row: rowIndex)
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
    }
    
    private func buildBoxConstraints() {
        
        for aValue in 1...9 {
            for boxIndex in 1...9 {
                let header = ColumnHeader(value: aValue, box: boxIndex)
                let node = PuzzleKey(header: header)
                matrix.addLateralLink(node)
            }
        }
    }
    
    private func buildRowChoices() {
        
        for rowIndex in 1...9 {
            for columnIndex in 1...9 {
                for aValue in 1...9 {
                    let cell = PuzzleCell(row: rowIndex, column: columnIndex, value: aValue)
                    let node = PuzzleKey(cell: cell)
                    matrix.addVerticalLink(node)
                }
            }
        }
        
    }
    
    private func buildOutMatrix() {
        
        let vertHead = matrix.verticalHead
        
        var currentRow:LinkedNode<PuzzleKey> = vertHead
        
        repeat {
            
            connectMatchingConstraintsForRow(currentRow)
            currentRow = currentRow.down!
        } while currentRow.key != vertHead.key
        
        
    }
    
    private func connectMatchingConstraintsForRow(row: LinkedNode<PuzzleKey>) {
        let latHead = matrix.lateralHead
        
        var currentHeader = latHead
        
        func addNodeBlock (header: LinkedNode<PuzzleKey>) {
            if header.key == row.key {
                let newNode = LinkedNode(key: row.key!)
                self.matrix.addLateralLinkFromNode(row.getLateralTail(), toNewNode: newNode)
                self.matrix.addVerticalLinkFromNode(header.getVerticalTail(), toNewNode: newNode)
                newNode.down = header
                newNode.right = row
            }
        }
        
        repeat {
            addNodeBlock(currentHeader)
            currentHeader = currentHeader.right!
        } while currentHeader.key! != latHead.key
        
        
    }
    
    
    // matches given values against row choices -- move this to linked list class def?
    
    func findRowMatch(mRow: PuzzleKey) -> LinkedNode<PuzzleKey> {
        
        
        var current = matrix.verticalHead.up!
        
        while current.vertOrder != matrix.verticalHead.vertOrder {
            if current.key! == mRow {
                return current
            }
            current = current.up!
        }
        return current
    }
    
    func findRowMatchForCell(cell: PuzzleCell) -> LinkedNode<PuzzleKey> {
        var current = matrix.verticalHead.up!
        
        while current.vertOrder != matrix.verticalHead.vertOrder {
            if current.key!.cell == cell {
                return current
            }
            current = current.up!
        }
        return current
    }
    
    
    
    // puzzle generation
    
    func generatePuzzle() {
        var puzz: [PuzzleCell] = []
        
        let initialChoice = self.selectRowToSolve()!
        var solutionFound = false
        
        while !solutionFound {
            solutionFound = self.findFirstSolution(initialChoice, root: initialChoice.vertOrder)
        }
        
        let sol = self.solutions[0]
        
        puzz = cellsFromConstraints(sol, filter: true)
        
        solutionDict = cellNodeDictFromNodes(sol, filter: true)
        
        // get a list of minimal givens that need to be left in the grid for a valid puzzle and a list of all the values that are taken out
        let filtered = packagePuzzle(puzz)
        
        puzz = filtered.Givens
        
        let puzzSolution:[PuzzleCell] = filtered.Solution
        
        PuzzleStore.sharedInstance.puzzleReady(puzz, solution: puzzSolution, rawScore: filtered.Score)
        
        
        self.rebuild()
        
        
    }
    
    
    
    func validatePuzzle(puzzle: [PuzzleCell]) -> Bool{
        
        let rowList: [LinkedNode<PuzzleKey>] = puzzle.map({solutionDict![$0]!})
        
        eliminateRows(rowList);
        
        let valid = countPuzzleSolutions() == 1;
        
        rebuild()
        
        return valid
    }
    
    func scorePuzzle(puzzle: [PuzzleCell]) -> Int {
        
        
        let rowList: [LinkedNode<PuzzleKey>] = puzzle.map({solutionDict![$0]!})
        
        return eliminateRows(rowList);
        
    }
    
    internal func packagePuzzle(puzzle: [PuzzleCell]) -> (Givens:[PuzzleCell], Solution:[PuzzleCell], Score:Int) {
        
        func validate(puzzle: [PuzzleCell]) -> ([PuzzleCell], [PuzzleCell]) {
            var solution = puzzle
           
            var givens:[PuzzleCell] = []
            
            while !validatePuzzle(givens) {
                givens += solution.removeRandom()
            }
            return (givens, solution)
        }
        
        func calibrate(puzzle: (givens: [PuzzleCell], solution: [PuzzleCell])) -> (Givens: [PuzzleCell], Solution: [PuzzleCell], Score:Int) {
            
            var givens = puzzle.givens
            var solution = puzzle.solution
            let target = rawDifficultyForPuzzle
            var score = scorePuzzle(givens)
            
            
            while score > target {  // target > solution
                if givens.count == 0 {
                    switch PuzzleStore.sharedInstance.difficulty {
                    case .Hard:
                        givens += solution.removeRandom(99)
                    case .Medium:
                        givens += solution.removeRandom(122)
                    case .Easy:
                        givens += solution.removeRandom(137)
                    default:
                        givens += solution.removeRandom(89)
                    }
                } else {
                    let delta = score - target
                    switch delta {
                    case 1000...3000:
                        givens += solution.removeRandom(70)
                    case 500...999:
                        givens += solution.removeRandom(25)
                    case 199...499:
                        givens += solution.removeRandom(12)
                    case 119...198:
                        givens += solution.removeRandom(5)
                    default:
                        givens += solution.removeRandom()
                        
                    }
                }
                
                
                score = scorePuzzle(givens)
            }
            
            return (givens, solution, score)
        }
        
        return calibrate(validate(puzzle))
    }
    
    
    // function for "cheat mode" -- checks that there is only one solution given list of given cells and returns solution for the puzzle
    internal func solutionForValidPuzzle(puzzle: [PuzzleCell]) -> [PuzzleCell]? {
        defer {
            rebuild()
        }
        
        // helper function to translate the given list of puzzle cells into matrix rows
        
        func getRowsFromCells(cells: [PuzzleCell]) -> [LinkedNode<PuzzleKey>] {
            
            var rowsToSolve = [LinkedNode<PuzzleKey>]()
            
            for cell in cells {
                let solvedRow = findRowMatchForCell(cell)
                rowsToSolve.append(solvedRow)
            }
            
            return rowsToSolve
        }
        
        let givens = getRowsFromCells(puzzle)
        eliminateRows(givens)
        if countPuzzleSolutions() != 1 {
            return nil
        }
        let nodes = solutions[0]
        return cellsFromConstraints(nodes)
    }
    
    
    
    
    internal func countPuzzleSolutions() -> Int {
        
        if isSolved {
            return 1
        }
        
        if let bestColumn = selectRowToSolve() {
            return allSolutionsForPuzzle(bestColumn, andRoot:bestColumn.vertOrder)
        }
        
        return 0
    }
    
    
    internal func addSolution() {
        var solution: [LinkedNode<PuzzleKey>] = []
        
        for choice in currentSolution {
            solution.append(choice.Chosen.getLateralHead())
        }
        
        solutions.append(solution)
    }
    
    
    internal func allSolutionsForPuzzle(rowChoice:LinkedNode<PuzzleKey>, andCount count:Int = 0, withCutOff cutOff:Int = 2, andRoot root:Int = 1) -> Int {
        
        if count == cutOff {
            return cutOff
        }
        
        solveForRow(rowChoice, root: root)
        
        
        if isSolved {
            addSolution()
            
            if let next = findNextRowChoice() {
                return allSolutionsForPuzzle(next.Node, andCount: count+1, withCutOff: cutOff, andRoot: next.Root)
            } else {
                return count+1
            }
        } else {
            if let next = selectRowToSolve() {
                return allSolutionsForPuzzle(next, andCount: count, withCutOff: cutOff, andRoot:next.vertOrder)
            } else {
                if let next = findNextRowChoice() {
                    return allSolutionsForPuzzle(next.Node, andCount: count, withCutOff: cutOff, andRoot: next.Root)
                } else {
                    return count
                }
            }
        }
    }
    
    
    internal func findFirstSolution(rowChoice:LinkedNode<PuzzleKey>, root: Int) -> Bool {
        
        solveForRow(rowChoice, root: root)
        /*let next = selectRowToSolve()!
         solveForRow(next, root: next.vertOrder)
         
         let another = findNextRowChoice()
         let andAnother = findNextRowChoice()
         
         matrix.enumerateRows()
         matrix.enumerateColumns()*/
        
        if isSolved {
            addSolution()
            return true
        } else {
            if let next = selectRowToSolve() {
                return findFirstSolution(next, root: next.vertOrder)
            } else {
                if let next = findNextRowChoice() {
                    return findFirstSolution(next.Node, root: next.Root)
                } else {
                    return false
                }
            }
        }
    }
    
    internal func findNextRowChoice()->(Node: LinkedNode<PuzzleKey>, Root:Int)? {
        
        if currentSolution.count == 0 {
            return nil
        }
        
        let lastChoice:Choice = self.currentSolution.removeLast()
        reinsertLast(lastChoice)
        
        let lcDown = lastChoice.Chosen.down!.vertOrder != 0 ? lastChoice.Chosen.down! : lastChoice.Chosen.down!.down!
        
        if lcDown.vertOrder == lastChoice.Root {
            return findNextRowChoice()
        }
        
        return (lcDown, lastChoice.Root)
    }
    
    
    internal func reinsertLast(last: Choice) {
        
        var current = last.Chosen.getLateralTail() // start at last node and work back to the head reconnecting each node with its column
        
        while current.latOrder != 0 {
            uncoverColumn(current)
            current = current.left!
        }
        
    }
    
    
    
    internal func selectRowToSolve() -> LinkedNode<PuzzleKey>? {
        
        var currentColumn:LinkedNode<PuzzleKey> = matrix.lateralHead.left!
        var minColumns: [LinkedNode<PuzzleKey>] = []
        var minRows = currentColumn.countColumn()
        let last = currentColumn.key
        
        
        repeat {
            let count = currentColumn.countColumn()
            if count == 1 { // if we have a one-row column, we have an unsatisfiable constraint and therefore an invalid puzzle
                return nil
            } else if count < minRows {
                minRows = count
                minColumns = [currentColumn]
            } else if count == minRows {
                minColumns.append(currentColumn)
            }
            currentColumn = currentColumn.right!
        }  while currentColumn.key != last
        
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
    
    
    
    
    internal func solveForRow(row: LinkedNode<PuzzleKey>, root: Int = 1){
        
        removeRowFromMatrix(row)
        currentSolution.append((row, root))
        
    }
    
    internal func eliminateRows(rows: [LinkedNode<PuzzleKey>]) -> Int {
        for row in rows {
            eliminateRow(row, root: row.vertOrder)
        }
        
        return matrix.verticalCount()
    }
    
    
    internal func eliminateRow(row: LinkedNode<PuzzleKey>, root: Int = 1){
        removeRowFromMatrix(row)
        eliminated.append((row, root))
    }
    
    
    internal func removeRowFromMatrix(row: LinkedNode<PuzzleKey>) {
        
        var current = row.getLateralHead().right!
        while current.latOrder != 0 {
            let col = current.getVerticalHead()  // go to the top of the column
            coverColumn(col)                     // "cover" the column
            current = current.right!
        }
        
    }
    
    
    internal func coverColumn(column: LinkedNode<PuzzleKey>)  {
        
        var current = column.down!
        while current.vertOrder != 0 {      // start at top of column and remove each row until we get to the column head
            removeRow(current)
            current = current.down!
        }
        
        matrix.removeLateralLink(column)  // unlink the column head so it doesn't get read during row selection
        
    }
    
    
    internal func uncoverColumn(column: LinkedNode<PuzzleKey>) {
        var current = column.getVerticalTail()
        
        repeat {  // we start at the bottom of the column and insert each row until we get back to the top
            insertRow(current)
            current = current.up!
        } while current.vertOrder != 0
        
        matrix.insertLateralLink(current) // we reinsert the column head laterally
        
    }
    
    
    internal func removeRow(row: LinkedNode<PuzzleKey>) {
        let skip = row.latOrder  // skip the column we're choosing on
        var current = row.getLateralHead() // start at leftmost node and remove each from left to right
        
        repeat {
            if current.latOrder == skip {
                current = current.right!
                continue
            }
            matrix.removeVerticalLink(current)
            current = current.right!
        } while current.latOrder !=  0
        
        
    }
    
    internal func insertRow(row: LinkedNode<PuzzleKey>) {
        
        let skip = row.latOrder
        var current = row.getLateralTail()
        
        repeat {                                // start at the last node and go backwards reconnecting nodes with their columns
            if current.latOrder == skip {
                current = current.left!
                continue
            }
            matrix.insertVerticalLink(current)
            current = current.left!
            
        } while current.latOrder != 4
        
    }
    
    
    // data translation
    
    // Nodes <-> Cells
    
    func cellsFromConstraints(constraints: [LinkedNode<PuzzleKey>], filter: Bool = false) -> [PuzzleCell] {
        var puzzleKeys: [PuzzleKey] = []
        for node in constraints {
            if node.key != nil {
                puzzleKeys.append(node.key!)
            }
        }
        
        
        // helper function to strip out board-0 cells with companions and replace with their non-0 companions
        func getCell(key: PuzzleKey) -> PuzzleCell {
            guard let comp = key.cell!.companionCell else {
                return key.cell!
            }
            
            if comp.boardIndex == 0 {
                return key.cell!
            }
            
            return comp
        }
        
        var cells: [PuzzleCell] = []
        for key in puzzleKeys {
            let cell = filter ? getCell(key) : key.cell!
            cells.append(cell)
        }
        return cells
    }
    
    func cellNodeDictFromNodes(nodes: [LinkedNode<PuzzleKey>], filter:Bool = false) -> [PuzzleCell: LinkedNode<PuzzleKey>]{
        var dict: [PuzzleCell: LinkedNode<PuzzleKey>] = [:]
        
        // helper function to strip out board-0 cells with companions and replace with their non-0 companions
        func getCell(key: PuzzleKey) -> PuzzleCell {
            guard let comp = key.cell!.companionCell else {
                return key.cell!
            }
            
            if comp.boardIndex == 0 {
                return key.cell!
            }
            
            return comp
        }
        
        for node in nodes {
            let cell = filter ? getCell(node.key!) : node.key!.cell!
            dict[cell] = node
        }
        return dict
    }
    
}
