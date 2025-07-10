//
//  TimerViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import UserNotifications
import UIKit

@MainActor
final class TimerViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedSeconds: Int = 0
    @Published var workoutType: WorkoutType = .strength
    @Published var notes: String = ""
    
    private var timer: Timer?
    private let context = CoreDataStack.shared.context
    var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid

    init() {
        requestNotificationPermission()
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("❌ Ошибка разрешения уведомлений: \(error)")
            }
        }
    }

    func start() {
        isRunning = true
        
        backgroundTaskID = UIApplication.shared.beginBackgroundTask {
            Task { @MainActor in
                self.endBackgroundTask()
            }
        }

        sendNotification(title: "Тренировка началась", body: "Ваш таймер для тренировки начался.")
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.elapsedSeconds += 1
            }
         }
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
    
    func pause() {
        isRunning = false
        sendNotification(title: "Тренировка приостановлена", body: "Вы приостановили тренировку.")
        timer?.invalidate()
    }

    func reset() {
        sendNotification(title: "Тренировка завершена", body: "Тренировка завершена и сохранена.")
        isRunning = false
        elapsedSeconds = 0
        workoutType = .strength
        notes = ""
        timer?.invalidate()
    }

    func saveWorkout() {
        let workout = Workout(context: context)
        workout.id = UUID()
        workout.date = Date()
        workout.duration = Int32(elapsedSeconds)
        workout.type = workoutType.rawValue
        workout.notes = notes

        do {
            try context.save()
            print("✅ Тренировка сохранена")
        } catch {
            print("❌ Ошибка сохранения: \(error)")
        }

        reset()
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
        let h = elapsedSeconds / 3600
        let m = (elapsedSeconds % 3600) / 60
        let s = elapsedSeconds % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s)
                     : String(format: "%02d:%02d", m, s)
    }

    var progress: Double {
        min(Double(elapsedSeconds % 60) / 60.0, 1.0)
    }
}
