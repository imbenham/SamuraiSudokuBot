//
//  LinkedList_and_Nodes.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

protocol LaterallyLinkable {
    associatedtype T:Equatable
    var latOrderOffset: Int {get set}
    var lateralHead: LinkedNode<T> {get set}
    func addLateralLink(key: T)
}

extension LaterallyLinkable {
    func addLateralLink(key: T) {
        
        if lateralHead.key == nil {
            lateralHead.key = key
            lateralHead.left = lateralHead
            lateralHead.right = lateralHead
            lateralHead.up = lateralHead
            lateralHead.down = lateralHead
            lateralHead.latOrder += latOrderOffset
            return
        }
        
        let current = lateralHead.left!
        
        
        let newLink = LinkedNode<T>()
        newLink.key = key
        newLink.left = current
        newLink.right = current.right
        newLink.up = newLink
        newLink.down = newLink
        
        newLink.right!.left = newLink
        current.right = newLink
        
        newLink.latOrder = current.latOrder+1
        
        
    }
}

protocol VerticallyLinkable {
    associatedtype T: Equatable
    var verticalHead: LinkedNode<T> {get set}
    var vertOrderOffset: Int {get set}
    func addVerticalLink(key: T, callback: (LinkedNode<T> -> ())?)
}

extension VerticallyLinkable {
    
    func addVerticalLink(key: T, callback: (LinkedNode<T> -> ())? = nil) {
        if verticalHead.key == nil {
            verticalHead.key = key
            verticalHead.down = verticalHead
            verticalHead.up = verticalHead
            verticalHead.left = verticalHead
            verticalHead.right = verticalHead
            verticalHead.vertOrder += vertOrderOffset
            
            if let callback = callback {
                callback(verticalHead)
            }
            return
        }
        
        let current = verticalHead.up!
        
        let newLink = LinkedNode<T>()
        newLink.key = key
        newLink.up = current
        newLink.down = current.down
        newLink.left = newLink
        newLink.right = newLink
        
        self.verticalHead.up = newLink
        current.down = newLink
        
        newLink.vertOrder = current.vertOrder+1
        
        if let callback = callback {
            callback(newLink)
        }
        
    }
    
}

protocol TwoDimensionallyLinkable: LaterallyLinkable, VerticallyLinkable {
    associatedtype T: Equatable
    
    func addLateralLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>)
    func addVerticalLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>)
    
}

extension TwoDimensionallyLinkable {
    
    func addLateralLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>) {
        newNode.latOrder = node.latOrder+1
        newNode.right = node.right
        newNode.left = node
        node.right!.left = newNode
        node.right = newNode
    }
    
    func addVerticalLinkFromNode(node: LinkedNode<T>, toNewNode newNode: LinkedNode<T>) {
        newNode.vertOrder = node.vertOrder+1
        newNode.down = node.down
        newNode.up = node
        node.down!.up = newNode
        node.down = newNode
    }
    
    
}


class SudokuMatrix<T:Equatable where T:Hashable>: LaterallyLinkable, VerticallyLinkable, TwoDimensionallyLinkable {
    
    var lateralHead = LinkedNode<T>()
    var verticalHead = LinkedNode<T>()
    var vertOrderOffset: Int = 0
    var latOrderOffset: Int = 0
    
    lazy var rows: [Int : LinkedNode<T>] = {
        var rowDict:[Int : LinkedNode<T>] = [:]
        
        var current:LinkedNode<T>? = self.verticalHead
        if let hash = current?.key?.hashValue {
            rowDict[hash] = current!
        }
        current = current?.down
        while current != nil {
            if current!.key == self.verticalHead.key {
                break
            }
            if let hash = current?.key?.hashValue {
                rowDict[hash] = current!
            }
            current = current!.down
        }
        return rowDict
        
    }()
    
    
    func verticalCount() -> Int {
        var current:LinkedNode<T>? = verticalHead.down
        var count = 1
        WhileLoop: while current != nil {
            if current!.key == verticalHead.key {
                break WhileLoop
            }
            count+=1
            current = current!.down
        }
        return count
    }
    
    
    func lateralCount() -> Int {
        var current:LinkedNode<T>? = lateralHead.right
        var count = 1
        WhileLoop: while current != nil {
            if current!.key == lateralHead.key {
                break WhileLoop
            }
            count+=1
            current = current!.right
        }
        return count
    }
    
    func removeLateralLink(link: LinkedNode<T>) {
        
        if link.left?.latOrder == link.latOrder {
            lateralHead = LinkedNode<T>()
        } else {
            link.left?.right = link.right
            link.right?.left = link.left
            if link.latOrder == lateralHead.latOrder && link.vertOrder == 0 {
                if let newHead = link.right {
                    lateralHead = newHead
                }
            }
            
        }
    }
    
    func removeVerticalLink(link: LinkedNode<T>) {
        
        if link.up?.vertOrder == link.vertOrder {
            verticalHead = LinkedNode<T>()
        } else {
            link.up?.down = link.down
            link.down?.up = link.up
            
            if link.vertOrder == verticalHead.vertOrder && link.latOrder == 0 {
                if let newHead = link.down {
                    verticalHead = newHead
                }
            }
            
        }
    }
    
    
    func insertLateralLink(link: LinkedNode<T>) {
        if lateralHead.key == nil {
            if link.vertOrder == 0 {
                lateralHead = link
                return
            }
            
        }
        
        link.left?.right = link
        link.right?.left = link
        if link.latOrder <= lateralHead.latOrder && link.vertOrder == 0 {
            lateralHead = link
        }
        
    }
    
    func insertVerticalLink(link: LinkedNode<T>) {
        
        if verticalHead.key == nil {
            if link.latOrder == 0 {
                verticalHead = link
                return
            }
            
        }
        link.up?.down = link
        link.down?.up = link
        if link.vertOrder <= verticalHead.vertOrder && link.latOrder == 0 {
            verticalHead = link
        }
        
    }
    
    func printRows() {
        var current = verticalHead
        let last = verticalHead.up!.vertOrder
        
        while current.vertOrder != last {
            let key = current.key!
            print("\(current.vertOrder): \(key)")
            
            current = current.down!
        }
        
        print("\(last): \(current.key!)")
    }
    
    func printColumns() {
        var current = lateralHead
        let last = current.left!.latOrder
        
        while current.latOrder != last {
            let key = current.key!
            print("\(current.latOrder): \(key)")
            
            current = current.right!
        }
        
        print("\(last): \(current.key!)")
    }
    
    func enumerateRows() {
        
        var current = verticalHead
        var count = 0
        
        
        while (current.vertOrder != verticalHead.vertOrder || count < 1) {
            if current.vertOrder == lateralHead.vertOrder {
                count += 1
            }
            
            var countString = " "
            current = current.right!
            while current.latOrder != 0 {
                countString += "-\(current.latOrder)"
                current = current.right!
            }
            
            let numRow = current.vertOrder
            
            print("\(numRow)" + countString)
            
            if countString == " " {
                print(current.key)
            }
            
            current = current.down!
        }
        
        
    }
    
    func enumerateColumns() {
        
        var current = lateralHead
        var count = 0
        
        while (current.latOrder != lateralHead.latOrder || count < 1) {
            if current.latOrder == lateralHead.latOrder {
                count += 1
            }
            var countString = " "
            
            current = current.down!
            while current.vertOrder != 0 {
                countString += "-\(current.vertOrder)"
                current = current.down!
            }
            let numCol = current.latOrder
            print("\(numCol)" + countString)
            
            if countString == " " {
                print(current.key)
            }
            
            current = current.right!
        }
    }
    
    func countAllColumns() {
        var total = 0
        var current = lateralHead
        
        repeat {
            print("column: \(current.latOrder) has \(countColumn(current)) nodes")
            current = current.right!
            total += 1
        } while current.latOrder != 0
        
        print("total:\(total)")
    }
    
    func countColumn(node: LinkedNode<T>) -> Int {
        
        var current = node.down!
        var count = 1
        
        while current.vertOrder != node.vertOrder {
            count += 1
            current = current.down!
        }
        
        return count
    }
    
    func countAllRows() {
        
        var current = verticalHead
        var total = 0
        
        repeat {
            print("row: \(current.vertOrder) has \(countRow(current)) nodes")
            current = current.down!
            total += 1
        } while current.vertOrder != 0
        print("total:\(total)")
    }
    
    func countRow(node: LinkedNode<T>) -> Int {
        var current = node.right!
        var count = 1
        
        while current.latOrder != node.latOrder {
            count += 1
            current = current.right!
        }
        
        return count
    }
    
    
}


func == (lhs:PuzzleKey, rhs:PuzzleKey) -> Bool {
    
    guard lhs.header == nil || rhs.header == nil else {
        return lhs.header! == rhs.header!
    }
    
    guard lhs.cell == nil || rhs.cell == nil else {
        return lhs.cell! == rhs.cell!
    }
    
    if let header = lhs.header {
        
        return header == rhs.cell!
    }
    
    return lhs.cell! == rhs.header!
    
}


class LinkedNode<T> {
    var key: T? = nil
    
    var left: LinkedNode<T>?
    var right: LinkedNode<T>?
    var up: LinkedNode<T>?
    var down: LinkedNode<T>?
    
    var latJump: LinkedNode<T>?
    var vertJump: LinkedNode<T>?
    
    var latOrder: Int = 0
    var vertOrder: Int = 0
    
    var companion: LinkedNode<T>? = nil
}




extension LinkedNode  {
    
    convenience init(key: T) {
        self.init()
        self.key = key
    }
    
    
    func countColumn() -> Int {
        let start = self.vertOrder
        var count = 1
        var current = self.down
        while current != nil {
            if current!.vertOrder == start {
                break
            }
            count+=1
            current = current!.down
        }
        return count
    }
    
    
    func getVerticalHead() -> LinkedNode<T> {
        var current:LinkedNode<T> = self
        
        while current.up != nil {
            if current.vertOrder == 0 {
                break
            }
            current = current.up!
        }
        
        return current
    }
    
    func getLateralHead() -> LinkedNode<T> {
        var current = self
        while current.left != nil {
            if current.latOrder == 0 {
                break
            }
            current = current.left!
        }
        return current
    }
    
    func getVerticalTail() -> LinkedNode<T> {
        var current = self
        while current.down != nil {
            if current.down!.vertOrder == 0 {
                break
            }
            current = current.down!
        }
        return current
    }
    
    func getLateralTail() -> LinkedNode<T> {
        var current:LinkedNode<T> = self
        while current.right != nil {
            if current.right!.latOrder == 0 {
                break
            }
            current = current.right!
        }
        return current
    }
    
}

infix operator +| {associativity left precedence 160}
infix operator +- {associativity left precedence 160}

// merge matrices vertically

func +| <T:Equatable where T: Hashable>(lhs: SudokuMatrix<T>, rhs: SudokuMatrix<T>) {
    
    if rhs.verticalHead.key == nil {
        
        return
    }
    
    if lhs.verticalHead.key == nil {
        
        lhs.verticalHead = rhs.verticalHead
        
    }
    
    if let tail1 = lhs.verticalHead.up, tail2 = rhs.verticalHead.up {
        tail1.down = rhs.verticalHead
        rhs.verticalHead.up = tail1
        tail2.down = lhs.verticalHead
        lhs.verticalHead.up = tail2
    }
    
}

// merge matrices horizontally

func +- <T:Equatable where T: Hashable>(lhs: SudokuMatrix<T>, rhs: SudokuMatrix<T>) {
    if rhs.lateralHead.key == nil {
        return
    }
    
    if lhs.lateralHead.key == nil {
        lhs.lateralHead = rhs.lateralHead
    }
    
    if let tail1 = lhs.lateralHead.left, tail2 = rhs.lateralHead.left {
        tail1.right = rhs.lateralHead
        rhs.lateralHead.left = tail1
        tail2.right = lhs.lateralHead
        lhs.lateralHead.left = tail2
    }
    
}



struct PuzzleKey: Hashable {
    
    var cell: PuzzleCell?
    var header: ColumnHeader?
    
    
    init(node: PuzzleKey){
        cell = node.cell
        header = node.header
    }
    
    init(cell: PuzzleCell) {
        self.cell = cell
    }
    
    init(header: ColumnHeader) {
        self.header = header
    }
    
    var hashValue: Int {
        guard let cell = cell else {
            return 0
        }
        return cell.hashValue
    }
    
    
}



extension PuzzleKey: Equatable {}