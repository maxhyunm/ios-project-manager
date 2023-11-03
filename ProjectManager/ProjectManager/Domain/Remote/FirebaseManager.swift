//
//  FirebaseManager.swift
//  ProjectManager
//
//  Created by Max on 2023/10/31.
//

import FirebaseDatabase
import RxSwift

final class FirebaseManager {
    let firebaseDB: DatabaseReference = Database.database().reference()

    func loadData<T: Decodable>(entityName: String, handler: @escaping (Result<[T], Error>) -> Void) {
        firebaseDB.child(entityName).getData { error, snapshot in
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
    
    func changeData(entityName: String, id: String, values: [String: Any]) {
        firebaseDB.child(entityName).updateChildValues([id: values])
    }
    
    func deleteData(entityName: String, id: String) {
        firebaseDB.child(entityName).child(id).removeValue()
    }
}
