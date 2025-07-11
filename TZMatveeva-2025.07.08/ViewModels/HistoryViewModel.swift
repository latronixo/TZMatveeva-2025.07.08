//
//  HistoryViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var searchText: String = ""
    @Published var filteredWorkouts: [Workout] = []
    @Published var groupedWorkouts: [String: [Workout]] = [:]

    private let context = CoreDataStack.shared.context

    func fetchWorkouts() {
        let request = NSFetchRequest<Workout>(entityName: "Workout")
        do {
            workouts = try context.fetch(request)
            filterWorkouts()
        } catch {
            print("❌ Ошибка получения тренировки: \(error)")
        }
    }

    func deleteWorkouts(_ workoutsToDelete: [Workout]) {
        for workout in workoutsToDelete {
            context.delete(workout)
        }
        do {
            try context.save()
            fetchWorkouts()
        } catch {
            print("❌ Ошибка удаления тренировки: \(error)")
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
