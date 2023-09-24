//
//  CoreDataManager.swift
//  ProjectManager
//
//  Created by Min Hyun on 2023/09/24.
//

import CoreData

class CoreDataManager {
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDo")
        container.loadPersistentStores(completionHandler: { (_, _) in })
        return container
    }()

    func fetchData(entityName: String, predicate: NSPredicate? = nil, sort: String? = nil) throws -> [NSManagedObject] {
        let request: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: entityName)
        if let predicate {
            request.predicate = predicate
        }
        if let sort {
            let sorted = NSSortDescriptor(key: sort, ascending: true)
            request.sortDescriptors = [sorted]
        }
        do {
            let entities: [NSManagedObject] = try persistentContainer.viewContext.fetch(request)
            return entities
        } catch {
            throw CoreDataError.dataNotFound
        }
    }
    
    @discardableResult
    func createData<T: NSManagedObject>(type: T.Type, values: [(key: String, value: Any?)]) throws -> T {
        let newData = T(context: persistentContainer.viewContext)
        return try updateData(entity: newData, values: values)
    }
    
    @discardableResult
    func updateData<T: NSManagedObject>(entity: T, values: [(key: String, value: Any?)]) throws -> T  {
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
//            do {
//                try context.save()
//            } catch {
//                throw CoreDataError.saveFailure
//            }
        }
    }
}