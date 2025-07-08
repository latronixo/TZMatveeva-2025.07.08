//
//  TimerViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import SwiftUI

final class TimerViewModel: ObservableObject {
    @Published var isRunning = false
    @Published var elapsedSeconds: Int = 0
    @Published var workoutType: WorkoutType = .strength
    @Published var notes: String = ""

    private var timer: Timer?
    private let context = CoreDataStack.shared.context

    func start() {
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.elapsedSeconds += 1
        }
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
    }

    func reset() {
        pause()
        elapsedSeconds = 0
        workoutType = .strength
        notes = ""
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
