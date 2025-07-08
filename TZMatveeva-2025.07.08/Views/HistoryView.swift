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
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: vm.searchText, perform: vm.filterWorkouts)

                List {
                    ForEach(vm.filteredWorkouts, id: \.id) { workout in
                        VStack(alignment: .leading) {
                            Text(workout.type).font(.headline)
                            Text("Длительность: \(formatDuration(workout.duration))")
                                .font(.subheadline)
                            if let notes = workout.notes {
                                Text(notes).font(.subheadline).italic()
                            }
                            Text("Дата: \(formatDate(workout.date))").font(.footnote)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                vm.deleteWorkout(at: IndexSet([vm.filteredWorkouts.firstIndex(where: { $0.id == workout.id })!]))
                            } label: {
                                Label("Удалить", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { offsets in
                        vm.deleteWorkout(at: offsets)
                    }
                }
                .listStyle(.plain)
                .onAppear {
                    vm.fetchWorkouts()
                }
            }
            .navigationTitle("История тренировок")
        }
    }

    func formatDuration(_ seconds: Int32) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s)
                     : String(format: "%02d:%02d", m, s)
    }

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
