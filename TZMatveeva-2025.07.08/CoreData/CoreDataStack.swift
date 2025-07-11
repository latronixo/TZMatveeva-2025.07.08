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

    private init() {
        container = NSPersistentContainer(name: "TZMatveeva_2025_07_08")
        container.loadPersistentStores { _, error in
            if let error = error { fatalError("Core Data failed: \(error)") }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    func fetchWorkouts() async throws -> [WorkoutHistoryDTO] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            let request = NSFetchRequest<Workout>(entityName: "Workout")
            let result = try context.fetch(request)
            return result.map(WorkoutHistoryDTO.init)
        }
    }
    
    func deleteWorkouts(_ ids: [UUID]) async throws -> [UUID] {
        let context = container.newBackgroundContext()
        return try await context.perform {
            try ids
                .map { NSPredicate(format: "id == %@", $0 as CVarArg) }
                .map { predicate -> NSFetchRequest<Workout> in
                    let request = NSFetchRequest<Workout>(entityName: "Workout")
                    request.predicate = predicate
                    return request
                }
                .flatMap { try context.fetch($0) }
                .forEach(context.delete)

            try context.save()
            return ids
        }
    }
    
    func saveWorkout(_ dto: WorkoutDTO) async throws {
        let context = container.newBackgroundContext()
        try await context.perform {
            let workout = Workout(context: context)
            dto.apply(to: workout)
            try context.save()
        }
    }
}

