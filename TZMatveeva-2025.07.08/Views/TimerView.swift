//
//  TimerView.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

struct TimerView: View {
    @StateObject private var vm = TimerViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(vm.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)

                    Circle()
                        .trim(from: 0, to: vm.progress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 200, height: 200)
                        .animation(.easeInOut(duration: 0.2), value: vm.progress)
                }

                Picker("Тип тренировки", selection: $vm.workoutType) {
                    ForEach(WorkoutType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.menu)

                TextField("Заметки о тренировке", text: $vm.notes)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Button(vm.isRunning ? "Пауза" : "Старт") {
                        vm.isRunning ? vm.pause() : vm.start()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(vm.isRunning ? .orange : .green)

                    Button("Сброс") {
                        vm.reset()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)

                    Button("Сохранить") {
                        vm.saveWorkout()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Таймер")
        }
    }
}

#Preview {
    TimerView()
}
