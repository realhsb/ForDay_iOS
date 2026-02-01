//
//  StoriesTabsResponse.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

extension DTO {

    struct StoriesTabsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: StoriesTabsData
    }

    struct StoriesTabsData: Codable {
        let tabInfo: [StoriesTabInfo]
    }

    struct StoriesTabInfo: Codable {
        let hobbyId: Int
        let hobbyName: String
        let hobbyStatus: String
    }
}

extension DTO.StoriesTabsResponse {
    func toDomain() -> [StoriesTab] {
        return data.tabInfo.map { $0.toDomain() }
    }
}

extension DTO.StoriesTabInfo {
    func toDomain() -> StoriesTab {
        return StoriesTab(
            hobbyId: hobbyId,
            hobbyName: hobbyName,
            hobbyStatus: hobbyStatus
        )
    }
}
