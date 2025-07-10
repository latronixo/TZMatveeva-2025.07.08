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
                VStack {
                    if vm.isEditingTime {
                        HStack(spacing: 16) {
                            HStack(spacing: 0) {
                                Picker("", selection: Binding(
                                    get: { vm.totalTime / 3600 },
                                    set: {
                                        let minutes = (vm.totalTime % 3600) / 60
                                        let seconds = vm.totalTime % 60
                                        vm.totalTime = $0 * 3600 + minutes * 60 + seconds
                                        vm.remainingSeconds = vm.totalTime
                                    })) {
                                    ForEach(0..<24) { hour in
                                        Text("\(hour) ч").tag(hour)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80)

                                Picker("", selection: Binding(
                                    get: { (vm.totalTime % 3600) / 60 },
                                    set: {
                                        let hours = vm.totalTime / 3600
                                        let seconds = vm.totalTime % 60
                                        vm.totalTime = hours * 3600 + $0 * 60 + seconds
                                        vm.remainingSeconds = vm.totalTime
                                    })) {
                                    ForEach(0..<60) { minute in
                                        Text("\(minute) мин").tag(minute)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80)

                                Picker("", selection: Binding(
                                    get: { vm.totalTime % 60 },
                                    set: {
                                        let hours = vm.totalTime / 3600
                                        let minutes = (vm.totalTime % 3600) / 60
                                        vm.totalTime = hours * 3600 + minutes * 60 + $0
                                        vm.remainingSeconds = vm.totalTime
                                    })) {
                                    ForEach(0..<60) { second in
                                        Text("\(second) сек").tag(second)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80)
                            }
                            .frame(height: 150)

                            Button("OK") {
                                withAnimation {
                                    vm.isEditingTime = false
                                    vm.remainingSeconds = vm.totalTime
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                        }
                    } else {
                        Text(vm.formattedTime)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .onTapGesture {
                                if !vm.isRunning {
                                    vm.isEditingTime = true
                                }
                            }
                    }
                }


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

                TextField("Заметки о тренировке", text: $vm.notes, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                HStack(spacing: 16) {
                    Button(vm.isRunning ? "Пауза" : "Старт") {
                        withAnimation {
                            vm.isRunning ? vm.pause() : vm.start()
                        }
                    }
                    .scaleEffect(vm.isRunning ? 1.2 : 1)
                    .animation(.spring(), value: vm.isRunning)
                    .buttonStyle(.borderedProminent)
                    .tint(vm.isRunning ? .orange : .green)

                    Button("Сброс") {
                        vm.reset()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(vm.resetDisabled)

                    Button("Сохранить") {
                        vm.saveWorkout()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                    .disabled(vm.saveDisabled)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Таймер")
        }
        .onAppear {
            vm.requestNotificationPermission()
        }
    }
}

#Preview {
    TimerView()
}
