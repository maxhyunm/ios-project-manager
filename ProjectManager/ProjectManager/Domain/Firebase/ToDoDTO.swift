//
//  ToDo.swift
//  ProjectManager
//
//  Created by Min Hyun on 2023/10/31.
//

import Foundation

struct ToDoDTO: Decodable, Hashable, Identifiable {
    var id: UUID
    var title: String
    var dueDate: Date
    var body: String
    var modifiedAt: Date
    var status: String
    var uploadedAt: Date
    var willBeDeleted: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, dueDate, body, modifiedAt, status, uploadedAt, willBeDeleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let uuid = UUID(uuidString: try container.decode(String.self, forKey: .id)),
              let dtoDueDate = dateFormatter.date(from: try container.decode(String.self, forKey: .dueDate)),
              let dtoModifiedAt = dateFormatter.date(from: try container.decode(String.self, forKey: .modifiedAt)),
              let dtoUploadedAt = dateFormatter.date(from: try container.decode(String.self, forKey: .uploadedAt)) else {
            throw ProjectManagerError.decodingFailure
        }
        
        id = uuid
        title = try container.decode(String.self, forKey: .title)
        dueDate = dtoDueDate
        body = try container.decode(String.self, forKey: .body)
        modifiedAt = dtoModifiedAt
        status = try container.decode(String.self, forKey: .status)
        uploadedAt = dtoUploadedAt
        willBeDeleted = try container.decode(Bool.self, forKey: .willBeDeleted)
    }
}
