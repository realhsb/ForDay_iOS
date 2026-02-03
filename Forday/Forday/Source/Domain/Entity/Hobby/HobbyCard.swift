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

enum HobbyImageAsset: String, Codable {
    case drawing = "drawing.png"
    case gym = "gym.png"
    case reading = "reading.png"
    case music = "music.png"
    case running = "running.png"
    case cooking = "cooking.png"
    case cafe = "cafe.png"
    case movie = "movie.png"
    case photo = "photo.png"
    case writing = "writing.png"

    /// Maps Korean hobby name to HobbyImageAsset
    init?(hobbyName: String) {
        // Map Korean hobby names to image assets
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
    
//    var image: UIImage? {
//        let assetName = self.rawValue.replacingOccurrences(of: ".png", with: "")
//        return UIImage(named: assetName)
//    }
    
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
