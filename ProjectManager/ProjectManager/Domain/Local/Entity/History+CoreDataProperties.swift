//
//  History+CoreDataProperties.swift
//  ProjectManager
//
//  Created by Max on 2023/11/02.
//
//

import Foundation
import CoreData

extension History {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var title: String
    @NSManaged public var createdAt: Date
    @NSManaged public var uploadedAt: Date?
    @NSManaged public var willBeDeleted: Bool
}

extension History: LocalType {
    func makeAttributeKeywordArguments() -> [KeywordArgument] {
        return [KeywordArgument(key: "id", value: id),
                KeywordArgument(key: "title", value: title),
                KeywordArgument(key: "createdAt", value: createdAt),
                KeywordArgument(key: "uploadedAt", value: uploadedAt),
                KeywordArgument(key: "willBeDeleted", value: willBeDeleted)]
    }
    
    func makeAttributeDictionary() -> [String: Any] {
        guard let uploadedAt else { return [:] }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return ["id": id.uuidString,
                "title": title,
                "createdAt": dateFormatter.string(from: createdAt),
                "uploadedAt": dateFormatter.string(from: uploadedAt),
                "willBeDeleted": willBeDeleted]
    }
    
    
}
