//
//  ProfileView.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var vm = ProfileViewModel()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showClearAlert = false
    
    // Локальное состояние colorScheme для управления отображением темы
    @State private var currentColorScheme: ColorScheme? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    avatarSection
                    avatarDeleteButton
                    statsSection
                    settingsSection
                    infoSection
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .preferredColorScheme(currentColorScheme)
            .onAppear {
                vm.fetchStats { count, total in
                    DispatchQueue.main.async {
                        vm.totalWorkouts = count
                        vm.totalDuration = total
                    }
                }
                currentColorScheme = vm.selectedTheme.colorScheme
            }
            .alert("Очистить все данные?", isPresented: $showClearAlert) {
                Button("Удалить", role: .destructive) {
                    vm.clearAllData { count, total in
                        DispatchQueue.main.async {
                            vm.totalWorkouts = count
                            vm.totalDuration = total
                        }
                    }
                }
                Button("Отмена", role: .cancel) {}
            }
            .onChange(of: selectedPhoto) { _, newValue in
                if let item = newValue {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self) {
                            vm.saveAvatarData(data)
                        }
                    }
                }
            }
            .onChange(of: vm.selectedTheme) { newTheme, oldTheme in
                currentColorScheme = newTheme.colorScheme
            }
        }
    }

    private var avatarSection: some View {
        let currentAvatar = vm.avatarData
        return PhotosPicker(selection: $selectedPhoto, matching: .images) {
            if let data = currentAvatar, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary, lineWidth: 2))
                    .shadow(radius: 4)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
            }
        }
    }

    private var avatarDeleteButton: some View {
        Group {
            if vm.avatarData != nil {
                Button(role: .destructive) {
                    vm.clearAvatar()
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Общая статистика")
                .font(.headline)
            Text("Всего тренировок: \(vm.totalWorkouts)")
            Text("Общее время: \(formatDuration(vm.totalDuration))")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Настройки")
                .font(.headline)
            Section {
                Text("Тема")
                Picker("Тема", selection: $vm.selectedTheme) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
                .pickerStyle(.segmented)
            }
            Toggle("Звуки таймера", isOn: $vm.isSoundEnabled)
            Button("Очистить все данные", role: .destructive) {
                showClearAlert = true
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("О приложении")
                .font(.headline)
            Text(vm.appVersion())
            Text("Разработано специально для тестового задания.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0
            ? String(format: "%02d:%02d:%02d", h, m, s)
            : String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    ProfileView()
}
