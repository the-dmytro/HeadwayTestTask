//
// Created by Dmytro Kopanytsia on 31.10.2023.
//

import Foundation

struct BookSummaries: Equatable, Decodable {
    let summaries: [BookSummary]
}

struct BookSummary: Equatable, Identifiable {
    let id: String
    let title: String
    let coverName: String
    let keyPoints: [BookSummaryKeyPoint]
    let audioMetaData: AudioMetaData
    let productId: String
}

extension BookSummary: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case coverName
        case keyPoints
        case audioMetaData
        case productId
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: CodingKeys.id)
        title = try container.decode(String.self, forKey: CodingKeys.title)
        coverName = try container.decode(String.self, forKey: CodingKeys.coverName)
        keyPoints = try container.decode([BookSummaryKeyPoint].self, forKey: CodingKeys.keyPoints)
        audioMetaData = try container.decode(AudioMetaData.self, forKey: CodingKeys.audioMetaData)
        productId = try container.decode(String.self, forKey: CodingKeys.productId)
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

struct Purchase: Equatable {
    typealias ID = String
    enum PurchasingState: Equatable {
        case notLoaded
        case available
        case notAvailable
        case purchasing
        case purchased
        case error(Error)
        
        static func ==(lhs: PurchasingState, rhs: PurchasingState) -> Bool {
            switch (lhs, rhs) {
            case (.notLoaded, .notLoaded), (.available, .available), (.notAvailable, .notAvailable), (.purchasing, .purchasing), (.purchased, .purchased):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    var id: ID
    var title: String
    var description: String
    var price: String
    var status: PurchasingState = .notLoaded
    
    init(id: ID) {
        self.id = id
        self.title = ""
        self.description = ""
        self.price = ""
    }
    
    init(id: ID, title: String, description: String, price: String, status: PurchasingState) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
        self.status = status
    }
}