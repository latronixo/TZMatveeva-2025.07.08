//
//  AppSettings.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 11.07.2025.
//

import SwiftUI
import Combine

final class AppSettings: ObservableObject, @unchecked Sendable {
    static let shared = AppSettings()

    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: Self.themeKey)
        }
    }

    private static let themeKey = "app_theme"

    private init() {
        let saved = UserDefaults.standard.string(forKey: Self.themeKey)
        self.selectedTheme = AppTheme(rawValue: saved ?? "") ?? .system
    }
}

// Пример безопасного использования:
// Для чтения:
// let theme = AppSettings.shared.selectedTheme // можно из любого потока
//
// Для записи (только на главном потоке!):
// DispatchQueue.main.async {
//     AppSettings.shared.selectedTheme = .dark
// }
// или
// Task { @MainActor in
//     AppSettings.shared.selectedTheme = .dark
// }
