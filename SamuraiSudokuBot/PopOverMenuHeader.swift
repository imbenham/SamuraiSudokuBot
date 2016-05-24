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
        
        titleLabel.attributedText = Utils.ButtonConfigs().getAttributedBodyText(titleText)
        
        titleLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor)
        titleLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
        titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(6.25, 6, 0, 6))
        titleLabel.layer.borderColor = UIColor.whiteColor().CGColor
        titleLabel.layer.borderWidth = borderWidth
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .Center
    }
    
}
