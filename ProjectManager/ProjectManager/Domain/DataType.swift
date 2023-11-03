//
//  NSManagedObject+.swift
//  ProjectManager
//
//  Created by Max on 2023/11/03.
//

import CoreData

protocol LocalType: NSManagedObject, Identifiable {
    var id: UUID { get }
    func makeAttributeKeywordArguments() -> [KeywordArgument]
    func makeAttributeDictionary() -> [String: Any]
}

protocol RemoteType: Decodable, Identifiable {
    var id: UUID { get }
    func makeAttributeKeywordArguments() -> [KeywordArgument]
    func makeAttributeDictionary() -> [String: Any]
}
