//
//  BackingCell+CoreDataProperties.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension BackingCell {

    @NSManaged var assignedValue: NSNumber?
    @NSManaged var board: NSNumber
    @NSManaged var column: NSNumber
    @NSManaged var revealed: NSNumber
    @NSManaged var row: NSNumber
    @NSManaged var value: NSNumber
    @NSManaged var notes: String?
    @NSManaged var puzzleInitial: Puzzle?
    @NSManaged var puzzleSolution: Puzzle?

}
