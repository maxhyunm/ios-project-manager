//
//  ToDoViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//

import CoreData
import RxSwift
import RxCocoa

final class BaseListViewModel: BaseViewModelType, BaseViewModelOutputsType, BaseViewModelDelegate {
    var inputs: BaseViewModelInputsType { return self }
    var outputs: BaseViewModelOutputsType { return self }
    private let toDoUseCase: ToDoUseCase
    var historyUseCase: HistoryUseCase
    var totalEntityList: BehaviorRelay<[ToDoStatus: [ToDo]]> = BehaviorRelay(value: [:])
    var errorMessage = PublishRelay<String>()
    var disposeBag = DisposeBag()
    
    var children = [ToDoStatus: ChildListViewModel]()
    
    init(toDoUseCase: ToDoUseCase, historyUseCase: HistoryUseCase) {
        self.toDoUseCase = toDoUseCase
        self.historyUseCase = historyUseCase
    }
}

extension BaseListViewModel: BaseViewModelInputsType {
    func addChild(_ status: ToDoStatus) -> ChildListViewModel {
        let child = ChildListViewModel(status: status)
        child.delegate = self
        children[status] = child
        return child
    }
}

extension BaseListViewModel {
    func fetchData(for status: ToDoStatus) {
        do {
            children[status]?.entityList = try toDoUseCase.fetchDataByStatus(for: status)
            
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func createData(values: [KeywordArgument], status: ToDoStatus = ToDoStatus.toDo) {
        do {
            guard let title = values.filter({ $0.key == "title" }).first?.value as? String else { return }
            try toDoUseCase.createData(values: values)
            try historyUseCase.createData(when: Date(), action: .create(title: title))
            fetchData(for:status)
            children[status]?.action.accept(Output(type: .create))
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func readData(for status: ToDoStatus) {
        fetchData(for: status)
        children[status]?.action.accept(Output(type: .read))
    }
    
    func updateData(_ entity: ToDo, values: [KeywordArgument]) {
        do {
            guard let status = ToDoStatus(rawValue: entity.status) else { return }
            try toDoUseCase.updateData(entity, values: values)
            fetchData(for: status)
            children[status]?.action.accept(Output(type: .update))
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus, index: Int) {
        guard let oldStatus = ToDoStatus(rawValue: entity.status) else { return }
        do {
            let modified = try toDoUseCase.updateData(entity, values: [KeywordArgument(key: "status", value: newStatus.rawValue)])
            fetchData(for: oldStatus)
            fetchData(for: newStatus)
            children[oldStatus]?.action.accept(Output(type: .delete, extraInformation: [KeywordArgument(key: "index", value: index)]))
            children[newStatus]?.action.accept(Output(type: .update))
            try historyUseCase.createData(when: modified.modifiedAt, action: .move(title: modified.title,
                                                                                   oldStatus: oldStatus.rawValue,
                                                                                   newStatus: newStatus.rawValue))
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func deleteData(_ entity: ToDo, index: Int) {
        guard let status = ToDoStatus(rawValue: entity.status) else { return }
        let historyAction = HistoryUseCase.ActionType.delete(title: entity.title, status: entity.status)
        do {
            try toDoUseCase.deleteData(entity)
            fetchData(for: status)
            children[status]?.action.accept(Output(type: .delete, extraInformation: [KeywordArgument(key: "index", value: index)]))
            try historyUseCase.createData(when: Date(), action: historyAction)
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func syncData() {
        toDoUseCase
            .syncData()
            .subscribe(
                onSuccess: {
                    self.readData(for: .toDo)
                    self.readData(for: .doing)
                    self.readData(for: .done)
                },
                onFailure: { error in
                    self.errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
                })
            .disposed(by: disposeBag)
    }
}
