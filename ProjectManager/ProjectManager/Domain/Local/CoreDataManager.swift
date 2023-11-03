//
//  CoreDataManager.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//

import CoreData

struct CoreDataManager {
    let persistentContainer: NSPersistentContainer
    
    init(containerName: String) {
        persistentContainer = {
            let container = NSPersistentContainer(name: containerName)
            container.loadPersistentStores(completionHandler: { (_, _) in })
            return container
        }()
    }

    func fetchData<T: NSManagedObject>(entityName: String, predicate: NSPredicate? = nil, sort: String? = nil, ascending: Bool = true) throws -> [T] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
        if let predicate {
            request.predicate = predicate
        }
        if let sort {
            let sorted = NSSortDescriptor(key: sort, ascending: ascending)
            request.sortDescriptors = [sorted]
        }
        do {
            let entities: [NSManagedObject] = try persistentContainer.viewContext.fetch(request)
            guard let result = entities as? [T] else {
                throw ProjectManagerError.unknown
            }
            return result
        } catch {
            throw ProjectManagerError.dataNotFound
        }
    }
    
    @discardableResult
    func createData<T: NSManagedObject>(values: [KeywordArgument]) throws -> T {
        let newData = T(context: persistentContainer.viewContext)
        values.forEach { newData.setValue($0.value, forKey: $0.key) }
        try saveContext()
        return newData
    }
    
    @discardableResult
    func updateData<T: NSManagedObject>(entity: T, values: [KeywordArgument]) throws -> T  {
        values.forEach { entity.setValue($0.value, forKey: $0.key) }
        try saveContext()
        return entity
    }
    
    func deleteData<T: NSManagedObject>(entity: T) throws {
        persistentContainer.viewContext.delete(entity)
        try saveContext()
    }
    
    func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                throw ProjectManagerError.saveFailure
            }
        }
    }
}
