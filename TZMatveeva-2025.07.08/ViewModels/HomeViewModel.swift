//
//  HomeViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData

// MARK: — Безопасная структура для передачи в UI
struct WorkoutDTO: Identifiable {
    let id: UUID
    let type: String
    let duration: Int32
    let date: Date
}

final class HomeViewModel: ObservableObject {
    @Published var totalWorkouts = 0
    @Published var totalDuration: Int32 = 0
    @Published var recentWorkouts: [WorkoutDTO] = []

    /// Человекочитаемое форматирование длительности
    var totalDurationFormatted: String {
        let seconds = totalDuration
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%02d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }

    /// Асинхронный fetch статистики из Core Data
    func fetchStats(completion: @escaping (Int, Int32, [WorkoutDTO]) -> Void) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<Workout>(entityName: "Workout")
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            do {
                let fetched = try context.fetch(request)
                let dtos = fetched.map { workout in
                    WorkoutDTO(
                        id: workout.id,
                        type: workout.type,
                        duration: workout.duration,
                        date: workout.date
                    )
                }
                let total = dtos.reduce(0) { $0 + $1.duration }
                let latest = Array(dtos.prefix(3))
                let totalCount = dtos.count
                let totalDuration = total
                let latestWorkouts = latest
                completion(totalCount, totalDuration, latestWorkouts)
            } catch {
                print("❌ Failed to fetch workouts: \(error)")
            }
        }
    }
}
