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

struct DataSyncManager<Local: LocalType, Remote: RemoteType> {
    let coreDataManager: CoreDataManager<Local>
    let firebaseManager: FirebaseManager<Remote>
    let name: String
    
    init(coreDataManager: CoreDataManager<Local>, firebaseManager: FirebaseManager<Remote>, name: String) {
        self.coreDataManager = coreDataManager
        self.firebaseManager = firebaseManager
        self.name = name
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
        firebaseManager.loadData { result in
            switch result {
            case .success(let data):
                do {
                    let localEntities = try coreDataManager.fetchData(entityName: name)
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
    
    func mergeSingleLocalDataToRemote(_ entity: Local, uploadedAt: Date) throws {
        let values = [KeywordArgument(key: "uploadedAt", value: uploadedAt)]
        try coreDataManager.updateData(entity: entity, values: values)
        firebaseManager.changeData(id: entity.id.uuidString, values: entity.makeAttributeDictionary())
    }

    private func mergeLocalDataToRemote(for type: MergeType) throws {
        let onCondition = NSPredicate(format: type.predicateCondition)
        let notDeleted = NSPredicate(format: "willBeDeleted == %d", false)
        let predicated = NSCompoundPredicate.init(type: .and, subpredicates: [onCondition, notDeleted])
        let result = try coreDataManager.fetchData(entityName: name, predicate: predicated)
        let uploadedAt = Date()
        
        try result.forEach { entity in
            try mergeSingleLocalDataToRemote(entity, uploadedAt: uploadedAt)
        }
    }
    
    func deleteSingleData(_ entity: Local) throws {
        firebaseManager.deleteData(id: entity.id.uuidString)
        try coreDataManager.deleteData(entity: entity)
    }
    
    private func deleteData() throws {
        let predicated = NSPredicate(format: "willBeDeleted == %d", true)
        let result = try coreDataManager.fetchData(entityName: name, predicate: predicated)

        try result.forEach { entity in
            try deleteSingleData(entity)
        }
    }
}

extension DataSyncManager {
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
