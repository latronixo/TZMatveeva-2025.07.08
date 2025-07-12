//
//  WrkoutsList.swift
//  TZMatveeva-2025.07.08
//
//  Created by Илья Шаповалов on 12.07.2025.
//

import SwiftUI

struct WrkoutsList: View, @preconcurrency Equatable {
    let dates: [String]
    let groupedWorkouts: [String: [WorkoutHistoryDTO]]
    let deleteWorkouts: (String, IndexSet) -> Void
    
    var body: some View {
        List {
            ForEach(dates, id: \.self) { date in
                Section(header: Text(date)) {
                    ForEach(
                        groupedWorkouts[date] ?? [],
                        id: \.id,
                        content: WorkoutRow.init
                    )
                    .onDelete { indexSet in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            deleteWorkouts(date, indexSet)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: dates)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: groupedWorkouts)
    }
    
    static func == (lhs: WrkoutsList, rhs: WrkoutsList) -> Bool {
        lhs.dates == rhs.dates && lhs.groupedWorkouts == rhs.groupedWorkouts
    }
}

#Preview {
    WrkoutsList(
        dates: [],
        groupedWorkouts: [:],
        deleteWorkouts: { _,_ in }
    )
}
