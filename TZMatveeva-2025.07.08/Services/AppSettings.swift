//
//  AppSettings.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 11.07.2025.
//

import SwiftUI
import Combine

@MainActor
final class AppSettings: ObservableObject {
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
