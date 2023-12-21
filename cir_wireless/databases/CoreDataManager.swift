//
//  CoreDataManager.swift
//  cir_wireless
//
//  Created by Softel S.A. de C.V. on 19/12/23.
//  Copyright © 2023 SOFTEL. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FirmwareDB")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Error al cargar el almacén persistente: \(error)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Error al guardar el contexto: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
