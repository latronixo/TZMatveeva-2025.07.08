//
//  TimeFormatter.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import Foundation

struct TimeFormatter {
    static func formatTime(_ seconds: Int32) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad

        if seconds >= 3600 {
            formatter.allowedUnits = [.hour, .minute, .second]
        } else {
            formatter.allowedUnits = [.minute, .second]
        }
        formatter.unitsStyle = .positional
        return formatter.string(from: TimeInterval(seconds)) ?? "00:00"
    }
} 
