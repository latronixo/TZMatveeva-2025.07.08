//
//  ProfileViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData
import SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var totalDuration: Int = 0
    @Published var totalWorkouts: Int = 0

    let context = CoreDataStack.shared.context

    func fetchStats() {
        let request = NSFetchRequest<Workout>(entityName: "Workout")
        do {
            let workouts = try context.fetch(request)
            totalWorkouts = workouts.count
            totalDuration = workouts.reduce(0) { $0 + Int($1.duration) }
        } catch {
            print("❌ Ошибка получения статистики: \(error)")
        }
    }

    func clearAllData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
            fetchStats()
        } catch {
            print("❌ Ошибка удаления всех данных: \(error)")
        }
    }

    func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        return "Версия \(version) (build \(build))"
    }
}
