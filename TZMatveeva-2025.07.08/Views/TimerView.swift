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
            ScrollView {
                VStack(spacing: AppSpacing.large) {
                    TimeDisplayView(vm: vm)
                    ProgressCircleView(vm: vm)
                    WorkoutSettingsView(vm: vm)
                    ControlButtonsView(vm: vm)
                }
                .padding(.vertical, AppSpacing.standard)
            }
            .background(AppColors.background)
            .navigationTitle("Таймер")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if !vm.isRunning {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                if vm.isEditingTime {
                                    // Сохраняем изменения
                                    vm.remainingSeconds = vm.totalTime
                                }
                                vm.isEditingTime.toggle()
                            }
                        }
                    }) {
                        Image(systemName: vm.isEditingTime ? "checkmark" : "pencil")
                            .foregroundColor(vm.isRunning ? AppColors.textTertiary : AppColors.primary)
                    }
                    .disabled(vm.isRunning)
                }
            }
        }
        .overlay {
            if vm.isLoading {
                LoadingView()
            }
        }
        .onAppear {
            vm.requestNotificationPermission()
        }
    }
}

// MARK: - Time Display View
struct TimeDisplayView: View {
    @ObservedObject var vm: TimerViewModel
    
    var body: some View {
        VStack {
            if vm.isEditingTime {
                TimeEditView(vm: vm)
            } else {
                TimeShowView(vm: vm)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.isEditingTime)
    }
}

// MARK: - Time Edit View
struct TimeEditView: View {
    @ObservedObject var vm: TimerViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            Picker("", selection: vm.timeBindings.hoursBinding) {
                ForEach(0..<24) { hour in
                    Text("\(hour) ч").tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Picker("", selection: vm.timeBindings.minutesBinding) {
                ForEach(0..<60) { minute in
                    Text("\(minute) мин").tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Picker("", selection: vm.timeBindings.secondsBinding) {
                ForEach(0..<60) { second in
                    Text("\(second) сек").tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)
        }
        .frame(height: 150)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
}

// MARK: - Time Show View
struct TimeShowView: View {
    @ObservedObject var vm: TimerViewModel
    
    var body: some View {
        Text(vm.formattedTime)
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .foregroundColor(AppColors.textPrimary)
            .onTapGesture {
                if !vm.isRunning {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        vm.isEditingTime = true
                    }
                }
            }
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
    }
}

// MARK: - Progress Circle View
struct ProgressCircleView: View {
    @ObservedObject var vm: TimerViewModel
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 20)
                .frame(width: 200, height: 200)

            Circle()
                .trim(from: 0, to: vm.progress)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
                .animation(.easeInOut(duration: 0.3), value: vm.progress)
                .scaleEffect(vm.isRunning ? 1.05 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: vm.isRunning)
        }
    }
}

// MARK: - Workout Settings View
struct WorkoutSettingsView: View {
    @ObservedObject var vm: TimerViewModel
    
    var body: some View {
        VStack(spacing: AppSpacing.standard) {
            Picker("Тип тренировки", selection: $vm.workoutType) {
                ForEach(WorkoutType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)
            .font(AppFonts.body)

            TextField("Заметки о тренировке", text: $vm.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .font(AppFonts.body)
                .background(AppColors.secondaryBackground)
        }
        .padding(.horizontal, AppSpacing.standard)
    }
}

// MARK: - Control Buttons View
struct ControlButtonsView: View {
    @ObservedObject var vm: TimerViewModel
    
    var body: some View {
        VStack(spacing: AppSpacing.standard) {
            Group {
                if vm.isRunning {
                    Button("Пауза/Стоп") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            vm.pause()
                        }
                    }
                    .buttonStyle(DangerButtonStyle())
                } else {
                    Button("Старт") {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            vm.start()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .scaleEffect(vm.isRunning ? 1.2 : 1)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: vm.isRunning)
            .pressEffect()

            HStack(spacing: AppSpacing.standard) {
                Button("Сброс") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        vm.reset()
                    }
                }
                .buttonStyle(SecondaryButtonStyle(isDisabled: vm.resetDisabled))
                .disabled(vm.resetDisabled)
                .pressEffect()
                
                Button("Сохранить") {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        vm.saveWorkout()
                    }
                }
                .buttonStyle(PrimaryButtonStyle(isDisabled: vm.saveDisabled))
                .disabled(vm.saveDisabled)
                .pressEffect()
            }
        }
        .padding(.horizontal, AppSpacing.standard)
    }
}

#Preview {
    TimerView()
}
