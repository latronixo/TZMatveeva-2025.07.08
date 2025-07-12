//
//  ProfileViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import CoreData
import Combine
import SwiftUI

final class ProfileViewModel: ObservableObject {
    @Published var totalDuration: Int = 0
    @Published var totalWorkouts: Int = 0

    @Published var avatarData: Data?
    private let avatarKey = "user_avatar"
    private let soundKey = "timer_sounds_enabled"
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: soundKey)
        }
    }

    @Published var selectedTheme: AppTheme {
        didSet {
            let selectedScheme = selectedTheme
                if AppSettings.shared.selectedTheme != selectedScheme {
                    DispatchQueue.main.async {
                         AppSettings.shared.selectedTheme = selectedScheme
                     }
                }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()    //подписка
    
    init() {
        self.avatarData = UserDefaults.standard.data(forKey: avatarKey)
        self.isSoundEnabled = UserDefaults.standard.bool(forKey: soundKey)
        self.selectedTheme = AppSettings.shared.selectedTheme
    }

    func saveAvatarData(_ data: Data) {
        avatarData = data
        UserDefaults.standard.set(data, forKey: avatarKey)
    }

    func clearAvatar() {
        avatarData = nil
        UserDefaults.standard.removeObject(forKey: avatarKey)
    }

    func fetchStats(completion: @escaping (Int, Int) -> Void) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<Workout>(entityName: "Workout")
            do {
                let workouts = try context.fetch(request)
                let count = workouts.count
                let total = workouts.reduce(0) { $0 + Int($1.duration) }
                completion(count, total)
            } catch {
                print("❌ Ошибка получения статистики: \(error)")
                completion(0, 0)
            }
        }
    }

    func clearAllData(completion: @escaping (Int, Int) -> Void) {
        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
                try context.save()
                // После удаления — fetch статистики в этом же контексте
                let request = NSFetchRequest<Workout>(entityName: "Workout")
                let workouts = try context.fetch(request)
                let count = workouts.count
                let total = workouts.reduce(0) { $0 + Int($1.duration) }
                completion(count, total)
            } catch {
                print("❌ Ошибка удаления всех данных: \(error)")
                completion(0, 0)
            }
        }
    }

    func appVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
        return "Версия \(version) (build \(build))"
    }
}


enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Тёмная"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
