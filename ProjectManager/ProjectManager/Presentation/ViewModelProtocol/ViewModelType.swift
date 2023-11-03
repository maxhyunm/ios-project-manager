//
//  ViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//

import RxCocoa
import RxSwift

protocol BaseViewModelType {
    var inputs: BaseViewModelInputsType { get }
    var outputs: BaseViewModelOutputsType { get }
    var historyUseCase: HistoryUseCase { get }
}

protocol BaseViewModelInputsType {
    func addChild(_ status: ToDoStatus) -> ChildListViewModel
}

protocol BaseViewModelOutputsType {
    var errorMessage: PublishRelay<String> { get }
}

protocol ChildViewModelType {
    var inputs: ChildViewModelInputsType { get }
    var outputs: ChildViewModelOutputsType { get }
    var delegate: BaseViewModelDelegate? { get }
}

protocol ChildViewModelInputsType {
    func viewWillAppear()
    func swipeToDelete(_ entity: ToDo)
}

protocol ChildViewModelOutputsType {
    var action: PublishRelay<Output> { get }
    var entityList: [ToDo] { get }
}

protocol ChangeStatusViewModelType {
    func touchUpButton(_ entity: ToDo, status: ToDoStatus)
}

protocol DetailViewModelType {
    func touchUpDoneButton(_ entity: ToDo?, values: [KeywordArgument])
}
