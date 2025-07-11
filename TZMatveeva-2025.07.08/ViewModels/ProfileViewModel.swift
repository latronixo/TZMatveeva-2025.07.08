//
//  ProfileViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData
import Combine
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var totalDuration: Int = 0
    @Published var totalWorkouts: Int = 0

    @Published var avatarData: Data?
    private let avatarKey = "user_avatar"

    @Published var selectedTheme: AppTheme {
        didSet {
            if AppSettings.shared.selectedTheme != selectedTheme {
                AppSettings.shared.selectedTheme = selectedTheme
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()    //подписка
    
    private let context: NSManagedObjectContext
    
    private let soundKey = "timer_sounds_enabled"
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: soundKey)
        }
    }

    init() {
        self.context = CoreDataStack.shared.context
        self.avatarData = UserDefaults.standard.data(forKey: avatarKey)

        // Инициализация темы из AppSettings
        self.selectedTheme = AppSettings.shared.selectedTheme
        
        self.isSoundEnabled = UserDefaults.standard.bool(forKey: soundKey)

        // Подписываемся на изменения темы из AppSettings
        AppSettings.shared.$selectedTheme
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTheme in
                guard let self = self else { return }
                if self.selectedTheme != newTheme {
                    self.selectedTheme = newTheme
                }
            }
            .store(in: &cancellables)
    }

    func saveAvatarData(_ data: Data) {
        avatarData = data
        UserDefaults.standard.set(data, forKey: avatarKey)
    }

    func clearAvatar() {
        avatarData = nil
        UserDefaults.standard.removeObject(forKey: avatarKey)
    }

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
