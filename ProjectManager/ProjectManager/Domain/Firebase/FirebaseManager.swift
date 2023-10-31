//
//  FirebaseManager.swift
//  ProjectManager
//
//  Created by Max on 2023/10/31.
//

import FirebaseDatabase
import RxSwift

struct FirebaseManager {
    let firebaseDB: DatabaseReference = Database.database().reference().child("ToDo")
    var entityList = BehaviorSubject<[ToDoDTO]>(value: [])
    
    func loadData() {
        firebaseDB.getData { error, snapshot in
            guard let snapshot,
                  let data = snapshot.value as? [String: Any] else { return }
            let reducedData = data.reduce(into: []) { $0.append($1.value) }
            
            do {
                let json = try JSONSerialization.data(withJSONObject: reducedData)
                let dto = try JSONDecoder().decode([ToDoDTO].self, from: json)
                entityList.onNext(dto)
            } catch(let error) {
                entityList.onError(error)
            }
        }
    }
    
    func createData(id: String, values: [String: Any]) {
        firebaseDB.child(id).setValue(values)
    }
    
    func updateData(id: String, values: [String: Any]) {
        firebaseDB.updateChildValues([id: values])
    }
    
    func deleteData(id: String) {
        firebaseDB.child(id).removeValue()
    }
}
