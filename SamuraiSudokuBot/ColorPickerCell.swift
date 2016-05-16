//
//  ColorPickerCell.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/15/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class ColorPickerCell: UITableViewCell {
    var greenTab = UIView()
    var orangeTab = UIView()
    var blueTab = UIView()
    var yellowTab = UIView()
    
    var selectedTab: Int = 0 {
        willSet {
            if newValue != selectedTab {
                let old = tabs[selectedTab]
                old.alpha = 0.5
                old.layer.borderColor = UIColor.blackColor().CGColor
            }
        }
        
        didSet {
            if oldValue != selectedTab {
                let new = tabs[selectedTab]
                new.alpha = 1.0
                new.layer.borderColor = UIColor.whiteColor().CGColor
            }
        }
    }
    
    var tabs: [UIView] {
        get {
            return [greenTab, orangeTab, blueTab, yellowTab]
        }
    }
    
    override init (style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        didLoad()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func didLoad() {
        
        backgroundColor = UIColor.blackColor()
        
        for (index, tab) in tabs.enumerate() {
            tab.tag = index
            addSubview(tab)
            tab.backgroundColor = Utils.Palette.getColorForRaw(index)
            
            
            tab.layer.borderWidth = 2.0
            
            if tab.tag == selectedTab {
                tab.alpha = 1
                tab.layer.borderColor = UIColor.whiteColor().CGColor
            } else {
                tab.alpha = 0.5
                tab.layer.borderColor = UIColor.blackColor().CGColor
            }
        }
    }
    
    override func layoutSubviews() {
        let sideInset:CGFloat = 6.0

        layoutMargins = UIEdgeInsets(top: 0, left: sideInset, bottom: 0, right: sideInset)
        
        for (index, tab) in tabs.enumerate() {
            
            tab.frame.size = CGSizeMake((self.frame.width - sideInset * 2) / 5, self.frame.height * 4/5)
            let quad = (self.frame.size.width - 2 * sideInset) / 4
            let offset:CGFloat = 8 + sideInset
            tab.frame.origin = CGPointMake(self.frame.origin.x + (quad * CGFloat(index)) + offset, self.frame.height * 1/10)
            
        }

    }
    
    func unsetSelectedTab(tab: Int) {
        let unselected = tabs[tab]
        
        unselected.alpha = 0.5
        unselected.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    //MARK: UIResponder
    
  /*  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        return
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        return
    }*/
}