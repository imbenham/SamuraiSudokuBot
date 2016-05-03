//
//  SamuraiUIExtensions.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

extension SudokuItem {
    enum Side {
        case Top, Bottom, Left, Right
        
    }
    
    func addBorderToSide(side: Side, ofColor color: CGColor = UIColor.blackColor().CGColor, width: CGFloat = 2.0) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        let borderFrame:CGRect = {
            switch side {
            case .Top:
                return CGRectMake(0, 0, self.frame.width, width)
            case .Bottom:
                return CGRectMake(0, self.frame.height, self.frame.width, width)
            case .Left:
                return CGRectMake(0, 0, width, self.frame.height)
            case .Right:
                return CGRectMake(0, self.frame.width, width, self.frame.height)
                
            }
        }()
        
        border.frame = borderFrame
        
        
        self.layer.addSublayer(border)
        
        self.drawRect(borderFrame)
        
    }
    
    func addBordersToSides(sides:[Side], ofColor color: CGColor = UIColor.blackColor().CGColor, width: CGFloat = 2.0) {
        
        for side in sides {
            addBorderToSide(side, ofColor: color, width: width)
        }
    }
    
    func addBorders() {
        if self.index == 4 {
            addBordersToSides([.Left, .Right, .Top, .Bottom])
        }
    }
    
}

class MiddleBoard: SudokuBoard {
    override init(frame: CGRect) {
        super.init(frame: frame)
        boxes = []
        
        for index in 0...8 {
            let aBox = Box(index: index, withParent: self)
            aBox.parentSquare = self
            boxes.append(aBox)
        }
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        boxes = []
        for index in 0...8 {
            let aBox = Box(index: index)
            boxes.append(aBox)
        }
        
    }
    
    override func prepareBoxes() {
        super.prepareBoxes()
        
        backgroundColor = UIColor.clearColor()
    }
    
    
}

class MiddleBox: Box {
    override init(index: Int) {
        super.init(index:index)
        
        if [0, 2, 6, 8].filter({$0 == index}).count > 0  {
            boxes = []
        }
        
    }
    
    convenience init (index withIndex: Int, withParent parent: SudokuBoard){
        self.init(index: withIndex)
        
        if [0, 2, 6, 8].filter({$0 == index}).count > 0  {
            boxes = []
        }
        
        self.parentSquare = parent
        controller = parent.controller
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if [0, 2, 6, 8].filter({$0 == self.index}).count > 0  {
            boxes = []
        }
        
        
    }
    
    override func layoutSubviews() {
        self.prepareBoxes()
    }
    
    override func prepareBoxes() {
        
        if [0, 2, 6, 8].filter({$0 == self.index}).count == 0  {
            super.prepareBoxes()
            
            
        }
        
        
    }
}