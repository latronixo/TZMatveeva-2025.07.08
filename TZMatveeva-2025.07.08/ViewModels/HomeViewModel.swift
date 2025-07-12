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
    let duration: Int
    let date: Date
    let notes: String?
    
    var durationFormatted: String {
        TimeFormatter.formatTime(duration)
    }

    init(
        id: UUID = .init(),
        type: String,
        duration: Int,
        date: Date = .now,
        notes: String?
    ) {
        self.id = id
        self.type = type
        self.duration = duration
        self.date = date
        self.notes = notes
    }
    
    func apply(to workout: Workout) {
        workout.id = id
        workout.date = date
        workout.duration = duration
        workout.type = type
        workout.notes = notes
    }
}

final class HomeViewModel: ObservableObject {
    @Published var totalWorkouts = 0
    @Published var totalDuration: Int = 0
    @Published var recentWorkouts: [WorkoutDTO] = []

    // Человекочитаемое форматирование длительности
    var totalDurationFormatted: String {
        TimeFormatter.formatTime(totalDuration)
    }

    // Асинхронный fetch статистики из Core Data
    func fetchStats(completion: @escaping (Int, Int, [WorkoutDTO]) -> Void) {
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
                        date: workout.date,
                        notes: workout.notes
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
