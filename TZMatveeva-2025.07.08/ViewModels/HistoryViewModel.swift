//
//  HistoryViewModel.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation
import CoreData
import Combine

// MARK: — Безопасная структура для передачи в UI
struct WorkoutHistoryDTO: Identifiable, Equatable {
    let id: UUID
    let type: String
    let duration: Int32
    let date: Date
    let notes: String?
    
    init(workout: Workout) {
        self.id = workout.id
        self.type = workout.type
        self.duration = workout.duration
        self.date = workout.date
        self.notes = workout.notes
    }
}

final class HistoryViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var selectedDateFilter: DateFilter = .all
    @Published var workouts: [String: [WorkoutHistoryDTO]] = [:]
    
    var dates: [String] { workouts.keys.sorted(by: >) }
    
    // Храним все тренировки для фильтрации
    private var allWorkouts: [WorkoutHistoryDTO] = []
    
    enum DateFilter: String, CaseIterable {
        case all = "Все"
        case today = "Сегодня"
        case yesterday = "Вчера"
        case week = "Неделя"
        case month = "Месяц"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private let coreData: CoreDataStack
    
    init(coreData: CoreDataStack = .shared) {
        self.coreData = coreData
        
        $searchText
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                filterWorkouts()
            }
            .store(in: &cancellables)
        
        $selectedDateFilter
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                filterWorkouts()
            }
            .store(in: &cancellables)
    }

    @MainActor
    func fetchWorkouts() async {
        do {
            let workouts = try await coreData.fetchWorkouts()
            self.allWorkouts = workouts
            self.filterWorkouts()
        } catch {
           // Handle error
        }
    }
    
    @MainActor
    func deleteWorkouts(for date: String, at indexes: IndexSet) {
        guard let items = workouts[date] else {
            return
        }
        let toDelete = indexes
            .filter(items.indices.contains(_:))
            .map { items[$0] }
        if toDelete.isEmpty {
            return
        }
        Task { @MainActor in
            try await coreData.deleteWorkouts(toDelete.map(\.id))
            
            // Удаляем из allWorkouts
            allWorkouts.removeAll { workout in
                toDelete.contains { $0.id == workout.id }
            }
            
            // Переприменяем фильтры
            filterWorkouts()
        }
    }

    func filterWorkouts() {
        let calendar = Calendar.current
        let now = Date()
        
        // Фильтрация по дате
        let dateFiltered = allWorkouts.filter { workout in
            switch selectedDateFilter {
            case .all:
                return true
            case .today:
                return calendar.isDate(workout.date, inSameDayAs: now)
            case .yesterday:
                let yesterday = calendar.date(byAdding: .day, value: -1, to: now) ?? now
                return calendar.isDate(workout.date, inSameDayAs: yesterday)
            case .week:
                let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
                return workout.date >= weekAgo
            case .month:
                let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
                return workout.date >= monthAgo
            }
        }
        
        // Фильтрация по поиску
        let base = searchText.isEmpty
            ? dateFiltered
            : dateFiltered.filter {
                $0.type.lowercased().contains(searchText.lowercased()) ||
                $0.notes?.lowercased().contains(searchText.lowercased()) == true
            }

        // Группировка по дате (формат: yyyy-MM-dd)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        self.workouts = Dictionary(grouping: base) { workout in
            formatter.string(from: workout.date)
        }
    }
}
