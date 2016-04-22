//
//  Puzzle.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation
import CoreData


class Puzzle: NSManagedObject {
    
    // Insert code here to add functionality to your managed object subclass
    
    init(initialValues: [PuzzleCell], solution:[PuzzleCell]) {
        
        let ctxt = CoreDataStack.sharedStack.managedObjectContext
        
        let entityDescriptor = NSEntityDescription.entityForName("Puzzle", inManagedObjectContext: ctxt)!
        
        super.init(entity: entityDescriptor, insertIntoManagedObjectContext: ctxt)
        
        self.initialValues.setByAddingObjectsFromArray(initialValues.map({$0.toBackingCell().setPuzzleInitalAndReturn(self)}))
        self.solution.setByAddingObjectsFromArray(solution.map({$0.toBackingCell().setPuzzleSolutionAndReturn(self)}))
    }
    
    func solutionArray() -> [BackingCell] {
        return Array(solution) as! [BackingCell]
    }
    
    func initialsArray() -> [BackingCell] {
        return Array(initialValues) as! [BackingCell]
    }
}
