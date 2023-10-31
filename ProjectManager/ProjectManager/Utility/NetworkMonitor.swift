//
//  NetworkMonitor.swift
//  ProjectManager
//
//  Created by Min Hyun on 2023/10/31.
//

import Foundation
import Network
import RxCocoa

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global()
    private(set) var isConnected = BehaviorRelay<Bool>(value: false)
    
    private init() {}
    
    public func start() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            self.isConnected.accept(path.status == .satisfied)
        }
    }
    
    public func stop() {
        monitor.cancel()
    }
}
