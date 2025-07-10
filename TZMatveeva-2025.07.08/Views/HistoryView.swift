//
//  HistoryView.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var vm = HistoryViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Поиск", text: $vm.searchText)
                    .padding(.horizontal)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: vm.searchText, perform: { _ in
                        vm.filterWorkouts()
                    })

                List {
                    ForEach(vm.filteredWorkouts, id: \.id) { workout in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(workout.type)
                                .font(.headline)
                            Text("Длительность: \(formatDuration(workout.duration))")
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
                    .onDelete(perform: vm.deleteWorkout)
                }
                .listStyle(.plain)
                .onAppear {
                    vm.fetchWorkouts()
                }
            }
            .navigationTitle("История тренировок")
            .toolbar {
                EditButton() // Позволяет активировать режим удаления
            }
        }
    }

    // Форматирование длительности
    func formatDuration(_ seconds: Int32) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%02d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }

    // Форматирование даты
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    HistoryView()
}
