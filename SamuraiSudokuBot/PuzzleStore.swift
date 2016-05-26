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
    
    lazy var recentPuzzleFetch: NSFetchRequest = {
        let puzzleFetch = NSFetchRequest(entityName: Puzzle.entityName)
        puzzleFetch.sortDescriptors = [NSSortDescriptor(key: "modifiedDate", ascending: false)]
        return puzzleFetch
    }()
    
    var hasRecents: Bool {
        get {
            let err: NSErrorPointer = nil
            return self.managedObjectContext.countForFetchRequest(recentPuzzleFetch, error: err) > 0
        }
    }
    
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
            
            
            dispatch_async(Utils.ConcurrentPuzzleQueue) {
                self.completionHandler = handler
                SamuraiMatrix().generatePuzzle()
                
            }
            
        }
        
    }
    
    func getMostRecentPuzzleForController(controller: PlayPuzzleDelegate, withCompletionHandler handler: (Puzzle ->())) {
        let puzzleFetch = NSFetchRequest(entityName: Puzzle.entityName)
        puzzleFetch.sortDescriptors = [NSSortDescriptor(key: "modifiedDate", ascending: false)]
        
        var fetchedPuzzles: [Puzzle]
        
        
        
        
        
        do {
            fetchedPuzzles = try managedObjectContext.executeFetchRequest(puzzleFetch) as! [Puzzle]
        } catch {
            fatalError("puzzle fetch failed with error: \(error)")
        }

        handler(fetchedPuzzles[0])
    }
    
   
    
    func puzzleReady(initials: [PuzzleCell], solution: [PuzzleCell], rawScore:Int) {
        
        let initials = initials.filter({!($0.companionCell != nil && $0.boardIndex == 0)})
        let solution = solution.filter({!($0.companionCell != nil && $0.boardIndex == 0)})
        
        let puzz = Puzzle.init(initialValues: initials, solution: solution, rawScore: rawScore)
        puzz.difficultyLevel = self.difficulty.identifier
        
        CoreDataStack.sharedStack.saveMainContext()
        
        dispatch_async(Utils.GlobalMainQueue) {
            self.completionHandler!(puzz)
            self.completionHandler = nil
        }
        
    }
}
