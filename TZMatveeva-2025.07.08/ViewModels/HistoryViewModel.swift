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

    private let context = CoreDataStack.shared.context

    func fetchWorkouts() {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        do {
            workouts = try context.fetch(request)
            filterWorkouts()
        } catch {
            print("❌ Ошибка получения тренировок: \(error)")
        }
    }

    func deleteWorkout(at offsets: IndexSet) {
        offsets.forEach { index in
            let workout = workouts[index]
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
        if searchText.isEmpty {
            filteredWorkouts = workouts
        } else {
            filteredWorkouts = workouts.filter {
                ($0.type.lowercased().contains(searchText.lowercased()) ||
                $0.notes?.lowercased().contains(searchText.lowercased()) == true)
            }
        }
    }
}
