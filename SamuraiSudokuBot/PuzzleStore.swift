//
//  PuzzleStore.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit


class PuzzleStore: NSObject {
    static let sharedInstance = PuzzleStore()
    
    
    var operationQueue = NSOperationQueue()
    var difficulty: PuzzleDifficulty = .Medium
    private var rawDiffDict: [PuzzleDifficulty:Int] = [.Easy : 130, .Medium: 160, .Hard: 190, .Insane: 240]
    
    
    var completionHandler: (Puzzle -> ())?
    
    
    func setPuzzleDifficulty(pd:PuzzleDifficulty) {
        difficulty = pd
    }
    
    func getPuzzleDifficulty() -> Int {
        switch difficulty {
        case .Custom(let val):
            return val
        default:
            return rawDiffDict[difficulty]!
        }
    }
    
    
    
    
    func getPuzzleForController(controller: PlayPuzzleDelegate, withCompletionHandler handler: (Puzzle ->())) {
        
        
        if false { //TODO PLACEHOLDER -- NEED TO ADD SAVED PUZZLE LOGIC
            //handler(saved.0, saved.1)
            //Add logic for saved puzzle
            //print(saved)
            //return
        } else {
            
            controller.prepareForLongFetch()
            
            dispatch_async(concurrentPuzzleQueue) {
                self.completionHandler = handler
                self.difficulty = controller.difficulty
                SamuraiMatrix.sharedInstance.generatePuzzle()
                
            }
            
        }
        
    }
    
    /*
     
     func savedPuzzleForDifficulty(difficulty: PuzzleDifficulty) -> (Puzzle, [String:Any]?)? {
     let defaults = NSUserDefaults.standardUserDefaults()
     guard let key = difficulty.currentKey, let dict = defaults.objectForKey(key) as? [String: AnyObject], puzzData = dict["puzzle"] as? NSData, assigned = dict["progress"] as? [[String:Int]], let annotatedDict = dict["annotated"] as? [NSDictionary], let discovered = dict["discovered"] as? [[String: Int]], let time = dict["time"] as? Double  else {
     return nil
     }
     let currentPuzz = NSKeyedUnarchiver.unarchiveObjectWithData(puzzData) as! Puzzle
     let assignedCells = assigned.map{PuzzleCell(dict: $0)!}
     let discoveredCells = discovered.map{PuzzleCell(dict: $0)!}
     
     defaults.removeObjectForKey(key)
     
     let puzzInfo:[String:Any] = ["progress": assignedCells, "discovered":discoveredCells, "annotated":annotatedDict, "time":time]
     
     return (currentPuzz, puzzInfo)
     
     }
     */
    
    func puzzleReady(initials: [PuzzleCell], solution: [PuzzleCell]) {
        
        let initials = initials.filter({!($0.companionCell != nil && $0.boardIndex == 0)})
        let solution = solution.filter({!($0.companionCell != nil && $0.boardIndex == 0)})
        
        dispatch_async(GlobalMainQueue) {
            self.completionHandler!(Puzzle.init(initialValues: initials, solution: solution))
            self.completionHandler = nil
        }
        
        
        
    }
}
