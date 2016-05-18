//
//  PuzzleStore.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import UIKit
import CoreData


class PuzzleStore: NSObject {
    static let sharedInstance = PuzzleStore()
    
    
    var operationQueue = NSOperationQueue()
    var difficulty: PuzzleDifficulty = .Medium
    
    var managedObjectContext: NSManagedObjectContext {
        get {
            return CoreDataStack.sharedStack.managedObjectContext
        }
    }
    
    
    var completionHandler: (Puzzle -> ())?
    
    
    func setPuzzleDifficulty(pd:PuzzleDifficulty) {
        difficulty = pd
    }
    
    func getPuzzleForController(controller: PlayPuzzleDelegate, withCompletionHandler handler: (Puzzle ->())) {
        
        self.difficulty = controller.difficulty
        
        
        let puzzleFetch = NSFetchRequest(entityName: Puzzle.entityName)
        
        let fetchPredicate = Puzzle.predicateForDifficulty(difficulty)
        
        puzzleFetch.predicate = fetchPredicate
        
        var fetchedPuzzles: [Puzzle]
        
        do {
            fetchedPuzzles = try managedObjectContext.executeFetchRequest(puzzleFetch) as! [Puzzle]
        } catch {
            fatalError("puzzle fetch failed with error: \(error)")
        }
        
        if fetchedPuzzles.count > 0 {
            handler(fetchedPuzzles.last!)
        } else {
            
            controller.prepareForLongFetch()
            
            dispatch_async(concurrentPuzzleQueue) {
                self.completionHandler = handler
                SamuraiMatrix().generatePuzzle()
                
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
    
    func puzzleReady(initials: [PuzzleCell], solution: [PuzzleCell], rawScore:Int) {
        
        let initials = initials.filter({!($0.companionCell != nil && $0.boardIndex == 0)})
        let solution = solution.filter({!($0.companionCell != nil && $0.boardIndex == 0)})
        
        let puzz = Puzzle.init(initialValues: initials, solution: solution, rawScore: rawScore)
        puzz.difficultyLevel = self.difficulty.identifier
        
        CoreDataStack.sharedStack.saveMainContext()
        
        dispatch_async(GlobalMainQueue) {
            self.completionHandler!(puzz)
            self.completionHandler = nil
        }
        
    }
}
