//
//  HistoryViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData

// MARK: — Безопасная структура для передачи в UI
struct WorkoutHistoryDTO: Identifiable {
    let id: UUID
    let type: String
    let duration: Int32
    let date: Date
    let notes: String?
}

final class HistoryViewModel: ObservableObject {
    @Published var workouts: [WorkoutHistoryDTO] = []
    @Published var searchText: String = ""
    @Published var filteredWorkouts: [WorkoutHistoryDTO] = []
    @Published var groupedWorkouts: [String: [WorkoutHistoryDTO]] = [:]

    func fetchWorkouts(completion: @escaping ([WorkoutHistoryDTO]) -> Void) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<Workout>(entityName: "Workout")
            do {
                let result = try context.fetch(request)
                let dtos = result.map { workout in
                    WorkoutHistoryDTO(
                        id: workout.id,
                        type: workout.type,
                        duration: workout.duration,
                        date: workout.date,
                        notes: workout.notes
                    )
                }
                completion(dtos)
            } catch {
                print("❌ Ошибка получения тренировки: \(error)")
                completion([])
            }
        }
    }

    func deleteWorkouts(_ workoutsToDelete: [WorkoutHistoryDTO], completion: @escaping ([WorkoutHistoryDTO]) -> Void) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            for workout in workoutsToDelete {
                let request = NSFetchRequest<Workout>(entityName: "Workout")
                request.predicate = NSPredicate(format: "id == %@", workout.id as CVarArg)
                if let object = try? context.fetch(request).first {
                    context.delete(object)
                }
            }
            do {
                try context.save()
                // После удаления — fetchWorkouts в этом же контексте
                let request = NSFetchRequest<Workout>(entityName: "Workout")
                let result = try context.fetch(request)
                let dtos = result.map { workout in
                    WorkoutHistoryDTO(
                        id: workout.id,
                        type: workout.type,
                        duration: workout.duration,
                        date: workout.date,
                        notes: workout.notes
                    )
                }
                completion(dtos)
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
