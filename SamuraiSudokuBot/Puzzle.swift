//
//  Puzzle.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 5/16/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation
import CoreData


class Puzzle: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    // Insert code here to add functionality to your managed object subclass
    
    static let entityName = "Puzzle"
    
    static func predicateForDifficulty(difficulty: PuzzleDifficulty) -> NSPredicate {

        return NSPredicate(format: "difficultyLevel = '\(difficulty.identifier)'")
    }
    
    
    init(initialValues: [PuzzleCell], solution:[PuzzleCell], rawScore: Int) {
        
        let ctxt = CoreDataStack.sharedStack.managedObjectContext
        
        let entityDescriptor = NSEntityDescription.entityForName("Puzzle", inManagedObjectContext: ctxt)!
        
        super.init(entity: entityDescriptor, insertIntoManagedObjectContext: ctxt)
        
        self.initialValues.setByAddingObjectsFromArray(initialValues.map({$0.toBackingCell().setPuzzleInitalAndReturn(self)}))
        
        self.solution.setByAddingObjectsFromArray(solution.map({$0.toBackingCell().setPuzzleSolutionAndReturn(self)}))
        
        
        self.rawScore = NSNumber(integer: rawScore)
        
    }
    
    override func didSave() {
        self.modifiedDate = NSDate()
    }
    
    override func awakeFromInsert() {
        self.modifiedDate = NSDate()
    }
    
    override func awakeFromFetch() {
        self.modifiedDate = NSDate()
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func solutionArray() -> [BackingCell] {
        return Array(solution) as! [BackingCell]
    }
    
    func initialsArray() -> [BackingCell] {
        return Array(initialValues) as! [BackingCell]
    }

}
