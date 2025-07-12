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
                
                // Фильтр по дням
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(HistoryViewModel.DateFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                vm.selectedDateFilter = filter
                            }) {
                                Text(filter.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        vm.selectedDateFilter == filter
                                            ? Color.accentColor
                                            : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        vm.selectedDateFilter == filter
                                            ? .white
                                            : .primary
                                    )
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
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
