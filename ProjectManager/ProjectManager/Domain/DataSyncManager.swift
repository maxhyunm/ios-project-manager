//
//  DataSyncManager.swift
//  ProjectManager
//
//  Created by Max on 2023/10/31.
//

import Foundation
import RxSwift
import RxCocoa

struct DataSyncManager {
    let coreDataManager: CoreDataManager<ToDo>
    let firebaseManager: FirebaseManager<ToDoDTO>
    
    init(coreDataManager: CoreDataManager<ToDo>, firebaseManager: FirebaseManager<ToDoDTO>) {
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
        firebaseManager.loadData { result in
            switch result {
            case .success(let data):
                do {
                    let localEntities = try coreDataManager.fetchData(entityName:"ToDo")
                    let localIdList: [UUID] = localEntities.map { $0.id }
                    let remoteList = data.filter { !localIdList.contains($0.id) }
                    
                    try remoteList.forEach { entity in
                        let newItem = makeDTOKeywordArguments(for: entity)
                        try coreDataManager.createData(values: newItem)
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
        let data: [String: Any] = makeEntityDictionary(for: entity)
        firebaseManager.changeData(id: entity.id.uuidString, values: data)
    }

    private func mergeLocalDataToRemote(for type: MergeType) throws {
        let onCondition = NSPredicate(format: type.predicateCondition)
        let notDeleted = NSPredicate(format: "willBeDeleted == %d", false)
        let predicated = NSCompoundPredicate.init(type: .and, subpredicates: [onCondition, notDeleted])
        let result = try coreDataManager.fetchData(entityName:"ToDo", predicate: predicated)
        let uploadedAt = Date()
        
        try result.forEach { entity in
            try mergeSingleLocalDataToRemote(entity, uploadedAt: uploadedAt)
        }
    }
    
    func deleteSingleData(_ entity: ToDo) throws {
        firebaseManager.deleteData(id: entity.id.uuidString)
        try coreDataManager.deleteData(entity: entity)
    }
    
    private func deleteData() throws {
        let predicated = NSPredicate(format: "willBeDeleted == %d", true)
        let result = try coreDataManager.fetchData(entityName:"ToDo", predicate: predicated)

        try result.forEach { entity in
            try deleteSingleData(entity)
        }
    }
}

extension DataSyncManager {
    private func makeDTOKeywordArguments(for entity: ToDoDTO) -> [KeywordArgument] {
        return [KeywordArgument(key: "id", value: entity.id),
                KeywordArgument(key: "title", value: entity.title),
                KeywordArgument(key: "dueDate", value: entity.dueDate),
                KeywordArgument(key: "body", value: entity.body),
                KeywordArgument(key: "modifiedAt", value: entity.modifiedAt),
                KeywordArgument(key: "status", value: entity.status),
                KeywordArgument(key: "uploadedAt", value: entity.uploadedAt),
                KeywordArgument(key: "willBeDeleted", value: entity.willBeDeleted)]
    }
    
    private func makeEntityDictionary(for entity: ToDo) -> [String: Any] {
        guard let uploadedAt = entity.uploadedAt else { return [:] }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return ["id": entity.id.uuidString,
                "title": entity.title,
                "dueDate": dateFormatter.string(from: entity.dueDate),
                "body" : entity.body,
                "modifiedAt": dateFormatter.string(from: entity.modifiedAt),
                "status": entity.status,
                "uploadedAt": dateFormatter.string(from: uploadedAt),
                "willBeDeleted": entity.willBeDeleted]
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
