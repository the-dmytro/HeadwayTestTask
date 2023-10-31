//
// Created by Dmytro Kopanytsia on 31.10.2023.
//

import Foundation

struct BookSummary: Equatable, Identifiable {
    let id: String
    let title: String
    let coverName: String
    let keyPoints: [BookSummaryKeyPoint]
    let audioMetaData: AudioMetaData
}

extension BookSummary: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coverName
        case keyPoints
        case audioMetaData
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: CodingKeys.id)
        title = try container.decode(String.self, forKey: CodingKeys.title)
        coverName = try container.decode(String.self, forKey: CodingKeys.coverName)
        keyPoints = try container.decode([BookSummaryKeyPoint].self, forKey: CodingKeys.keyPoints)
        audioMetaData = try container.decode(AudioMetaData.self, forKey: CodingKeys.audioMetaData)
    }
}

struct BookSummaryKeyPoint: Equatable, Identifiable, Comparable, Decodable {
    let id: String
    let title: String
    let start: TimeInterval
    
    static func <(lhs: BookSummaryKeyPoint, rhs: BookSummaryKeyPoint) -> Bool {
        lhs.start < rhs.start
    }
}

struct AudioMetaData: Equatable, Decodable {
    let fileName: String
    let duration: TimeInterval
}