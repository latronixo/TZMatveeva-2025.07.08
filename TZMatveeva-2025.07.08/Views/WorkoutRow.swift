//
//  WorkoutRow.swift
//  TZMatveeva-2025.07.08
//
//  Created by Илья Шаповалов on 11.07.2025.
//

import SwiftUI

struct WorkoutRow: View {
    let workout: WorkoutHistoryDTO
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.small) {
            Text(workout.type)
                .font(AppFonts.subtitle)
                .foregroundColor(AppColors.textPrimary)
            Text("Длительность: \(TimeFormatter.formatTime(workout.duration))")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(AppFonts.body)
                    .italic()
                    .foregroundColor(AppColors.textSecondary)
            }
            Text("Дата: \(formatDate(workout.date))")
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding(AppSpacing.standard)
        .background(AppColors.secondaryBackground)
        .cornerRadius(AppRadius.card)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: workout.id)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
