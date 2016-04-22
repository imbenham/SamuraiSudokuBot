//
//  SamuraiMatrixExtension.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

extension SamuraiMatrix {
    
    // function for finding the exact cell choice when a chosen cell has a companion cell
    
    func companionChoice(choice: LinkedNode<PuzzleKey>) -> LinkedNode<PuzzleKey>? {
        let head = choice.getLateralHead()
        
        guard var companion = head.companion else {
            return nil
        }
        
        while companion.latOrder != choice.latOrder {
            companion = companion.right!
        }
        
        return companion
    }
    
}