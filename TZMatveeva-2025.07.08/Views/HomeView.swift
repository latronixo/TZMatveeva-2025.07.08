//
//  HomeView.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.large) {
                    VStack(alignment: .leading, spacing: AppSpacing.standard) {
                        Text("Привет, спортсмен!")
                            .font(AppFonts.title)
                            .foregroundColor(AppColors.textPrimary)
                            .transition(.slideFromTop)
                            .padding(.horizontal, AppSpacing.standard)

                        HStack {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                Text("Всего тренировок: \(vm.totalWorkouts)")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                                    .transition(.slideFromLeft)
                                Text("Общее время: \(vm.totalDurationFormatted)")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                    .transition(.slideFromLeft)
                            }
                            .padding(.horizontal, AppSpacing.standard)
                            
                            Spacer()
                        }
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.totalWorkouts)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.totalDurationFormatted)
                    }
                    .padding(.horizontal, AppSpacing.standard)

                    // Кнопка перехода к таймеру
                    Button("Начать тренировку") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            selectedTab = 1
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, AppSpacing.standard)
                    .pressEffect()
                    .transition(.scaleFade)

                    Text("Последние тренировки")
                        .font(AppFonts.subtitle)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(.horizontal, AppSpacing.standard)
                        .transition(.slideFromTop)

                    // Мини-карточки последних 3 тренировок
                    VStack(spacing: AppSpacing.standard) {
                        ForEach(vm.recentWorkouts) { workout in
                            HStack {
                                VStack(alignment: .leading, spacing: AppSpacing.small) {
                                    Text(workout.type)
                                        .font(AppFonts.body)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text("Длительность: \(workout.durationFormatted)")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                Spacer()
                                Text(workout.formattedDate)
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(AppSpacing.standard)
                            .background(AppColors.tertiaryBackground)
                            .cornerRadius(AppRadius.card)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .scale.combined(with: .opacity)
                            ))
                        }
                    }
                    .padding(.horizontal, AppSpacing.standard)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: vm.recentWorkouts.count)
                }
                .padding(.vertical, AppSpacing.standard)
            }
            .background(AppColors.background)
            .onAppear {
                vm.fetchStats { totalCount, totalDuration, latestWorkouts in
                    DispatchQueue.main.async {
                        vm.totalWorkouts = totalCount
                        vm.totalDuration = Int32(totalDuration)
                        vm.recentWorkouts = latestWorkouts
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
