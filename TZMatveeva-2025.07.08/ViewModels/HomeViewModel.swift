//
//  HomeViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData

final class HomeViewModel: ObservableObject {
    @Published var totalWorkouts = 0
    @Published var totalDuration: Int32 = 0
    @Published var recentWorkouts: [Workout] = []

    private let context = CoreDataStack.shared.context

    var totalDurationFormatted: String {
        formatDuration(totalDuration)
    }

    func formatDuration(_ seconds: Int32) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s)
                     : String(format: "%02d:%02d", m, s)
    }

    func fetchStats() {
        let request = NSFetchRequest<Workout>(entityName: "Workout")
        do {
            let workouts = try context.fetch(request)
            totalWorkouts = workouts.count
            totalDuration = workouts.reduce(0) { $0 + $1.duration }
            recentWorkouts = workouts.sorted { $0.date > $1.date }
        } catch {
            print("❌ Failed to fetch workouts: \(error)")
        }
    }
}
