//
//  Extensions.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit

extension Array {
    mutating func removeRandom(number: Int = 1) -> [Element] {
        var removed = 0
        var removedList: [Element] = []
        
        while removed < number {
            let random = Int(arc4random_uniform((UInt32(self.count))))
            removedList.append(self.removeAtIndex(random))
            removed += 1
        }
        
        return removedList
    }
}

extension UIView {
    
    func removeConstraints() {
        if let superView = self.superview {
            self.removeFromSuperview()
            superView.addSubview(self)
        }
    }
}

extension UIButton {
    convenience init(tag: Int) {
        self.init()
        self.tag = tag
    }
}

extension UIView {
    convenience init(tag: Int) {
        self.init()
        self.tag = tag
    }
}

extension TileValue {
    func getSymbolForTileValueforSet(symSet: Utils.TextConfigs.SymbolSet) -> String {
        switch symSet {
        case .Standard:
            return String(self.rawValue)
        case .Critters:
            let dict:[Int:String] = [1:"🐥", 2:"🙈", 3:"🐼", 4:"🐰", 5:"🐷", 6:"🐘", 7:"🐢", 8:"🐙", 9:"🐌"]
            return dict[self.rawValue]!
        case .Flags:
            let dict = [1:"🇨🇭", 2:"🇿🇦", 3:"🇨🇱", 4:"🇨🇦", 5:"🇯🇵", 6:"🇹🇷", 7:"🇫🇮", 8:"🇰🇷", 9:"🇲🇽"]
            return dict[self.rawValue]!
        }
    }
    
}