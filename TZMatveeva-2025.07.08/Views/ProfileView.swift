//
//  ProfileView.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var vm = ProfileViewModel()

    var body: some View {
        Form {
            Section(header: Text("Пользователь")) {
                HStack {
                    Image(uiImage: vm.avatar)
                        .resizable()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                    Button("Изменить фото") { vm.pickPhoto() }
                }
            }

            Section(header: Text("Статистика")) {
                Text("Тренировок: \(vm.total)")
                Text("Время: \(vm.totalTimeFormatted)")
            }

            Section {
                Button("Очистить данные", role: .destructive) { vm.clearData() }
                Button("Версия: 1.0.0") { }
            }
        }
    }
}

#Preview {
    ProfileView()
}
