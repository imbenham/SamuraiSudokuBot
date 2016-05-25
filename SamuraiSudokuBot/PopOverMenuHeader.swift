//
//  ChoosePuzzleMenuHeader.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/12/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class PopOverMenuHeader: UIView {
    
    var titleLabel = UILabel()
    let titleText:String
    
    init(frame: CGRect, title:String) {
        titleText = title
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        titleText = ""
        super.init(coder: aDecoder)
    }
    
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.blackColor()
        self.addSubview(titleLabel)
        
        let borderWidth:CGFloat = 2.0
        
        titleLabel.attributedText = Utils.TextConfigs.getAttributedBodyText(titleText)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        
        let leftPin = NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 6)
        let rightPin = NSLayoutConstraint(item: titleLabel, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -6)
        let topPin = NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 6)
        let bottomPin = NSLayoutConstraint(item: titleLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        
        self.addConstraints([leftPin, rightPin, topPin, bottomPin])
        
        titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(6.25, 16, 0, 6))
        titleLabel.layer.borderColor = UIColor.whiteColor().CGColor
        titleLabel.layer.borderWidth = borderWidth
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .Center
    }
    
}
