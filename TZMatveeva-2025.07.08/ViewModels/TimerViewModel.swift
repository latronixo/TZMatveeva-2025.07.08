//
//  TimerViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import AVFoundation
import UserNotifications
import SwiftUI

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

        let totalTimeCopy = totalTime
        let remainingSecondsCopy = remainingSeconds
        let workoutTypeCopy = workoutType
        let notesCopy = notes

        let context = CoreDataStack.shared.container.newBackgroundContext()
        context.perform {
            let workout = Workout(context: context)
            workout.id = UUID()
            workout.date = Date()
            workout.duration = Int32(totalTimeCopy - remainingSecondsCopy)
            workout.type = workoutTypeCopy.rawValue
            workout.notes = notesCopy

            do {
                try context.save()
            } catch {
                print("❌ Ошибка сохранения: \(error)")
            }

            Task { @MainActor in
                self.reset()
                self.endBackgroundTask()
            }
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
        let h = remainingSeconds / 3600
        let m = (remainingSeconds % 3600) / 60
        let s = remainingSeconds % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s)
                     : String(format: "%02d:%02d", m, s)
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
