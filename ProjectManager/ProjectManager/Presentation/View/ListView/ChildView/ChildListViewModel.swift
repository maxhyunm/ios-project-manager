//
//  ToDoViewModelProtocol.swift
//  ProjectManager
//
//  Created by Max on 2023/09/26.
//

import Foundation
import RxSwift

final class ChildListViewModel: ChildViewModelType, ChildViewModelOutputsType {
    weak var delegate: BaseViewModelDelegate?
    
    var inputs: ChildViewModelInputsType { return self }
    var outputs: ChildViewModelOutputsType { return self }
    
    private let status: ToDoStatus
    var entityList: [ToDo] = []
    var action = PublishSubject<Output>()
    
    private let disposeBag = DisposeBag()
    
    init(status: ToDoStatus) {
        self.status = status
    }
}

extension ChildListViewModel: ChildViewModelInputsType {
    func viewWillAppear() {
        do {
            try delegate?.readData(for: status)
        } catch(let error) {
            action.onError(error)
        }
    }
    
    func swipeToDelete(_ entity: ToDo) {
        guard let index = entityList.firstIndex(of: entity) else { return }
        do {
            try delegate?.deleteData(entity, index: index)
        } catch(let error) {
            action.onError(error)
        }
    }
}

extension ChildListViewModel: ChildViewModelDelegate {
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus) {
        guard let index = entityList.firstIndex(of: entity) else { return }
        do {
            try delegate?.changeStatus(entity, to: newStatus, index: index)
        } catch(let error) {
            action.onError(error)
        }
    }
}

extension ChildListViewModel {
    func bindData() {
        guard let delegate else { return }
        delegate.statusInAction
            .filter { $0.status == self.status }
            .subscribe(
                onNext: { output in
                    do {
                        try delegate.fetchData(for: self.status)
                        self.action.onNext(output.action)
                    } catch(let error) {
                        self.action.onError(error)
                    }
                },
                onError: { error in
                    self.action.onError(error)
                })
            .disposed(by: disposeBag)
        
        delegate.totalEntityList.bind { totalList in
            guard let newList = totalList[self.status] else { return }
            self.entityList = newList
        }
        .disposed(by: disposeBag)
    }
}

#if DEBUG
extension ChildListViewModel {
    func addTestData() throws {
        let values: [KeywordArgument] = [
            KeywordArgument(key: "id", value: UUID()),
            KeywordArgument(key: "title", value: "\(status.rawValue) 테스트1"),
            KeywordArgument(key: "body", value: "테스트용입니다"),
            KeywordArgument(key: "dueDate", value: Date()),
            KeywordArgument(key: "modifiedAt", value: Date()),
            KeywordArgument(key: "status", value: status.rawValue)
        ]

        let values2: [KeywordArgument] = [
            KeywordArgument(key: "id", value: UUID()),
            KeywordArgument(key: "title", value: "\(status.rawValue) 테스트2"),
            KeywordArgument(key: "body", value: "테스트용입니다2"),
            KeywordArgument(key: "dueDate", value: Date()),
            KeywordArgument(key: "modifiedAt", value: Date()),
            KeywordArgument(key: "status", value: status.rawValue)
        ]

        try delegate?.createData(values: values, status: status)
        try delegate?.createData(values: values2, status: status)
    }
}
#endif
