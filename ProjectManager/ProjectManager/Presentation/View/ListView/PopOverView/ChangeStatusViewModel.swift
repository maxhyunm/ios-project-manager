//
//  ChangeStatusViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/10/06.
//

final class ChangeStatusViewModel: ChangeStatusViewModelType {
    weak var delegate: ChildViewModelDelegate?
    
    func touchUpButton(_ entity: ToDo, status: ToDoStatus) {
        delegate?.changeStatus(entity, to: status)
    }
}
