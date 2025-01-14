//
//  ProjectManager - SceneDelegate.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
//  Last modified by Max.

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let coreDataManager = CoreDataManager(containerName: "ProjectManager")
        let firebaseManager = FirebaseManager()
        
        let toDoDataSyncManager = ToDoDataSyncManager(coreDataManager: coreDataManager, firebaseManager: firebaseManager)
        let toDoUseCase = ToDoUseCase(dataSyncManager: toDoDataSyncManager)
        
        let historyDataSyncManager = HistoryDataSyncManager(coreDataManager: coreDataManager, firebaseManager: firebaseManager)
        let historyUseCase = HistoryUseCase(dataSyncManager: historyDataSyncManager)

        let toDoViewModel = BaseListViewModel(toDoUseCase: toDoUseCase, historyUseCase: historyUseCase)
        let baseViewController = BaseListViewController(toDoViewModel)
        let navigationViewController = UINavigationController(rootViewController: baseViewController)
        
        toDoViewModel.syncData()
        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NetworkMonitor.shared.stop()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }


}

