//
//  SudokuNumPad.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

import UIKit


@IBDesignable

class SudokuNumberPad: UIView {
    
    var buttons: [UIButton] = []
    var current: UIButton? = nil {
        didSet {
            if let oldCurrent = oldValue {
                if oldCurrent == current {
                    return
                }
                //oldCurrent.backgroundColor = UIColor.clearColor()
                oldCurrent.setTitleColor(defaultTitleColor, forState: .Normal)
            }
            if let someVal = current {
                //someVal.backgroundColor = UIColor.clearColor()
                someVal.setTitleColor(currentTitleColor, forState: .Normal)
            }
        }
    }
    
    var symbolSet: SymbolSet {
        get {
            let defaults = NSUserDefaults.standardUserDefaults()
            let symType = defaults.integerForKey("symbolSet")
            switch symType {
            case 0:
                return .Standard
            case 1:
                return .Critters
            default:
                return .Flags
            }
            
        }
    }
    
    var delegate: NumPadDelegate?
    var buttonHeight:CGFloat = 0.0
    let noteModeColor = UIColor.blackColor()//UIColor(red: 1.0, green: 1.0, blue: 0, alpha: 0.3)
    
    // customization points
    
    @IBInspectable var currentColor = UIColor.blackColor()
    @IBInspectable var defaultColor = UIColor.whiteColor()
    @IBInspectable var defaultTitleColor = UIColor(red: 51/255, green: 204/255, blue: 51/255, alpha: 1)
    @IBInspectable var currentTitleColor = UIColor.whiteColor()
    
    override func drawRect(rect: CGRect) {
        let rectHeight = rect.size.width/9
        let canvasRect = CGRectMake(0, 0, rect.width, rectHeight)
        let context = UIGraphicsGetCurrentContext()
        
        self.backgroundColor = UIColor.clearColor()
        
        self.backgroundColor?.setFill()
        CGContextFillRect(context, canvasRect)
        
        let buttonSize = CGSize(width: canvasRect.height, height: canvasRect.height)
        
        let configs = Utils.sharedUtils.ButtonConfigs
        let buttonImage = configs.backgroundImageForSize(buttonSize, selected: false)
        let selectedImage = configs.backgroundImageForSize(buttonSize, selected: true)
        
        for index in 1...9 {
            let buttonFrame = CGRect(x: rectHeight * CGFloat((index - 1)), y: 0, width: buttonSize.width, height: buttonSize.height)
            let button = UIButton.init(frame: buttonFrame)
            button.tag = index
            button.addTarget(self, action: #selector(SudokuNumberPad.buttonTapped(_:)), forControlEvents: .TouchUpInside)
            button.setBackgroundImage(buttonImage, forState: .Normal)
            button.setBackgroundImage(selectedImage, forState: .Selected)
            button.setTitleColor(defaultTitleColor, forState: .Normal)
            button.setBackgroundImage(selectedImage, forState: .Highlighted)
            
            let attribString = configs.getAttributedTitle(symbolSet.getSymbolForValue(index))
            button.setAttributedTitle(attribString, forState: .Normal)
            button.setAttributedTitle(attribString, forState: .Selected)
            
            buttons.append(button)
            button.layer.cornerRadius = button.frame.size.width / 2
            button.clipsToBounds = true
            
            button.layer.borderColor = UIColor.blackColor().CGColor
            button.layer.borderWidth = 2.0
            
            addSubview(button)
        }
    }
    
    /* override func layoutSubviews() {
     self.userInteractionEnabled = true
     for index in 0...buttons.count-1 {
     setTextTitleForValue(index+1)
     let button = buttons[index]
     button.setTitleColor(defaultTitleColor, forState: .Normal)
     button.backgroundColor = defaultColor
     self.addSubview(button)
     constrainButton(button, atIndex: index)
     let radius = self.frame.height/2
     buttonHeight = radius
     button.layer.cornerRadius = radius
     button.layer.borderColor = UIColor.blackColor().CGColor
     button.layer.borderWidth = 3.0
     button.tag = index+1
     button.addTarget(self, action: #selector(SudokuNumberPad.buttonTapped(_:)), forControlEvents: .TouchUpInside)
     
     }
     }*/
    
    
    
    
    func constrainButton(button: UIButton, atIndex index: Int) {
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonY = NSLayoutConstraint(item: button, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0)
        let buttonHeight = NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        let buttonWidth = NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1, constant: 0)
        
        var leftPin:NSLayoutConstraint
        
        let leftNeighbor = index == 0 ? self : buttons[index-1]
        if index == 0 {
            leftPin = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: leftNeighbor, attribute: .Leading, multiplier: 1, constant: 0)
        } else {
            leftPin = NSLayoutConstraint(item: button, attribute: .Leading, relatedBy: .Equal, toItem: leftNeighbor, attribute: .Trailing, multiplier: 1, constant: 0)
        }
        
        
        let constraints = index == 8 ? [buttonY, buttonHeight, buttonWidth, leftPin, NSLayoutConstraint(item: button, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1, constant: 0)] : [buttonY, buttonHeight, buttonWidth, leftPin]
        
        self.addConstraints(constraints)
    }
    
    func buttonTapped(sender: UIButton) {
        let val = sender.tag
        if let del = self.delegate {
            if del.noteMode() {
                del.noteValueChanged(val)
                noteModeRefreshButton(sender)
                return
            }
            del.valueSelected(val)
        }
    }
    
    func refresh() {
        if self.delegate == nil {
            return
        }
        
        if let existingValue = self.delegate!.currentValue {
            if let nowCurrent = current {
                if nowCurrent == existingValue {
                    return
                }
            }
            current = buttons[existingValue-1]
        } else {
            if current != nil {
                current = nil
            }
        }
        
        if !delegate!.noteMode() {
            var allButtons = buttons
            if let cur = current {
                allButtons.removeAtIndex(cur.tag-1)
            }
            for button in allButtons {
                // button.backgroundColor = defaultColor
                button.setTitleColor(defaultTitleColor, forState: .Normal)
            }
        } else {
            configureForNoteMode()
        }
    }
    
    func configureForNoteMode() {
        if let del = delegate {
            if !del.noteMode() {
                return
            }
        }
        var allButtons = buttons
        if let vals = delegate!.noteValues() {
            for val in vals {
                let button = buttonWithTag(val)!
                //button.backgroundColor = noteModeColor
                button.setTitleColor(currentTitleColor, forState: .Normal)
                allButtons.removeAtIndex(allButtons.indexOf(button)!)
            }
        }
        for button in allButtons {
            // button.backgroundColor = defaultColor
            button.setTitleColor(defaultTitleColor, forState: .Normal)
            
        }
    }
    
    
    func noteModeRefreshButton(button: UIButton) {
        if let vals = delegate?.noteValues() {
            //button.backgroundColor = vals.contains(button.tag) ? noteModeColor : defaultColor
            let color =  vals.contains(button.tag) ? currentTitleColor : defaultTitleColor
            button.setTitleColor(color, forState: .Normal)
        }
    }
    
    func buttonWithTag(tag:Int) -> UIButton? {
        for button in buttons {
            if button.tag == tag {
                return button
            }
        }
        return nil
    }
    
    
    
}


protocol NumPadDelegate {
    var currentValue: Int? {get}
    
    func valueSelected(value: Int)
    func noteValueChanged(value: Int)
    
    func noteValues() -> [Int]?
    func noteMode() -> Bool
}