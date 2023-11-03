//
//  ToDoUseCase.swift
//  ProjectManager
//
//  Created by Max on 2023/10/06.
//

import CoreData
import RxSwift

struct ToDoUseCase {
    let dataSyncManager: ToDoDataSyncManager
    
    init(dataSyncManager: ToDoDataSyncManager) {
        self.dataSyncManager = dataSyncManager
    }
    
    func fetchDataByStatus(for status: ToDoStatus) throws -> [ToDo] {
        let predicated = NSPredicate(format: "status == %@ AND willBeDeleted == %d", status.rawValue, false)
        let result: [ToDo] = try dataSyncManager.coreDataManager.fetchData(entityName:"ToDo", predicate: predicated, sort: "modifiedAt")

        return result
    }

    func createData(values: [KeywordArgument]) throws {
        var values = values
        
        if values.filter({ $0.key == "id" }).isEmpty {
            values.append(KeywordArgument(key: "id", value: UUID()))
        }
        
        if values.filter({ $0.key == "modifiedAt" }).isEmpty {
            values.append(KeywordArgument(key: "modifiedAt", value: Date()))
        }
        
        if values.filter({ $0.key == "status" }).isEmpty {
            values.append(KeywordArgument(key: "status", value: ToDoStatus.toDo.rawValue))
        }
        
        if values.filter({ $0.key == "willBeDeleted"}).isEmpty {
            values.append(KeywordArgument(key: "willBeDeleted", value: false))
        }
        let entity: ToDo = try dataSyncManager.coreDataManager.createData(values: values)
        
        if NetworkMonitor.shared.isConnected.value {
            try dataSyncManager.mergeSingleLocalDataToRemote(entity, uploadedAt: Date())
        }
    }
    
    @discardableResult
    func updateData(_ entity: ToDo, values: [KeywordArgument]) throws -> ToDo {
        var values = values
        if values.filter({ $0.key == "modifiedAt" }).isEmpty {
            values.append(KeywordArgument(key: "modifiedAt", value: Date()))
        }
        try dataSyncManager.coreDataManager.updateData(entity: entity, values: values)
        if NetworkMonitor.shared.isConnected.value {
            try dataSyncManager.mergeSingleLocalDataToRemote(entity, uploadedAt: Date())
        }
        
        return entity
    }
    
    func deleteData(_ entity: ToDo) throws {
        try updateData(entity, values: [KeywordArgument(key: "willBeDeleted", value: true)])
        if NetworkMonitor.shared.isConnected.value {
            try dataSyncManager.deleteSingleData(entity)
        }
    }
    
    func syncData(handler: @escaping (Error) -> Void) {
        dataSyncManager.syncLocalWithRemote() { handler($0) }
    }
}
