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
    func fetchData(for status: ToDoStatus)
    func createData(values: [KeywordArgument], status: ToDoStatus)
    func readData(for status: ToDoStatus)
    func updateData(_ entity: ToDo, values: [KeywordArgument])
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus, index: Int)
    func deleteData(_ entity: ToDo, index: Int) 
}

protocol ChildViewModelDelegate: AnyObject {
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus)
}
