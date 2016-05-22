//
//  Extensions.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

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