//
//  DesignSystem.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

// MARK: - Цветовая схема
struct AppColors {
    static let primary = Color(hex: "#007AFF")
    static let secondary = Color(hex: "#FF9500")
    static let success = Color(hex: "#34C759")
    static let warning = Color(hex: "#FF9500")
    static let danger = Color(hex: "#FF3B30")
    
    // Адаптивные цвета для светлой и темной темы
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    static let textTertiary = Color(.tertiaryLabel)
    
    static let separator = Color(.separator)
    static let systemGray = Color(.systemGray)
    static let systemGray2 = Color(.systemGray2)
    static let systemGray3 = Color(.systemGray3)
    static let systemGray4 = Color(.systemGray4)
    static let systemGray5 = Color(.systemGray5)
    static let systemGray6 = Color(.systemGray6)
}

// MARK: - Шрифты
struct AppFonts {
    static let title = Font.system(size: 28, weight: .bold)
    static let subtitle = Font.system(size: 20, weight: .semibold)
    static let body = Font.system(size: 16, weight: .regular)
    static let caption = Font.system(size: 14, weight: .regular)
}

// MARK: - Размеры и отступы
struct AppSpacing {
    static let standard: CGFloat = 16
    static let small: CGFloat = 8
    static let large: CGFloat = 24
}

struct AppRadius {
    static let card: CGFloat = 12
    static let button: CGFloat = 8
}

struct AppShadows {
    static let light = Shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Расширение для Color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Модификаторы для компонентов
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.secondaryBackground)
            .cornerRadius(AppRadius.card)
            .shadow(
                color: AppShadows.light.color,
                radius: AppShadows.light.radius,
                x: AppShadows.light.x,
                y: AppShadows.light.y
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.body)
            .foregroundColor(.white)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity)
            .background(AppColors.primary)
            .cornerRadius(AppRadius.button)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.body)
            .foregroundColor(AppColors.primary)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity)
            .background(AppColors.secondaryBackground)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.button)
                    .stroke(AppColors.primary, lineWidth: 1)
            )
            .cornerRadius(AppRadius.button)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct DangerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.body)
            .foregroundColor(.white)
            .frame(minHeight: 44)
            .frame(maxWidth: .infinity)
            .background(AppColors.danger)
            .cornerRadius(AppRadius.button)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
} 