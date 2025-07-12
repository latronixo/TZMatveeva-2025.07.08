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
                        vm.totalDuration = Int32(total)
                    }
                }
                currentColorScheme = vm.selectedTheme.colorScheme
            }
            .alert("Очистить все данные?", isPresented: $showClearAlert) {
                Button("Удалить", role: .destructive) {
                    vm.clearAllData { count, total in
                        DispatchQueue.main.async {
                            vm.totalWorkouts = count
                            vm.totalDuration = Int32(total)
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
        let hasAvatar = currentAvatar != nil
        return PhotosPicker(selection: $selectedPhoto, matching: .images) {
            if let data = currentAvatar, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.primary, lineWidth: 2))
                    .shadow(radius: 4)
                    .scaleEffect(hasAvatar ? 1.0 : 0.9)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasAvatar)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.title)
                            .foregroundColor(.gray)
                    )
                    .scaleEffect(!hasAvatar ? 1.0 : 0.9)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: !hasAvatar)
            }
        }
        .transition(.scaleFade)
    }

    private var avatarDeleteButton: some View {
        Group {
            let hasAvatar = vm.avatarData != nil
            if hasAvatar {
                Button(role: .destructive) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        vm.clearAvatar()
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .pressEffect()
                .transition(.scaleFade)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.avatarData != nil)
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Общая статистика")
                .font(.headline)
            Text("Всего тренировок: \(vm.totalWorkouts)")
                .transition(.slideFromLeft)
            Text("Общее время: \(vm.totalDurationFormatted)")
                .transition(.slideFromLeft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.totalWorkouts)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: vm.totalDurationFormatted)
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
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showClearAlert = true
                }
            }
            .pressEffect()
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
}

#Preview {
    ProfileView()
}
