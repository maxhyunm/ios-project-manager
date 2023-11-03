//
//  HistoryDataSyncManager.swift
//  ProjectManager
//
//  Created by Max on 2023/11/03.
//

import Foundation

struct HistoryDataSyncManager {
    let coreDataManager: CoreDataManager
    let firebaseManager: FirebaseManager
    
    init(coreDataManager: CoreDataManager, firebaseManager: FirebaseManager) {
        self.coreDataManager = coreDataManager
        self.firebaseManager = firebaseManager
    }
    
    func syncLocalWithRemote(handler: @escaping (Error) -> Void) {
        do {
            try mergeRemoteDataToLocal() { handler($0) }
            try mergeLocalDataToRemote()
        } catch(let error) {
            handler(error)
        }
    }
    
    private func mergeRemoteDataToLocal(handler: @escaping (Error) -> Void) throws {
        firebaseManager.loadData(entityName: "History") { (result: Result<[HistoryDTO], Error>) in
            switch result {
            case .success(let data):
                do {
                    let localEntities: [History] = try coreDataManager.fetchData(entityName: "History")
                    let localIdList: [UUID] = localEntities.map { $0.id }
                    let remoteList = data.filter { !localIdList.contains($0.id) }
                    
                    try remoteList.forEach { entity in
                        let _: History = try coreDataManager.createData(values: entity.makeAttributeKeywordArguments())
                    }
                } catch(let error) {
                    handler(error)
                }
            case .failure(let error):
                handler(error)
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
