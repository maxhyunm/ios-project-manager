//
//  DataManager.swift
//  ProjectManager
//
//  Created by Max on 2023/11/03.
//

struct DataManager<Local: LocalType, Remote: RemoteType> {
    let name: String
    let coreDataManager: CoreDataManager<Local>
    let firebaseManager: FirebaseManager<Remote>
    let dataSyncManager: DataSyncManager<Local, Remote>
    
    init(name: String) {
        self.name = name
        coreDataManager = CoreDataManager<Local>(containerName: "ToDo")
        firebaseManager = FirebaseManager<Remote>(name: name)
        dataSyncManager = DataSyncManager(coreDataManager: coreDataManager,
                                          firebaseManager: firebaseManager,
                                          name: name)
    }
}

