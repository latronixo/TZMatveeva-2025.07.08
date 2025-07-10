//
//  ProfileViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData

final class ProfileViewModel: ObservableObject {
    @Published var totalDuration: Int = 0
    @Published var totalWorkouts: Int = 0
    
    @Published var avatarData: Data?
    private var avatarKey = "user_avatar"

    private let context: NSManagedObjectContext
    
    @MainActor
    init() {
        self.context = CoreDataStack.shared.context
        loadAvatar()
    }

    private func loadAvatar() {
          avatarData = UserDefaults.standard.data(forKey: avatarKey)
    }
    
    @MainActor
    func saveAvatarData(_ data: Data) {
        avatarData = data
        UserDefaults.standard.set(data, forKey: avatarKey)
    }
    
    @MainActor
    func clearAvatar() {
        avatarData = nil
        UserDefaults.standard.removeObject(forKey: avatarKey)
    }
    
    @MainActor
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

    @MainActor
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
