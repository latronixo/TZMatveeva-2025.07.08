//
//  HomeView.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm = HomeViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Привет, спортсмен!").font(.title.bold())

                HStack {
                    VStack(alignment: .leading) {
                        Text("Всего тренировок: \(vm.totalWorkouts)")
                        Text("Общее время: \(vm.totalDurationFormatted)")
                    }
                    Spacer()
                }
                
                Button("Начать тренировку") {
                    selectedTab = 1
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)

                Text("Последние тренировки").font(.headline)

                ForEach(vm.recentWorkouts.prefix(3)) { workout in
                    Text("\(workout.type) - \(vm.formatDuration(workout.duration))")
                }

                Spacer()
            }
            .padding()
            .onAppear { vm.fetchStats() }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
