//
//  CoreDataError.swift
//  ProjectManager
//
//  Created by Max on 2023/09/24.
//

enum ProjectManagerError: Error {
    case dataNotFound
    case saveFailure
    case updateFailure
    case deleteFailure
    case decodingFailure
    case unknown

    var alertTitle: String {
        switch self {
        default:
            return "데이터 오류"
        }
    }
    
    var alertMessage: String {
        switch self {
        case .dataNotFound:
            return "데이터를 찾을 수 없습니다"
        case .saveFailure:
            return "저장에 실패하였습니다"
        case .updateFailure:
            return "수정에 실패하였습니다"
        case .deleteFailure:
            return "삭제에 실패하였습니다"
        case .decodingFailure:
            return "데이터 변환에 실패하였습니다"
        case .unknown:
            return "알 수 없는 오류입니다"
        }
    }
    
    static func downcastError(_ error: Error) -> ProjectManagerError {
        guard let downcasted = error as? ProjectManagerError else {
            return ProjectManagerError.unknown
        }
        return downcasted
    }
}

