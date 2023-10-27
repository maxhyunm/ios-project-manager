//
//  ToDoViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//

import CoreData
import RxSwift

final class BaseListViewModel: BaseViewModelType, BaseViewModelDelegate {
    private let useCase: ToDoUseCase
    var entityList: [ToDoStatus: [ToDo]] = [:]
    var statusInAction: PublishSubject<(status: ToDoStatus, action: Output)> = PublishSubject()
    var inputs: BaseViewModelInputsType { return self }
    
    init(useCase: ToDoUseCase) {
        self.useCase = useCase
    }
}

extension BaseListViewModel: BaseViewModelInputsType {
    func addChild(_ status: ToDoStatus) -> ChildListViewModel {
        let child = ChildListViewModel(status: status)
        child.delegate = self
        child.bindData()
#if DEBUG
        do {
            try child.addTestData()
            entityList[status] = try useCase.fetchDataByStatus(for: status)
            statusInAction.onNext((status: status, action: Output(type: .create)))
        } catch(let error) {
            statusInAction.onError(error)
        }
#endif
        return child
    }
}

extension BaseListViewModel {
    func fetchData(for status: ToDoStatus) throws {
        entityList[status] = try useCase.fetchDataByStatus(for: status)
    }
    
    func createData(values: [KeywordArgument], status: ToDoStatus = ToDoStatus.toDo) throws {
        try useCase.createData(values: values)
        statusInAction.onNext((status: ToDoStatus.toDo, action: Output(type: .create)))
    }
    
    func readData(for status: ToDoStatus) throws {
        statusInAction.onNext((status: status, action: Output(type: .read)))
    }
    
    func updateData(_ entity: ToDo, values: [KeywordArgument]) throws {
        guard let status = ToDoStatus(rawValue: entity.status) else { return }
        try useCase.updateData(entity, values: values)
        statusInAction.onNext((status: status, action: Output(type: .update)))
    }
    
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus, index: Int) throws {
        guard let oldStatus = ToDoStatus(rawValue: entity.status) else { return }
        try useCase.updateData(entity, values: [KeywordArgument(key: "status", value: newStatus.rawValue)])
        statusInAction.onNext((status: oldStatus,
                               action: Output(type: .delete, extraInformation: [KeywordArgument(key: "index", value: index)])))
        statusInAction.onNext((status: newStatus, action: Output(type: .update)))
    }
    
    func deleteData(_ entity: ToDo, index: Int) throws {
        guard let status = ToDoStatus(rawValue: entity.status) else { return }
        try useCase.deleteData(entity)
        statusInAction.onNext((status: status,
                               action: Output(type: .delete, extraInformation: [KeywordArgument(key: "index", value: index)])))
    }
}
