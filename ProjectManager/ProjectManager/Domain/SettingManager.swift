//
//  configureManager.swift
//  ProjectManager
//
//  Created by Max on 2023/11/02.
//

import Foundation

struct SettingManager {
    let coreDataManager = CoreDataManager<ToDo>(containerName: "ToDo")
    let firebaseManager = FirebaseManager<ToDoDTO>(name: "ToDo")
    let dataSyncManager: DataSyncManager
    let useCase: ToDoUseCase
    
    init() {
        self.dataSyncManager = DataSyncManager(coreDataManager: coreDataManager, firebaseManager: firebaseManager)
        self.useCase = ToDoUseCase(dataManager: dataSyncManager)
    }
}
