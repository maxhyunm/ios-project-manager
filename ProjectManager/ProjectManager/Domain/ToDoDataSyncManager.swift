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
    
    func syncLocalWithRemote(errorHandler: @escaping (Error) -> Void) {
        do {
            try mergeRemoteDataToLocal() { errorHandler($0) }
            try mergeLocalDataToRemote(for: .create)
            try mergeLocalDataToRemote(for: .update)
            try deleteData()
        } catch(let error) {
            errorHandler(error)
        }
    }
    
    private func mergeRemoteDataToLocal(errorHandler: @escaping (Error) -> Void) throws {
        firebaseManager.loadData(entityName: "ToDo") { (result: Result<[ToDoDTO], Error>) in
            switch result {
            case .success(let data):
                do {
                    let localEntities: [ToDo] = try coreDataManager.fetchData(entityName: "ToDo")
                    let localIdList: [UUID] = localEntities.map { $0.id }
                    let remoteList = data.filter { !localIdList.contains($0.id) }
                    
                    try remoteList.forEach { entity in
                        try coreDataManager.createData(values: entity.makeAttributeKeywordArguments())
                    }
                } catch(let error) {
                    errorHandler(error)
                }
            case .failure(let error):
                errorHandler(error)
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
