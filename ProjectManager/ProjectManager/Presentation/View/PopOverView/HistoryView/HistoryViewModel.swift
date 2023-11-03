//
//  HistoryViewModel.swift
//  ProjectManager
//
//  Created by Max on 2023/11/03.
//

import Foundation

final class HistoryViewModel {
    let useCase: HistoryUseCase
    var entityList = [History]()
    
    init(useCase: HistoryUseCase) {
        self.useCase = useCase
    }
    
    func viewDidLoad() {
        do {
            entityList = try useCase.fetchData()
            if entityList.count > 10 {
                entityList = Array(entityList[..<10])
            }
        } catch(let error) {
            print(error)
        }
    }
}
