//
//  CoreDataStack.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import CoreData

final class CoreDataStack: @unchecked Sendable {
    static let shared = CoreDataStack()
    let container: NSPersistentContainer
    let backgroundContext: NSManagedObjectContext

    private init() {
        container = NSPersistentContainer(name: "TZMatveeva_2025_07_08")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        backgroundContext = container.newBackgroundContext()
        backgroundContext.automaticallyMergesChangesFromParent = true
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    var context: NSManagedObjectContext {
        backgroundContext
    }

    func save() {
        backgroundContext.perform {
            if self.backgroundContext.hasChanges {
                do {
                    try self.backgroundContext.save()
                } catch {
                    print("Failed to save background context: \(error)")
                }
            }
        }
    }
}

