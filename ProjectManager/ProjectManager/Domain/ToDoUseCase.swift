//
//  ToDoUseCase.swift
//  ProjectManager
//
//  Created by Max on 2023/10/06.
//

import CoreData
import RxSwift

struct ToDoUseCase {
    private let dataSyncManager: DataSyncManager
    
    init(dataManager: DataSyncManager) {
        dataSyncManager = dataManager
    }
    
    func fetchDataByStatus(for status: ToDoStatus) throws -> [ToDo] {
        let predicated = NSPredicate(format: "status == %@ AND willBeDeleted == %d", status.rawValue, false)
        let filtered = try dataSyncManager.coreDataManager.fetchData(entityName:"ToDo", predicate: predicated, sort: "modifiedAt")
        
        guard let result = filtered as? [ToDo] else {
            throw ProjectManagerError.unknown
        }
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
        try dataSyncManager.coreDataManager.createData(type: ToDo.self, values: values)
        
        if NetworkMonitor.shared.isConnected.value {
            dataSyncManager.syncCoreDataWithFirebase()
        }
    }
    
    func updateData(_ entity: ToDo, values: [KeywordArgument]) throws {
        var values = values
        if values.filter({ $0.key == "modifiedAt" }).isEmpty {
            values.append(KeywordArgument(key: "modifiedAt", value: Date()))
        }
        try dataSyncManager.coreDataManager.updateData(entity: entity, values: values)
        if NetworkMonitor.shared.isConnected.value {
            dataSyncManager.syncCoreDataWithFirebase()
        }
    }
    
    func deleteData(_ entity: ToDo) throws {
        try dataSyncManager.coreDataManager.updateData(entity: entity, values: [KeywordArgument(key: "willBeDeleted", value: true)])
        if NetworkMonitor.shared.isConnected.value {
            dataSyncManager.syncCoreDataWithFirebase()
        }
    }
}
