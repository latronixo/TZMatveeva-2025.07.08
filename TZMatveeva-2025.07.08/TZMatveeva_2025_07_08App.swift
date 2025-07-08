//
//  TZMatveeva_2025_07_08App.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

@main
struct SportTimerApp: App {
    let persistenceController = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                TimerView()
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }
                HistoryView() 
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
            }
        }
    }
}
