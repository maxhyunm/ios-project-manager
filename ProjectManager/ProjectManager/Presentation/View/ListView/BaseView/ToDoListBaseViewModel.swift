//
//  ToDoViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//

import CoreData
import RxCocoa

final class ToDoListBaseViewModel: ToDoBaseViewModelType, ToDoBaseViewModelOutputsType {
    private let useCase: ToDoUseCase
    private var children: [ToDoStatus: ToDoListChildViewModel] = [:]
    
    var inputs: ToDoBaseViewModelInputsType { return self }
    var outputs: ToDoBaseViewModelOutputsType { return self }
    
    var error = BehaviorRelay<CoreDataError?>(value: nil)
    
    init(useCase: ToDoUseCase) {
        self.useCase = useCase
    }
}

extension ToDoListBaseViewModel: ViewModelTypeWithError {
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
 
extension ToDoListBaseViewModel: ToDoBaseViewModelInputsType {
    func addChild(_ status: ToDoStatus) -> ToDoListChildViewModel {
        let child = ToDoListChildViewModel(status: status, useCase: useCase)
        child.delegate = self
        children[status] = child
#if DEBUG
        child.addTestData()
        do {
            try updateChild(status, action: Output(type: .create))
        } catch(let error) {
            handle(error: error)
        }
#endif
        return child
    }
}

extension ToDoListBaseViewModel {
    func createData(values: [KeywordArgument]) {
        do {
            try useCase.createData(values: values)
            try updateChild(.toDo, action: Output(type: .create))
        } catch(let error) {
            handle(error: error)
        }
    }
}

extension ToDoListBaseViewModel: ToDoListBaseViewModelDelegate {
    func updateChild(_ status: ToDoStatus, action: Output) throws {
        children[status]?.entityList = try useCase.fetchDataByStatus(for: status)
        children[status]?.action.accept(action)
    }
}
