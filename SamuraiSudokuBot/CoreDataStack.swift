//
//  CoreDataStack.swift
//  SamuraiSudokuBot
//
//  Created by Isaac Benham on 4/21/16.
//  Copyright © 2016 Isaac Benham. All rights reserved.
//

import Foundation

import Foundation
import CoreData

class CoreDataStack {
    
    static let moduleName = Utils.Constants.Identifiers.coreDataModuleName
    static let sharedStack = CoreDataStack()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(moduleName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        return NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        let persistentStoreURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(moduleName).sqlite")
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: persistentStoreURL, options: [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true])
        } catch {
            fatalError("Persistent store could not be initialized! \(error)")
        }
        
        return coordinator
    }()
    
    private lazy var savePuzzleManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        return managedObjectContext
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.parentContext = self.savePuzzleManagedObjectContext
        managedObjectContext.undoManager = NSUndoManager()
        managedObjectContext.undoManager?.disableUndoRegistration()
        managedObjectContext.processPendingChanges()
        managedObjectContext.undoManager!.removeAllActions()
        return managedObjectContext
    }()
    
    func saveMainContext() {
        guard managedObjectContext.hasChanges || savePuzzleManagedObjectContext.hasChanges else {
            return
        }
        
        managedObjectContext.performBlockAndWait() {
            do {
                try self.managedObjectContext.save()
                print("started saving")
            } catch {
                fatalError("Error saving main managed object context! \(error)")
            }
        }
        
        savePuzzleManagedObjectContext.performBlock() {
            do {
                try self.savePuzzleManagedObjectContext.save()
                print("finished saving")
            } catch {
                fatalError("Error saving private managed object context! \(error)")
            }
        }
    }
    
}