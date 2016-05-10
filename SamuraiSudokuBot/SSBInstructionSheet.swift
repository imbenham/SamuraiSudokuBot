//
//  SSBInstructionSheet.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/9/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

class SSBInstructionSheet: UIView {
    
    var text = Utils.ButtonConfigs.getAttributedBodyText("A samurai sudoku puzzle consists of five boards: one board in the middle, with four exterior boards overlapping and sharing one 9x9 box each with the middle board.  To solve a samurai sudoku puzzle you must complete the grid such that each cell in the grid has a value, each 9x9 box in each board contains the digits 1-9 (or has one of each possible symbol), each row in each board contains 1-9, and each column in each board contains 1-9. Tiles shared between boards belong to both boards and count towards satisfying the above-described constraints for both boards.")
    
    let textview = UITextView()
    let exitButton = UIButton(type: .System)
    
    override var frame: CGRect {
        didSet {
            textview.frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(5, 5, 35, 5))
            exitButton.frame = CGRectMake(textview.frame.origin.x, textview.frame.size.height+1, textview.frame.width, frame.height - (textview.frame.height + 1))
            textview.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            exitButton.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textview.frame = frame
        textview.editable = false
        textview.bounces = false
        addSubview(textview)
        addSubview(exitButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        
        exitButton.setAttributedTitle(Utils.ButtonConfigs.getAttributedTitle("  X  "), forState: .Normal)
        
        textview.backgroundColor = UIColor.blackColor()
        textview.attributedText = text
        
        textview.layer.borderColor = UIColor.whiteColor().CGColor
        textview.layer.borderWidth = 1.0
        
        exitButton.tintColor = UIColor.whiteColor()
        exitButton.titleLabel?.backgroundColor = UIColor.whiteColor()
        
        exitButton.addTarget(self, action: #selector(self.pop), forControlEvents: .TouchUpInside)
        
        
    }
    
    func pop() {
        guard let tv = superview as? UITableView, let hmc = tv.delegate as? HelpMenuController else {
            return
        }
        
        let defaultSize = CGSizeMake(225, 225)
        
        let defaultRect = CGRectMake(self.frame.origin.x, self.frame.origin.y, defaultSize.width, defaultSize.height)
        
        let animations: () -> () = {
            self.frame = defaultRect
            hmc.preferredContentSize = defaultSize
        }
        
        let emptyRect = CGRectMake(defaultRect.origin.x, defaultRect.height, defaultRect.width, 0)
        
        let animations2: () -> () = {
            self.frame = emptyRect
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: animations) { (completed: Bool) -> () in
            if completed {
                UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseInOut, animations: animations2){
                    completed in
                    self.removeFromSuperview()
                    tv.bounces = true
                    hmc.selectedIndex = nil
                }
            }
            
        }
        
    }
}
