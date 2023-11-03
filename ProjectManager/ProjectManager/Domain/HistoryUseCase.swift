//
//  HistoryUseCase.swift
//  ProjectManager
//
//  Created by Max on 2023/11/03.
//

import Foundation

struct HistoryUseCase {
    let dataSyncManager: DataSyncManager<History, HistoryDTO>
    
    init(dataSyncManager: DataSyncManager<History, HistoryDTO>) {
        self.dataSyncManager = dataSyncManager
    }
    
    func fetchData() throws -> [History] {
        let predicated = NSPredicate(format: "willBeDeleted == %d", false)
        let result = try dataSyncManager.coreDataManager.fetchData(entityName:"History", predicate: predicated, sort: "createdAt", ascending: false)

        return result
    }
    
    func createData(when date: Date, action: ActionType) throws {
        let values = [KeywordArgument(key: "id", value: UUID()),
                      KeywordArgument(key: "title", value: action.message),
                      KeywordArgument(key: "createdAt", value: date),
                      KeywordArgument(key: "willBeDeleted", value: false)]

        let entity = try dataSyncManager.coreDataManager.createData(values: values)
        
        if NetworkMonitor.shared.isConnected.value {
            try dataSyncManager.mergeSingleLocalDataToRemote(entity, uploadedAt: Date())
        }
    }
    
    func deleteData(_ entity: History) throws {
        try dataSyncManager.coreDataManager.updateData(entity: entity,
                                                       values: [KeywordArgument(key: "willBeDeleted", value: true)])
        if NetworkMonitor.shared.isConnected.value {
            try dataSyncManager.deleteSingleData(entity)
        }
    }
    
    func syncData(handler: @escaping (Error) -> Void) {
        dataSyncManager.syncLocalWithRemote() { handler($0) }
    }
}

extension HistoryUseCase {
    enum ActionType {
        case create(title: String)
        case move(title: String, oldStatus: String, newStatus: String)
        case delete(title: String, status: String)
        
        var message: String {
            switch self {
            case .create(let title):
                return "Added '\(title)'."
            case .move(let title, let oldStatus, let newStatus):
                return "Moved '\(title)' from \(oldStatus) to \(newStatus)."
            case .delete(let title, let status):
                return "Removed '\(title)' from \(status)."
            }
        }
    }
}
