//
//  DataSyncManager.swift
//  ProjectManager
//
//  Created by Min Hyun on 2023/10/31.
//

import Foundation
import RxSwift

struct DataSyncManager {
    let coreDataManager = CoreDataManager()
    let firebaseManager = FirebaseManager()
    let disposeBag = DisposeBag()
    
    init() {
        loadFirebaseToCoreData()
    }
    
    func loadFirebaseToCoreData() {
        firebaseManager.entityList.subscribe(onNext: { entities in
            entities.forEach { entity in
                let predicated = NSPredicate(format: "id == %@", entity.id.uuidString)
                do {
                    let match = try coreDataManager.fetchData(entityName: "ToDo", predicate: predicated)
                    if match.isEmpty {
                        let newItem = [KeywordArgument(key: "id", value: entity.id),
                                       KeywordArgument(key: "title", value: entity.title),
                                       KeywordArgument(key: "dueDate", value: entity.dueDate),
                                       KeywordArgument(key: "body", value: entity.body),
                                       KeywordArgument(key: "modifiedAt", value: entity.modifiedAt),
                                       KeywordArgument(key: "status", value: entity.status),
                                       KeywordArgument(key: "uploadedAt", value: entity.uploadedAt),
                                       KeywordArgument(key: "willBeDeleted", value: entity.willBeDeleted),]
                        try coreDataManager.createData(type: ToDo.self, values: newItem)
                    }
                } catch(let error) {
                    print(error)
                }
            }
        }, onError: { error in
            print(error)
        })
        .disposed(by: disposeBag)
    }
    
    func syncCoreDataWithFirebase() {
        do {
            try createDataToFirebase()
            try updateDataFromFirebase()
            try deleteDataFromAll()
        } catch(let error) {
            print(error)
        }
    }
    
    func createDataToFirebase() throws {
        let toBeCreate = NSPredicate(format: "uploadedAt == nil")
        let notDeleted = NSPredicate(format: "willBeDeleted == %d", false)
        let predicated = NSCompoundPredicate.init(type: .and, subpredicates: [toBeCreate, notDeleted])
        let filtered = try coreDataManager.fetchData(entityName:"ToDo", predicate: predicated, sort: "modifiedAt")
        
        guard let result = filtered as? [ToDo] else {
            throw ProjectManagerError.unknown
        }
        
        let uploadedAt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        result.forEach { entity in
            do {
                entity.setValue(uploadedAt, forKey: "uploadedAt")
                try coreDataManager.saveContext()
            } catch(let error) {
                print(error)
            }
            
            let data: [String: Any] = [
                "id": entity.id.uuidString,
                "title": entity.title,
                "dueDate": dateFormatter.string(from: entity.dueDate),
                "body" : entity.body,
                "modifiedAt": dateFormatter.string(from: entity.modifiedAt),
                "status": entity.status,
                "uploadedAt": dateFormatter.string(from: uploadedAt),
                "willBeDeleted": entity.willBeDeleted
            ]
            
            firebaseManager.createData(id: entity.id.uuidString, values: data)
        }
    }
    
    func updateDataFromFirebase() throws {
        let firebaseManager = FirebaseManager()
        
        let toBeCreate = NSPredicate(format: "uploadedAt < modifiedAt")
        let notDeleted = NSPredicate(format: "willBeDeleted == %d", false)
        let predicated = NSCompoundPredicate.init(type: .and, subpredicates: [toBeCreate, notDeleted])
        let filtered = try coreDataManager.fetchData(entityName:"ToDo", predicate: predicated, sort: "modifiedAt")
        
        guard let result = filtered as? [ToDo] else {
            throw ProjectManagerError.unknown
        }
        
        let uploadedAt = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        result.forEach { entity in
            do {
                entity.setValue(uploadedAt, forKey: "uploadedAt")
                try coreDataManager.saveContext()
            } catch {
                
            }
            
            let data: [String: Any] = [
                "id": entity.id.uuidString,
                "title": entity.title,
                "dueDate": dateFormatter.string(from: entity.dueDate),
                "body" : entity.body,
                "modifiedAt": dateFormatter.string(from: entity.modifiedAt),
                "status": entity.status,
                "uploadedAt": dateFormatter.string(from: uploadedAt),
                "willBeDeleted": entity.willBeDeleted
            ]
            
            firebaseManager.updateData(id: entity.id.uuidString, values: data)
        }
    }
    
    func deleteDataFromAll() throws {
        let firebaseManager = FirebaseManager()
        let predicated = NSPredicate(format: "willBeDeleted == %d", true)
        let filtered = try coreDataManager.fetchData(entityName:"ToDo", predicate: predicated)
        guard let result = filtered as? [ToDo] else {
            throw ProjectManagerError.unknown
        }
        
        result.forEach { entity in
            firebaseManager.deleteData(id: entity.id.uuidString)
            
            do {
                try coreDataManager.deleteData(entity: entity)
            } catch {
                
            }
        }
    }
}
