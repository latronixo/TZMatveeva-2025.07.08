//
//  HistoryViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData

final class HistoryViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var searchText: String = ""
    @Published var filteredWorkouts: [Workout] = []
    @Published var groupedWorkouts: [String: [Workout]] = [:]

    func fetchWorkouts(completion: @escaping ([Workout]) -> Void) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<Workout>(entityName: "Workout")
            do {
                let result = try context.fetch(request)
                completion(result)
            } catch {
                print("❌ Ошибка получения тренировки: \(error)")
                completion([])
            }
        }
    }

    func deleteWorkouts(_ workoutsToDelete: [Workout], completion: @escaping ([Workout]) -> Void) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            for workout in workoutsToDelete {
                let objectID = workout.objectID
                if let object = try? context.existingObject(with: objectID) {
                    context.delete(object)
                }
            }
            do {
                try context.save()
                // После удаления — fetchWorkouts в этом же контексте
                let request = NSFetchRequest<Workout>(entityName: "Workout")
                let result = try context.fetch(request)
                completion(result)
            } catch {
                print("❌ Ошибка удаления тренировки: \(error)")
                completion([])
            }
        }
    }

    func filterWorkouts() {
        let base = searchText.isEmpty
            ? workouts
            : workouts.filter {
                $0.type.lowercased().contains(searchText.lowercased()) ||
                $0.notes?.lowercased().contains(searchText.lowercased()) == true
            }

        filteredWorkouts = base

        // Группировка по дате (формат: yyyy-MM-dd)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        groupedWorkouts = Dictionary(grouping: base) { workout in
            formatter.string(from: workout.date)
        }
    }
}
