//
//  ToDoViewModelProtocol.swift
//  ProjectManager
//
//  Created by Max on 2023/09/26.
//

import Foundation
import RxSwift
import RxCocoa

final class ChildListViewModel: ChildViewModelType, ChildViewModelOutputsType {
    weak var delegate: BaseViewModelDelegate?
    
    var inputs: ChildViewModelInputsType { return self }
    var outputs: ChildViewModelOutputsType { return self }
    
    private let status: ToDoStatus
    var entityList: [ToDo] = []
    var action = PublishRelay<Output>()
    
    init(status: ToDoStatus) {
        self.status = status
    }
}

extension ChildListViewModel: ChildViewModelInputsType {
    func viewWillAppear() {
        delegate?.readData(for: status)
    }
    
    func swipeToDelete(_ entity: ToDo) {
        guard let index = entityList.firstIndex(of: entity) else { return }
        delegate?.deleteData(entity, index: index)
    }
}

extension ChildListViewModel: ChildViewModelDelegate {
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus) {
        guard let index = entityList.firstIndex(of: entity) else { return }
        delegate?.changeStatus(entity, to: newStatus, index: index)
    }
}



