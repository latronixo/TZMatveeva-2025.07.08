//
//  WorkoutType.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation

enum WorkoutType: String, CaseIterable, Identifiable, Hashable {
    var id: String { rawValue }
    case strength = "Силовая тренировка"
    case cardio = "Кардио"
    case yoga = "Йога"
    case stretching = "Растяжка"
    case other = "Другое"
}
