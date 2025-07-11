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
                WrkoutsList(
                    dates: vm.dates,
                    groupedWorkouts: vm.workouts,
                    deleteWorkouts: { vm.deleteWorkouts(for: $0, at: $1) }
                )
                .equatable()
                .task {
                    await vm.fetchWorkouts()
                }
            }
            .navigationTitle("История тренировок")
            .toolbar {
                EditButton()
            }
        }
    }
}

#Preview {
    HistoryView()
}
