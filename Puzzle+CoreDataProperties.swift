//
//  Puzzle+CoreDataProperties.swift
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

extension Puzzle {

    @NSManaged var initialValues: NSSet
    @NSManaged var solution: NSSet

}
