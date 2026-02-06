//
//  HobbyCard.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

import UIKit

struct HobbyCard: Codable {
    let id: Int?
    let name: String
    let description: String
    let imageAsset: HobbyImageAsset
}

/// API imageCode와 1:1 매핑되는 enum
enum HobbyImageAsset: String, Codable {
    case drawing = "DRAWING_ICON"
    case gym = "GYM_ICON"
    case reading = "READING_ICON"
    case music = "MUSIC_ICON"
    case running = "RUNNING_ICON"
    case cooking = "COOKING_ICON"
    case cafe = "CAFE_ICON"
    case movie = "MOVIE_ICON"
    case photo = "PHOTO_ICON"
    case writing = "WRITING_ICON"

    /// API imageCode로 초기화 (rawValue 사용)
    /// e.g., "DRAWING_ICON" -> .drawing
    init?(imageCode: String) {
        if let asset = HobbyImageAsset(rawValue: imageCode) {
            self = asset
        } else {
            self = .default
        }
    }

    /// 한글 취미명으로 초기화
    init?(hobbyName: String) {
        let mapping: [String: HobbyImageAsset] = [
            "그림 그리기": .drawing,
            "그림그리기": .drawing,
            "헬스": .gym,
            "운동": .gym,
            "독서": .reading,
            "음악 듣기": .music,
            "음악듣기": .music,
            "러닝": .running,
            "요리": .cooking,
            "카페 탐방": .cafe,
            "카페탐방": .cafe,
            "영화 보기": .movie,
            "영화보기": .movie,
            "사진 촬영": .photo,
            "사진촬영": .photo,
            "글쓰기": .writing
        ]

        if let asset = mapping[hobbyName] {
            self = asset
        } else {
            return nil
        }
    }
    
    var image: UIImage {
        switch self {
        case .drawing:
                .Hobbycard.drawing
        case .gym:
                .Hobbycard.gym
        case .reading:
                .Hobbycard.reading
        case .music:
                .Hobbycard.listeningmusic
        case .running:
                .Hobbycard.running
        case .cooking:
                .Hobbycard.cooking
        case .cafe:
                .Hobbycard.cafe
        case .movie:
                .Hobbycard.watchingmovie
        case .photo:
                .Hobbycard.pictures
        case .writing:
                .Hobbycard.writing
        }
    }
    
    var icon: UIImage {
        switch self {
        case .drawing:
                .Hobbyicon.drawing
        case .gym:
                .Hobbyicon.gym
        case .reading:
                .Hobbyicon.reading
        case .music:
                .Hobbyicon.listeningmusic
        case .running:
                .Hobbyicon.running
        case .cooking:
                .Hobbyicon.cooking
        case .cafe:
                .Hobbyicon.cafe
        case .movie:
                .Hobbyicon.watchingmovie
        case .photo:
                .Hobbyicon.pictures
        case .writing:
                .Hobbyicon.writing
        }
    }
}
