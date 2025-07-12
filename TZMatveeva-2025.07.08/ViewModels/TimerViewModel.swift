//
//  TimerViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import AVFoundation
import UserNotifications
import SwiftUI

// MARK: - Структура для управления временем
struct TimeBindings {
    let totalTime: Binding<Int>
    let remainingSeconds: Binding<Int>
    
    var hoursBinding: Binding<Int> {
        Binding(
            get: { totalTime.wrappedValue / 3600 },
            set: { newHours in
                let minutes = (totalTime.wrappedValue % 3600) / 60
                let seconds = totalTime.wrappedValue % 60
                totalTime.wrappedValue = newHours * 3600 + minutes * 60 + seconds
                remainingSeconds.wrappedValue = totalTime.wrappedValue
            }
        )
    }
    
    var minutesBinding: Binding<Int> {
        Binding(
            get: { (totalTime.wrappedValue % 3600) / 60 },
            set: { newMinutes in
                let hours = totalTime.wrappedValue / 3600
                let seconds = totalTime.wrappedValue % 60
                totalTime.wrappedValue = hours * 3600 + newMinutes * 60 + seconds
                remainingSeconds.wrappedValue = totalTime.wrappedValue
            }
        )
    }
    
    var secondsBinding: Binding<Int> {
        Binding(
            get: { totalTime.wrappedValue % 60 },
            set: { newSeconds in
                let hours = totalTime.wrappedValue / 3600
                let minutes = (totalTime.wrappedValue % 3600) / 60
                totalTime.wrappedValue = hours * 3600 + minutes * 60 + newSeconds
                remainingSeconds.wrappedValue = totalTime.wrappedValue
            }
        )
    }
}

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var totalTime: Int {
        didSet {
            UserDefaults.standard.set(totalTime, forKey: "totalTime")
        }
    }
    @Published var remainingSeconds: Int
    
    @Published var workoutType: WorkoutType = .strength
    @Published var notes: String = ""
    @Published var isEditingTime = false
    @Published var isLoading = false

    private var timer: Timer?
    var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    init() {
        let saved = UserDefaults.standard.integer(forKey: "totalTime")
        let totalTime = saved > 0 ? saved : 300 // по умолчанию 5 минут
        self.totalTime = totalTime
        self.remainingSeconds = totalTime
    }

    func requestNotificationPermission() {
        Task.detached {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()

            guard settings.authorizationStatus == .notDetermined else {
                return
            }

            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound])
                print("🔔 Уведомления разрешены: \(granted)")
            } catch {
                print("❌ Ошибка разрешения уведомлений: \(error)")
            }
        }
    }

    func start() {
        guard remainingSeconds > 0 else { return }

        isRunning = true
        isEditingTime = false
        playSound(id: 1016)

        // Запускаем background task на ограниченное время
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            Task { @MainActor in
                self.endBackgroundTask()
            }
        }

        // Удаляем старые уведомления, ставим новое на оставшееся время
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["WorkoutEndNotification"])

        let content = UNMutableNotificationContent()
        content.title = "Тренировка завершена"
        content.body = "Время вышло."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(remainingSeconds), repeats: false)
        let request = UNNotificationRequest(identifier: "WorkoutEndNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)

        // Запускаем таймер для обновления UI
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                } else {
                    self.timer?.invalidate()
                    self.isRunning = false
                    self.playSound(id: 1005)
                    self.endBackgroundTask()
                }
            }
        }
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        playSound(id: 1007)
        sendNotification(title: "Тренировка приостановлена", body: "Вы приостановили тренировку.")
        timer?.invalidate()
        endBackgroundTask()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["WorkoutEndNotification"])
    }

    func reset() {
        if isRunning {
            playSound(id: 1007)
            isRunning = false
        }

        sendNotification(title: "Тренировка завершена", body: "Тренировка завершена и сохранена.")
        remainingSeconds = totalTime
        workoutType = .strength
        notes = ""
        timer?.invalidate()
        endBackgroundTask()
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["WorkoutEndNotification"])
    }

    func saveWorkout() {
        isRunning = false
        isLoading = true

        Task { @MainActor in
            let workout = WorkoutDTO(
                type: workoutType.rawValue,
                duration: Int32(totalTime - remainingSeconds),
                notes: notes
            )
            try await CoreDataStack.shared.saveWorkout(workout)
            self.reset()
            self.endBackgroundTask()
            self.isLoading = false
        }
    }

    func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    var formattedTime: String {
        TimeFormatter.formatTime(Int32(remainingSeconds))
    }

    var progress: Double {
        totalTime > 0 ? Double(totalTime - remainingSeconds) / Double(totalTime) : 0
    }
    
    var resetDisabled: Bool {
        isRunning == false && notes == "" && remainingSeconds == totalTime
    }
    
    var saveDisabled: Bool {
        isRunning || totalTime == 0 || remainingSeconds == totalTime
    }
    
    // MARK: - Time Bindings
    var timeBindings: TimeBindings {
        TimeBindings(
            totalTime: Binding(
                get: { self.totalTime },
                set: { self.totalTime = $0 }
            ),
            remainingSeconds: Binding(
                get: { self.remainingSeconds },
                set: { self.remainingSeconds = $0 }
            )
        )
    }

    private func playSound(id: SystemSoundID) {
        let isEnabled = UserDefaults.standard.bool(forKey: "timer_sounds_enabled")
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(id)
    }

    func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskID)
            backgroundTaskID = .invalid
        }
    }
}
