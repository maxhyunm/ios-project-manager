//
//  ChangeStatusViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/10/06.
//

import RxCocoa

final class ChangeStatusViewModel: ToDoChangeStatusViewModelType, ToDoChangeStatusViewModelOutputsType {
    weak var delegate: ToDoListChildViewModelDelegate?
    
    var error = BehaviorRelay<CoreDataError?>(value: nil)
    
    var inputs: ToDoChangeStatusViewModelInputsType { return self }
    var outputs: ToDoChangeStatusViewModelOutputsType { return self }
}

extension ChangeStatusViewModel: ViewModelTypeWithError {
    func handle(error: Error) {
        if let coreDataError = error as? CoreDataError {
            self.setError(coreDataError)
        } else {
            self.setError(CoreDataError.unknown)
        }
    }
    
    func setError(_ error: CoreDataError) {
        self.error.accept(error)
    }
}

extension ChangeStatusViewModel: ToDoChangeStatusViewModelInputsType {
    func touchUpButton(_ entity: ToDo, status: ToDoStatus) {
        delegate?.changeStatus(entity, to: status)
    }
}
