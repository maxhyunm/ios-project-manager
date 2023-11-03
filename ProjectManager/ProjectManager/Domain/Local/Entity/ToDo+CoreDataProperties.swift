//
//  ToDo+CoreDataProperties.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//
//

import Foundation
import CoreData


extension ToDo {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDo> {
        return NSFetchRequest<ToDo>(entityName: "ToDo")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var dueDate: Date
    @NSManaged public var body: String
    @NSManaged public var modifiedAt: Date
    @NSManaged public var status: String
    @NSManaged public var uploadedAt: Date?
    @NSManaged public var willBeDeleted: Bool
    
}

extension ToDo: LocalType {
    func makeAttributeKeywordArguments() -> [KeywordArgument] {
        return [KeywordArgument(key: "id", value: id),
                KeywordArgument(key: "title", value: title),
                KeywordArgument(key: "dueDate", value: dueDate),
                KeywordArgument(key: "body", value: body),
                KeywordArgument(key: "modifiedAt", value: modifiedAt),
                KeywordArgument(key: "status", value: status),
                KeywordArgument(key: "uploadedAt", value: uploadedAt),
                KeywordArgument(key: "willBeDeleted", value: willBeDeleted)]
    }
    
    func makeAttributeDictionary() -> [String: Any] {
        guard let uploadedAt else { return [:] }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return ["id": id.uuidString,
                "title": title,
                "dueDate": dateFormatter.string(from: dueDate),
                "body" : body,
                "modifiedAt": dateFormatter.string(from: modifiedAt),
                "status": status,
                "uploadedAt": dateFormatter.string(from: uploadedAt),
                "willBeDeleted": willBeDeleted]
    }
}
