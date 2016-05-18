//
//  TableCell.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/16/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class TableCell: UIView {
    var labelVertInset: CGFloat = 0 {
        didSet {
            label?.frame.origin.y = labelVertInset
            label?.frame.size.height = self.frame.size.height - (2*labelVertInset)
        }
    }
    var labelHorizontalInset: CGFloat = 0 {
        didSet {
            label?.frame.origin.x = labelHorizontalInset
        }
    }
    var label: UILabel? {
        didSet {
            if let old = oldValue {
                old.removeFromSuperview()
            }
            var rect = self.bounds
            rect.origin.x += labelHorizontalInset
            rect.origin.y += labelVertInset
            rect.size.height -= 2*labelVertInset
            label?.frame = rect
            label?.font = UIFont(name: "futura", size: UIFont.labelFontSize())
            label!.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.addSubview(label!)
        }
    }
    
    override var frame:CGRect {
        
        didSet {
            var labelFrame = bounds
            labelFrame.insetInPlace(dx: labelHorizontalInset, dy: labelVertInset)
            label?.frame = labelFrame
        }
    }
    
    var section: Int?
}