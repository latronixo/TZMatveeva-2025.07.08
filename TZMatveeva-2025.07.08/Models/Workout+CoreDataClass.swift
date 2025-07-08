//
//  Workout+CoreDataClass.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import CoreData

class Workout: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var type: String         // Тип тренировки
    @NSManaged var duration: Int32      // Длительность в секундах
    @NSManaged var date: Date           // Дата тренировки
    @NSManaged var notes: String?       // Заметки
}
