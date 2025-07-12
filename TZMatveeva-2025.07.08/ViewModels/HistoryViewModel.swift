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
    let duration: Int
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
    @Published var workouts: [String: [WorkoutHistoryDTO]] = [:]
    
    var dates: [String] { workouts.keys.sorted(by: >) }
    
    private var cancellables: Set<AnyCancellable> = []
    private let coreData: CoreDataStack
    
    init(coreData: CoreDataStack = .shared) {
        self.coreData = coreData
        
        $searchText
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                filterWorkouts(workouts.values.flatMap(\.self))
            }
            .store(in: &cancellables)
    }

    @MainActor
    func fetchWorkouts() async {
        do {
            let workouts = try await coreData.fetchWorkouts()
            self.filterWorkouts(workouts)
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
            let indexToDelete = try await coreData
                .deleteWorkouts(toDelete.map(\.id))
                .compactMap { id in
                    workouts[date]?.firstIndex{ $0.id == id }
                }
                
            let set = IndexSet(indexToDelete)
            workouts[date]?.remove(atOffsets: set)
            filterWorkouts(workouts.values.flatMap(\.self))
        }
    }

    func filterWorkouts(_ workouts: [WorkoutHistoryDTO]) {
        let base = searchText.isEmpty
            ? workouts
            : workouts.filter {
                $0.type.lowercased().contains(searchText.lowercased()) ||
                $0.notes?.lowercased().contains(searchText.lowercased()) == true
            }

        // Группировка по дате (формат: yyyy-MM-dd)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.workouts = Dictionary(grouping: base) { workout in
            formatter.string(from: workout.date)
        }
    }
}
