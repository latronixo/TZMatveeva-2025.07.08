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
            VStack(spacing: AppSpacing.standard) {
                TextField("Поиск", text: $vm.searchText)
                    .padding(.horizontal, AppSpacing.standard)
                    .textFieldStyle(.roundedBorder)
                    .font(AppFonts.body)
                    .background(AppColors.secondaryBackground)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                
                // Фильтр по дням
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.standard) {
                        ForEach(HistoryViewModel.DateFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    vm.selectedDateFilter = filter
                                }
                            }) {
                                Text(filter.displayName)
                                    .font(AppFonts.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, AppSpacing.standard)
                                    .padding(.vertical, AppSpacing.small)
                                    .background(
                                        vm.selectedDateFilter == filter
                                            ? AppColors.primary
                                            : AppColors.textSecondary.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        vm.selectedDateFilter == filter
                                            ? .white
                                            : AppColors.textPrimary
                                    )
                                    .cornerRadius(AppRadius.button)
                            }
                            .scaleEffect(vm.selectedDateFilter == filter ? 1.05 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: vm.selectedDateFilter)
                            .pressEffect()
                        }
                    }
                    .padding(.horizontal, AppSpacing.standard)
                }
                .padding(.vertical, AppSpacing.small)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
                
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
            .background(AppColors.background)
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
