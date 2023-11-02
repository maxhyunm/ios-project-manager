//
//  ToDoViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//

import CoreData
import RxSwift
import RxCocoa

final class BaseListViewModel: BaseViewModelType, BaseViewModelDelegate {
    private let useCase: ToDoUseCase
    var totalEntityList: BehaviorRelay<[ToDoStatus: [ToDo]]> = BehaviorRelay(value: [:])
    var inputs: BaseViewModelInputsType { return self }
    var errorMessage = PublishRelay<String>()
    var disposeBag = DisposeBag()
    
    var children = [ToDoStatus: ChildListViewModel]()
    
    init(useCase: ToDoUseCase) {
        self.useCase = useCase
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
            children[status]?.entityList = try useCase.fetchDataByStatus(for: status)
            
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func createData(values: [KeywordArgument], status: ToDoStatus = ToDoStatus.toDo) {
        do {
            try useCase.createData(values: values)
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
            try useCase.updateData(entity, values: values)
            fetchData(for: status)
            children[status]?.action.accept(Output(type: .update))
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus, index: Int) {
        guard let oldStatus = ToDoStatus(rawValue: entity.status) else { return }
        do {
            try useCase.updateData(entity, values: [KeywordArgument(key: "status", value: newStatus.rawValue)])
            fetchData(for: oldStatus)
            fetchData(for: newStatus)
            children[oldStatus]?.action.accept(Output(type: .delete, extraInformation: [KeywordArgument(key: "index", value: index)]))
            children[newStatus]?.action.accept(Output(type: .update))
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func deleteData(_ entity: ToDo, index: Int) {
        guard let status = ToDoStatus(rawValue: entity.status) else { return }
        do {
            try useCase.deleteData(entity)
            fetchData(for: status)
            children[status]?.action.accept(Output(type: .delete, extraInformation: [KeywordArgument(key: "index", value: index)]))
        } catch(let error) {
            errorMessage.accept(ProjectManagerError.downcastError(error).alertMessage)
        }
    }
    
    func syncData() {
        useCase.syncData() {
            self.errorMessage.accept(ProjectManagerError.downcastError($0).alertMessage)
        }
    }
}
