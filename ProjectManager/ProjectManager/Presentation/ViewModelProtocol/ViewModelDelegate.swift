//
//  ToDoListViewModelDelegate.swift
//  ProjectManager
//
//  Created by Max on 2023/10/03.
//

protocol ToDoListBaseViewModelDelegate: AnyObject {
    func updateChild(_ status: ToDoStatus, action: Output) throws
    func touchUpDoneButton(_ entity: ToDo?, values: [KeywordArgument])
}

protocol ToDoListChildViewModelDelegate: AnyObject {
    func changeStatus(_ entity: ToDo, to newStatus: ToDoStatus)
}
