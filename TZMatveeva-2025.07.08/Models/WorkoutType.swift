//
//  WorkoutType.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation

enum WorkoutType: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case strength = "Strength"
    case cardio = "Cardio"
    case yoga = "Yoga"
    case stretching = "Stretching"
    case other = "Other"
}
