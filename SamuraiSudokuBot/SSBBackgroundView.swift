//
//  SSBBackgroundView.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

//@IBDesignable

class SSBBackgroundView: UIView {
    
    var bgColor: UIColor = UIColor.init(colorLiteralRed: 1.0, green: 0.7, blue: 0.1, alpha: 0.9)
    var drawColor: UIColor = UIColor.blackColor()
    var patternSize:CGFloat = 130
    
    var innerGradientColor: UIColor = UIColor.blackColor()
    var outerGradientColor: UIColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
    
    override func drawRect(rect: CGRect) {
        
        let mainColor = Utils.Palette.getTheme()
        
        outerGradientColor = mainColor
        drawColor = mainColor
        
        innerGradientColor = Utils.Palette.getThemeInnerGradient()
        
        let drawSize = CGSize(width: patternSize, height: patternSize)
        
        UIGraphicsBeginImageContextWithOptions(drawSize, true, 0.0)
        let drawingContext = UIGraphicsGetCurrentContext()
        
        
        CGContextSetFillColorWithColor(drawingContext, bgColor.CGColor)
        CGContextFillRect(drawingContext, CGRectMake(0, 0, drawSize.width, drawSize.height))
        
        drawColor.setStroke()
        
        var nodePoints: [CGPoint] = []
        
        let path = UIBezierPath()
        let startPoint = CGPoint(x: 0, y: patternSize * 0.15)
        path.moveToPoint(startPoint)
        
        
        var nextPoint = CGPoint(x:patternSize * 0.15, y: startPoint.y + (patternSize * 0.1))
        path.addLineToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.2
        path.addLineToPoint(nextPoint)
        
        nextPoint.x -= 1.0
        nodePoints.append(nextPoint)
        
        nextPoint.x +=  patternSize * 0.10 - 1
        
        path.moveToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.15
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.2
        nextPoint.y -= patternSize * 0.1
        
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.x = patternSize * 0.9
        path.addLineToPoint(nextPoint)
        
        var branchPoint = nextPoint
        
        branchPoint.y += patternSize * 0.05
        branchPoint.x += patternSize * 0.05
        
        path.addLineToPoint(branchPoint)
        
        branchPoint.y += patternSize * 0.15 + 1
        path.addLineToPoint(branchPoint)
        
        
        path.moveToPoint(nextPoint)
        nextPoint.x = patternSize
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.y += patternSize * 0.25
        nextPoint.x -= patternSize * 0.1
        
        nodePoints.append(nextPoint)
        nextPoint.x += 1
        path.moveToPoint(nextPoint)
        
        nextPoint.x -= patternSize * 0.25
        path.addLineToPoint(nextPoint)
        
        
        nextPoint.x -= patternSize * 0.15
        nextPoint.y -= patternSize * 0.05
        path.addLineToPoint(nextPoint)
        
        nextPoint.x -= patternSize * 0.2
        path.addLineToPoint(nextPoint)
        
        nextPoint.y += patternSize * 0.05
        nextPoint.x -= patternSize * 0.15
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.x = patternSize * 0.1
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.x -= 1
        
        nodePoints.append(nextPoint)
        
        nextPoint.x += patternSize * 0.05 + 1
        nextPoint.y += patternSize * 0.05 - 1
        
        path.moveToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.2
        nextPoint.y = patternSize * 0.65
        path.addLineToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.15
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.x -= 1
        nodePoints.append(nextPoint)
        
        nextPoint.x += patternSize * 0.1
        path.moveToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.025
        
        path.addLineToPoint(nextPoint)
        
        branchPoint = nextPoint
        
        nextPoint.y += patternSize * 0.075
        nextPoint.x += patternSize * 0.075
        path.addLineToPoint(nextPoint)
        
        path.moveToPoint(branchPoint)
        
        branchPoint.y -= patternSize * 0.075
        branchPoint.x += patternSize * 0.075
        
        path.addLineToPoint(branchPoint)
        
        branchPoint.x += patternSize * 0.175
        
        path.addLineToPoint(branchPoint)
        
        branchPoint.x += 0.05 * patternSize
        branchPoint.y += 0.05 * patternSize
        
        path.addLineToPoint(branchPoint)
        
        branchPoint.y += 0.05 * patternSize
        
        path.addLineToPoint(branchPoint)
        
        branchPoint.x -= patternSize * 0.05
        branchPoint.y += patternSize * 0.05 - 1
        
        nodePoints.append(branchPoint)
        
        // finished w/ branchpoint deadend
        
        path.moveToPoint(nextPoint)
        
        nextPoint.y += patternSize * 0.1
        path.addLineToPoint(nextPoint)
        
        branchPoint = nextPoint
        
        nextPoint.x = patternSize
        
        path.addLineToPoint(nextPoint)
        nextPoint.x = 0
        
        path.moveToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.075
        path.addLineToPoint(nextPoint)
        
        nextPoint.x -= 1
        nodePoints.append(nextPoint)
        
        nextPoint.x += patternSize * 0.1 - 1
        path.moveToPoint(nextPoint)
        
        nextPoint.x += patternSize * 0.15
        path.addLineToPoint(nextPoint)
        
        nextPoint.y += patternSize * 0.05
        nextPoint.x += patternSize * 0.05
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.y = patternSize
        path.addLineToPoint(nextPoint)
        
        nextPoint.y = 0
        path.moveToPoint(nextPoint)
        
        nextPoint.y += patternSize * 0.05
        nextPoint.x -= patternSize * 0.05
        path.addLineToPoint(nextPoint)
        
        nextPoint.x -= patternSize * 0.15
        
        path.addLineToPoint(nextPoint)
        
        nextPoint.x -= patternSize * 0.1 - 1
        nodePoints.append(nextPoint)
        
        path.moveToPoint(branchPoint)
        branchPoint.x -= patternSize * 0.1
        path.addLineToPoint(branchPoint)
        
        branchPoint.y += patternSize * 0.05
        branchPoint.x -= patternSize * 0.05
        path.addLineToPoint(branchPoint)
        
        branchPoint.y = patternSize
        path.addLineToPoint(branchPoint)
        
        branchPoint.y = 0
        path.moveToPoint(branchPoint)
        
        branchPoint.y += patternSize * 0.06
        path.addLineToPoint(branchPoint)
        
        branchPoint.x -= patternSize * 0.05
        branchPoint.y -= 1
        
        nodePoints.append(branchPoint)
        
        branchPoint.y += patternSize * 0.05 - 1
        branchPoint.x += patternSize * 0.05
        path.moveToPoint(branchPoint)
        
        branchPoint.y += patternSize * 0.05
        path.addLineToPoint(branchPoint)
        
        branchPoint.x -= patternSize * 0.05
        path.addLineToPoint(branchPoint)
        
        branchPoint.x = patternSize * 0.35 + 1
        branchPoint.y = patternSize * 0.25
        
        path.addLineToPoint(branchPoint)
        
        
        path.lineWidth = 1.0
        path.lineJoinStyle = .Bevel
        path.stroke()
        CGContextAddPath(drawingContext
            , path.CGPath)
        
        for nodePoint in nodePoints {
            var nodeRect = CGRectMake(nodePoint.x, nodePoint.y - patternSize * 0.05, patternSize * 0.1, patternSize * 0.1)
            nodeRect = CGRectInset(nodeRect, 1.0, 1.0)
            
            drawRadialInRect(drawingContext!, rect: nodeRect)
            
            CGContextStrokeEllipseInRect(drawingContext, nodeRect)
        }
        
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let context = UIGraphicsGetCurrentContext()
        
        UIColor(patternImage: image).setFill()
        CGContextFillRect(context, rect)
        
    }
    
    func drawRadialInRect(context: CGContextRef, rect: CGRect) {
        let locations: [CGFloat] = [0.0, 1.0]
        let colorSpace =  CGColorSpaceCreateDeviceRGB()
        
        let colors = [outerGradientColor.CGColor, innerGradientColor.CGColor]
        
        let gradient = CGGradientCreateWithColors(colorSpace, colors, locations)
        
        
        let  startPoint = CGPoint(x: rect.origin.x + rect.size.width/2, y: rect.origin.y + rect.size.height/2)
        let endPoint = CGPoint(x: rect.origin.x + (rect.size.width * 0.5), y: rect.origin.y + (rect.size.height * 0.5))
        
        let endRadius:CGFloat = 0
        let startRadius = rect.size.width/2
        
        CGContextDrawRadialGradient(context, gradient, startPoint,
                                    startRadius, endPoint, endRadius, CGGradientDrawingOptions.init(rawValue: 0))
    }
}