//
//  HistoryView.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

struct HistoryView: View {
    @StateObject var vm = HistoryViewModel()

    var body: some View {
        List {
            ForEach(vm.groupedWorkouts.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(vm.formatDate(date))) {
                    ForEach(vm.groupedWorkouts[date] ?? []) { workout in
                        WorkoutCardView(workout: workout)
                            .swipeActions {
                                Button(role: .destructive) {
                                    vm.deleteWorkout(workout)
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
        .searchable(text: $vm.searchText)
        .onAppear { vm.fetchWorkouts() }
    }
}

#Preview {
    HistoryView()
}
