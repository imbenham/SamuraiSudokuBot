//
//  OptionMenuFooter.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/9/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class OptionMenuFooter: UITableViewHeaderFooterView {
    
    var buttonColor = UIColor(red: 51/255, green: 204/255, blue: 51/255, alpha: 1)
    let saveButton = UIButton()
    
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override func layoutSubviews() {
        
        
        backgroundView?.addSubview(saveButton)
       
        saveButton.frame = CGRectMake(frame.width/2-(1/2 * frame.height), 0, frame.height, frame.height) //CGRectMake((self.frame.width / 2) - ((self.frame.height * 4/5) / 2), (self.frame.height * 1/5)/2, self.frame.height * 4/5, self.frame.height * 4/5)
        
        let configs = Utils.ButtonConfigs()
                
        let title = configs.getAttributedTitle("Save")
        let background = configs.backgroundImageForSize(saveButton.frame.size, selected: true)
        saveButton.titleLabel?.numberOfLines = 1
        saveButton.titleLabel?.adjustsFontSizeToFitWidth = true
        saveButton.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2)
        saveButton.setAttributedTitle(title, forState: .Normal)
        saveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        saveButton.setBackgroundImage(background, forState: .Normal)
        saveButton.showsTouchWhenHighlighted = true
        saveButton.tintColor = UIColor.whiteColor()
        
        saveButton.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        saveButton.layer.cornerRadius = saveButton.frame.width/2
        saveButton.clipsToBounds = true
        
        
    }
    
    override func prepareForReuse() {
        userInteractionEnabled = true
        contentView.userInteractionEnabled = true
        saveButton.userInteractionEnabled = true

    }
}

