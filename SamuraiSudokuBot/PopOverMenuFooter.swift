//
//  PopOverMenuFooter.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/12/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class PopOverMenuFooter: UIView {
    
    var button: UIButton! = UIButton(type: .System)
    var buttonText = "Go!"
    
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        
        buttonText = text
        didLoad()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    func didLoad() {
        backgroundColor = UIColor.blackColor()
        addSubview(button)
    
        let buttonHeight = frame.height - 8
        button.frame.size = CGSizeMake(buttonHeight, buttonHeight)
        
        button.center = center
        button.layer.cornerRadius = button.frame.height/2
        button.clipsToBounds = true
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth =  2.0
        
        
        button.autoresizingMask = [.None]
        
        let configs = Utils.ButtonConfigs()
        button.setBackgroundImage(configs.backgroundImageForSize(button.frame.size, selected: true), forState: .Normal)
        button.setAttributedTitle(configs.getAttributedTitle(buttonText), forState: .Normal)

    }
}
