//
//  Workout+CoreDataClass.swift
//  TZMatveeva-2025.07.08
//
//  Created by Валентин on 08.07.2025.
//

import CoreData

class Workout: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var type: String
    @NSManaged var duration: Int
    @NSManaged var date: Date
    @NSManaged var notes: String?       
}
