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
                    .transition(.slideFromTop)

                HStack {
                    VStack(alignment: .leading) {
                        Text("Всего тренировок: \(vm.totalWorkouts)")
                            .transition(.slideFromLeft)
                        Text("Общее время: \(vm.totalDurationFormatted)")
                            .transition(.slideFromLeft)
                    }
                    Spacer()
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.totalWorkouts)
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.totalDurationFormatted)

                // Кнопка перехода к таймеру
                Button("Начать тренировку") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        selectedTab = 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .pressEffect()
                .transition(.scaleFade)

                // Заголовок последних тренировок
                Text("Последние тренировки")
                    .font(.headline)
                    .transition(.slideFromTop)

                // Мини-карточки последних 3 тренировок
                ForEach(vm.recentWorkouts) { workout in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(workout.type)
                                .font(.subheadline.bold())
                            Text("Длительность: \(workout.durationFormatted)")
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
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: vm.recentWorkouts.count)

                Spacer()
            }
            .padding()
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
