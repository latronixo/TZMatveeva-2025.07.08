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
        VStack(alignment: .leading, spacing: 6) {
            Text(workout.type)
                .font(.headline)
            Text("Длительность: \(TimeFormatter.formatTime(workout.duration))")
                .font(.subheadline)
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .italic()
            }
            Text("Дата: \(formatDate(workout.date))")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
