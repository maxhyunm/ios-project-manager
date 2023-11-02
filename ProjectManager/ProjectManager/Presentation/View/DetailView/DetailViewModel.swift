//
//  DetailViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/10/27.
//

final class DetailViewModel: DetailViewModelType {
    weak var delegate: BaseViewModelDelegate?
    
    func touchUpDoneButton(_ entity: ToDo?, values: [KeywordArgument]) {
        guard let entity else {
            delegate?.createData(values: values, status: ToDoStatus.toDo)
            return
        }
        delegate?.updateData(entity, values: values)
    }
}
