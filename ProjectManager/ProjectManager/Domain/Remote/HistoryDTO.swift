//
//  ToDo.swift
//  ProjectManager
//
//  Created by Max on 2023/10/31.
//

import Foundation

struct HistoryDTO: RemoteType, Hashable {
    var id: UUID
    var title: String
    var createdAt: Date
    var uploadedAt: Date
    var willBeDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, createdAt, uploadedAt, willBeDeleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let uuid = UUID(uuidString: try container.decode(String.self, forKey: .id)),
              let dtoCreatedAt = dateFormatter.date(from: try container.decode(String.self, forKey: .createdAt)),
              let dtoUploadedAt = dateFormatter.date(from: try container.decode(String.self, forKey: .uploadedAt)) else {
            throw ProjectManagerError.decodingFailure
        }
        
        id = uuid
        title = try container.decode(String.self, forKey: .title)
        createdAt = dtoCreatedAt
        uploadedAt = dtoUploadedAt
        willBeDeleted = try container.decode(Bool.self, forKey: .willBeDeleted)
    }
    
    func makeAttributeKeywordArguments() -> [KeywordArgument] {
        return [KeywordArgument(key: "id", value: id),
                KeywordArgument(key: "title", value: title),
                KeywordArgument(key: "createdAt", value: createdAt),
                KeywordArgument(key: "uploadedAt", value: uploadedAt),
                KeywordArgument(key: "willBeDeleted", value: willBeDeleted)]
    }
    
    func makeAttributeDictionary() -> [String: Any] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return ["id": id.uuidString,
                "title": title,
                "createdAt": dateFormatter.string(from: createdAt),
                "uploadedAt": dateFormatter.string(from: uploadedAt),
                "willBeDeleted": willBeDeleted]
    }
}
