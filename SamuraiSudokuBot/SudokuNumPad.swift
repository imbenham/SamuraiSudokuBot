//
//  SudokuNumPad.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

import UIKit


//@IBDesignable

class SudokuNumberPad: UIView {
    
    let buttons: [UIButton] = {
        var buttons: [UIButton] = []
        for num in 1...9 {
            let button = UIButton()
            button.tag = num
            buttons.append(button)
        }
        return buttons
    }()
    
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
    
    var currentColor = UIColor.blackColor()
    var defaultColor = UIColor.whiteColor()
    var defaultTitleColor = UIColor(red: 51/255, green: 204/255, blue: 51/255, alpha: 1)
    var currentTitleColor = UIColor.whiteColor()
    
    override func drawRect(rect: CGRect) {
        let rectHeight = rect.size.width/9
        let canvasRect = CGRectMake(0, 0, rect.width, rectHeight)
        let context = UIGraphicsGetCurrentContext()
        
        self.backgroundColor = UIColor.clearColor()
        
        self.backgroundColor?.setFill()
        CGContextFillRect(context, canvasRect)
        
        let buttonSize = CGSize(width: canvasRect.height, height: canvasRect.height)
        
        let configs = Utils.ButtonConfigs
        let buttonImage = configs.backgroundImageForSize(buttonSize, selected: false)
        let selectedImage = configs.backgroundImageForSize(buttonSize, selected: true)
        
        for index in 1...9 {
            
            let buttonFrame = CGRect(x: rectHeight * CGFloat((index - 1)), y: 0, width: buttonSize.width, height: buttonSize.height)
            let button = buttons[index-1]
            button.frame = buttonFrame
            button.tag = index
            button.setBackgroundImage(buttonImage, forState: .Normal)
            button.setBackgroundImage(selectedImage, forState: .Selected)
            button.setTitleColor(defaultTitleColor, forState: .Normal)
            button.setTitleColor(currentTitleColor, forState: .Normal)
            button.setBackgroundImage(selectedImage, forState: .Highlighted)
            
            let attribString = configs.getAttributedTitle(symbolSet.getSymbolForValue(index))
            button.setAttributedTitle(attribString, forState: .Normal)
            button.setAttributedTitle(attribString, forState: .Selected)
            
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
    
    func refresh() {
        if self.delegate == nil {
            return
        }
        
        if !delegate!.noteMode {
            let allButtons = buttons
           
            for button in allButtons {
                button.selected = self.delegate?.currentValue == button.tag ? true : false
                button.userInteractionEnabled = true
            }
        } else {
            configureForNoteMode()
        }
        self.userInteractionEnabled = true
    }
    
    func configureForNoteMode() {
       
        guard let delegate = delegate where delegate.noteMode, let selected = delegate.noteValues() else {
            print("returning wihtout doing anything")
            print("\(self.delegate!.noteValues())")
            if !self.delegate!.noteMode {
                print("no note mode")
            }
            return
        }
        
        let notes = Set(selected)
        
        var initial: ([UIButton], [UIButton]) = ([], [])
        
        let twoSets: (include: [UIButton], excldue: [UIButton]) = buttons.reduce(initial, combine: {
            if notes.contains($1.tag) {
                initial.0.append($1)
            } else {
                initial.1.append($1)
            }
            return initial
        })
        
        print(twoSets)
        
        for button in twoSets.include {
            button.selected = true
        }
        
        for button in twoSets.excldue {
            button.selected = false
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


