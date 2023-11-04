//
//  HistoryDataSyncManager.swift
//  ProjectManager
//
//  Created by Max on 2023/11/03.
//

import Foundation
import RxSwift

struct HistoryDataSyncManager {
    let coreDataManager: CoreDataManager
    let firebaseManager: FirebaseManager
    
    init(coreDataManager: CoreDataManager, firebaseManager: FirebaseManager) {
        self.coreDataManager = coreDataManager
        self.firebaseManager = firebaseManager
    }
    
    func syncLocalWithRemote() -> Single<Void> {
        return mergeRemoteDataToLocal().map { _ in
            try mergeLocalDataToRemote()
        }
    }
    
    private func mergeRemoteDataToLocal() -> Single<Void> {
        return firebaseManager.loadData(entityName: "History", type: HistoryDTO.self).map { entities in
            let localEntities: [History] = try coreDataManager.fetchData(entityName: "History")
            let localIdList: [UUID] = localEntities.map { $0.id }
            let remoteList = entities.filter { !localIdList.contains($0.id) }
            
            try remoteList.forEach { entity in
                let _: History = try coreDataManager.createData(values: entity.makeAttributeKeywordArguments())
            }
        }
    }
    
    func mergeSingleLocalDataToRemote(_ entity: History, uploadedAt: Date) throws {
        let values = [KeywordArgument(key: "uploadedAt", value: uploadedAt)]
        try coreDataManager.updateData(entity: entity, values: values)
        firebaseManager.changeData(entityName: "History", id: entity.id.uuidString, values: entity.makeAttributeDictionary())
    }

    private func mergeLocalDataToRemote() throws {
        let predicated = NSPredicate(format: "uploadedAt == nil")
        let result: [History] = try coreDataManager.fetchData(entityName: "History", predicate: predicated)
        let uploadedAt = Date()
        
        try result.forEach { entity in
            try mergeSingleLocalDataToRemote(entity, uploadedAt: uploadedAt)
        }
    }
}
