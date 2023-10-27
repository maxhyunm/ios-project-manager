//
//  DetailViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/10/27.
//

final class DetailViewModel: DetailViewModelType {
    weak var delegate: BaseViewModelDelegate?
    
    func touchUpDoneButton(_ entity: ToDo?, values: [KeywordArgument]) {
        do {
            guard let entity else {
                try delegate?.createData(values: values, status: ToDoStatus.toDo)
                return
            }
            try delegate?.updateData(entity, values: values)
        } catch(let error) {
            delegate?.statusInAction.onError(error)
        }
    }
}
