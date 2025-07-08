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
    @State private var avatarImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var showClearAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Аватар
                    Button {
                        showPhotoPicker = true
                    } label: {
                        if let image = avatarImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.primary, lineWidth: 2))
                                .shadow(radius: 4)
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                                .overlay(Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.gray))
                        }
                    }

                    // Общая статистика
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Общая статистика")
                            .font(.headline)
                        Text("Всего тренировок: \(vm.totalWorkouts)")
                        Text("Общее время: \(formatDuration(vm.totalDuration))")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)

                    // Настройки
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Настройки")
                            .font(.headline)
                        Button("Очистить все данные", role: .destructive) {
                            showClearAlert = true
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)

                    // Информация
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
                    .background(.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
                }
                .padding()
            }
            .navigationTitle("Профиль")
            .onAppear {
                vm.fetchStats()
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: .constant(nil))
            .alert("Очистить все данные?", isPresented: $showClearAlert) {
                Button("Удалить", role: .destructive) {
                    vm.clearAllData()
                }
                Button("Отмена", role: .cancel) {}
            }
        }
    }

    func formatDuration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return h > 0 ? String(format: "%02d:%02d:%02d", h, m, s)
                     : String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    ProfileView()
}
