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
            VStack(alignment: .leading, spacing: 16) {
                // Приветствие и статистика
                Text("Привет, спортсмен!")
                    .font(.title.bold())

                HStack {
                    VStack(alignment: .leading) {
                        Text("Всего тренировок: \(vm.totalWorkouts)")
                        Text("Общее время: \(vm.totalDurationFormatted)")
                    }
                    Spacer()
                }

                // Кнопка перехода к таймеру
                Button("Начать тренировку") {
                    selectedTab = 1
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)

                // Заголовок последних тренировок
                Text("Последние тренировки")
                    .font(.headline)

                // Мини-карточки последних 3 тренировок
                ForEach(vm.recentWorkouts) { workout in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(workout.type)
                                .font(.subheadline.bold())
                            Text("Длительность: \(formatDuration(workout.duration))")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(workout.date, format: .dateTime.month().day().year())
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }

                Spacer()
            }
            .padding()
            .onAppear {
                vm.fetchStats { totalCount, totalDuration, latestWorkouts in
                    DispatchQueue.main.async {
                        vm.totalWorkouts = totalCount
                        vm.totalDuration = totalDuration
                        vm.recentWorkouts = latestWorkouts
                    }
                }
            }
        }
    }
}

// Помогайка для форматирования длительности внутри View
private extension HomeView {
    func formatDuration(_ seconds: Int32) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%02d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
