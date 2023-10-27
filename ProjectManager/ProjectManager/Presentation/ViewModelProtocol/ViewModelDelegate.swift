//
//  ToDoListViewModelDelegate.swift
//  ProjectManager
//
//  Created by Max on 2023/10/03.
//

import RxSwift
import RxCocoa

protocol BaseViewModelDelegate: AnyObject {
    var totalEntityList: BehaviorRelay<[ToDoStatus: [ToDo]]> { get }
    var statusInAction: PublishSubject<(status: ToDoStatus, action: Output)> { get }
    func fetchData(for status: ToDoStatus) throws
    func createData(values: [KeywordArgument], status: ToDoStatus) throws
    func readData(for status: ToDoStatus) throws
    func updateData(_ entity: ToDo, values: [KeywordArgument]) throws
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus, index: Int) throws
    func deleteData(_ entity: ToDo, index: Int) throws
}

protocol ChildViewModelDelegate: AnyObject {
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus)
}
