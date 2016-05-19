//
//  PopOverSectionHeaderView.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/19/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class PopOverSectionHeaderView: UIView {
    var titleLabel = UILabel()
    let titleText: String
    
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
        
        titleLabel.attributedText = Utils.TextConfigs().getAttributedTitle(titleText, withColor: UIColor.whiteColor())
        
        titleLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor)
        titleLabel.centerYAnchor.constraintEqualToAnchor(centerYAnchor)
        titleLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(6, 16, 0, 6))
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .Left
    }
}