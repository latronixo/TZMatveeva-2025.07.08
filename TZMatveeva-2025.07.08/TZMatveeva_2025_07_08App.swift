//
//  TZMatveeva_2025_07_08App.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

@main
struct SportTimerApp: App {
    @State private var selectedTab = 0
    @StateObject private var settings = AppSettings.shared
    let persistenceController = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tabItem {
                        Label("Home", systemImage: "house")
                    }
                    .tag(0)
                    .transition(.slideFromRight)
                
                TimerView()
                    .tabItem {
                        Label("Timer", systemImage: "timer")
                    }
                    .tag(1)
                    .transition(.slideFromRight)
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(2)
                    .transition(.slideFromRight)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(3)
                    .transition(.slideFromRight)
            }
            .preferredColorScheme(settings.selectedTheme.colorScheme)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selectedTab)
        }
    }
}
