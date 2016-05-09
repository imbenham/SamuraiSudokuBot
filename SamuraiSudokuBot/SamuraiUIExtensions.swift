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
    
    override var tiles: [Tile] {
        get {

            var tiles: [Tile] = []
            for box in [boxes[1], boxes[3], boxes[4], boxes[5], boxes[7]] {
                tiles += box.boxes
            }
    
            return tiles
        }
    }
    
}
