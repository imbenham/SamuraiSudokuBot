//
//  ChoosePuzzleMenuHeader.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/12/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class ChoosePuzzleMenuHeader: UIView {
    
    var titleLabel = UILabel()
    let titleText = "Choose a difficulty \n level to get started."
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.blackColor()
        self.addSubview(titleLabel)
        
        titleLabel.attributedText = Utils.ButtonConfigs().getAttributedBodyText(titleText)
        
        titleLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor)
        titleLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
        titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(6, 6, 0, 6))
        titleLabel.layer.borderColor = UIColor.whiteColor().CGColor
        titleLabel.layer.borderWidth = 2.0
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .Center
    }
    
}
