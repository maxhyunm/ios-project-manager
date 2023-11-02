//
//  FirebaseManager.swift
//  ProjectManager
//
//  Created by Max on 2023/10/31.
//

import FirebaseDatabase
import RxSwift

final class FirebaseManager<T: Decodable> {
    let firebaseDB: DatabaseReference
    
    init(name: String) {
        firebaseDB = Database.database().reference().child(name)
    }
    
    func loadData(handler: @escaping (Result<[T], Error>) -> Void) {
        firebaseDB.getData { error, snapshot in
            if let error {
                handler(.failure(error))
                return
            }
            
            guard let snapshot,
                  let data = snapshot.value as? [String: Any] else {
                handler(.failure(ProjectManagerError.dataNotFound))
                return
            }
            
            let reducedData = data.reduce(into: []) { $0.append($1.value) }
            
            do {
                let json = try JSONSerialization.data(withJSONObject: reducedData)
                let dto = try JSONDecoder().decode([T].self, from: json)
                handler(.success(dto))
                
            } catch(let error) {
                handler(.failure(error))
            }
        }
    }
    
    func changeData(id: String, values: [String: Any]) {
        firebaseDB.updateChildValues([id: values])
    }
    
    func deleteData(id: String) {
        firebaseDB.child(id).removeValue()
    }
}
