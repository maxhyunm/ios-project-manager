//
//  DataSyncManager.swift
//  ProjectManager
//
//  Created by Max on 2023/10/31.
//

import Foundation
import CoreData
import RxSwift
import RxCocoa

struct ToDoDataSyncManager {
    let coreDataManager: CoreDataManager
    let firebaseManager: FirebaseManager
    
    init(coreDataManager: CoreDataManager, firebaseManager: FirebaseManager) {
        self.coreDataManager = coreDataManager
        self.firebaseManager = firebaseManager
    }
    
    func syncLocalWithRemote() -> Single<Void> {
        return mergeRemoteDataToLocal().map { _ in
            try self.mergeLocalDataToRemote(for: .create)
            try self.mergeLocalDataToRemote(for: .update)
            try self.deleteData()
        }
    }
    
    private func mergeRemoteDataToLocal() -> Single<Void> {
        return firebaseManager.loadData(entityName: "ToDo", type: ToDoDTO.self).map { entities in
            let localEntities: [ToDo] = try coreDataManager.fetchData(entityName: "ToDo")
            let localIdList: [UUID] = localEntities.map { $0.id }
            let remoteList = entities.filter { !localIdList.contains($0.id) }
            
            try remoteList.forEach { entity in
                let _: ToDo = try coreDataManager.createData(values: entity.makeAttributeKeywordArguments())
            }
        }
    }
    
    func mergeSingleLocalDataToRemote(_ entity: ToDo, uploadedAt: Date) throws {
        let values = [KeywordArgument(key: "uploadedAt", value: uploadedAt)]
        try coreDataManager.updateData(entity: entity, values: values)
        firebaseManager.changeData(entityName: "ToDo", id: entity.id.uuidString, values: entity.makeAttributeDictionary())
    }

    private func mergeLocalDataToRemote(for type: MergeType) throws {
        let onCondition = NSPredicate(format: type.predicateCondition)
        let notDeleted = NSPredicate(format: "willBeDeleted == %d", false)
        let predicated = NSCompoundPredicate.init(type: .and, subpredicates: [onCondition, notDeleted])
        let result: [ToDo] = try coreDataManager.fetchData(entityName: "ToDo", predicate: predicated)
        let uploadedAt = Date()
        
        try result.forEach { entity in
            try mergeSingleLocalDataToRemote(entity, uploadedAt: uploadedAt)
        }
    }
    
    func deleteSingleData(_ entity: ToDo) throws {
        firebaseManager.deleteData(entityName: "ToDo", id: entity.id.uuidString)
        try coreDataManager.deleteData(entity: entity)
    }
    
    private func deleteData() throws {
        let predicated = NSPredicate(format: "willBeDeleted == %d", true)
        let result: [ToDo] = try coreDataManager.fetchData(entityName: "ToDo", predicate: predicated)

        try result.forEach { entity in
            try deleteSingleData(entity)
        }
    }
}

extension ToDoDataSyncManager {
    enum MergeType {
        case create
        case update
        
        var predicateCondition: String {
            switch self {
            case .create:
                return "uploadedAt == nil"
            case .update:
                return "uploadedAt < modifiedAt"
            }
        }
    }
}
