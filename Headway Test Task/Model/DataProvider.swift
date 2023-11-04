//
// Created by Dmytro Kopanytsia on 31.10.2023.
//

import Foundation
import ComposableArchitecture
import UIKit

struct DataProvider {
    var loadImage: @Sendable (String) async throws -> UIImage?
    var loadBooks: @Sendable () async throws -> [BookSummary]
}

extension DataProvider: DependencyKey {
    static var liveValue: Self {
        let actor = Actor()
        return Self(
            loadImage: {
                try await actor.loadImage(name: $0)
            },
            loadBooks: {
                try await actor.loadBooks()
            }
        )
    }
    
    private actor Actor {
        @Dependency(\.mainBundle) var bundle
        
        func loadImage(name: String) async throws -> UIImage? {
            try await Task.wait(seconds: Double.random(in: 0.5...1))
            let url: URL?
            if let path = bundle.path(forResource: name, ofType: "jpg") {
                url = URL(fileURLWithPath: path)
            }
            else if let path = bundle.path(forResource: name, ofType: "png") {
                url = URL(fileURLWithPath: path)
            }
            else {
                url = nil
            }
            if let url = url {
                let data = try Data(contentsOf: url)
                guard let image = UIImage(data: data) else {
                    throw DataFailure.imageDataCorrupted
                }
                return image
            }
            else {
                throw DataFailure.imageNotFound
            }
        }
        
        func loadBooks() async throws -> [BookSummary] {
            try await Task.wait(seconds: Double.random(in: 0.5...1))
            if let url = bundle.url(forResource: "books", withExtension: "json") {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode(BookSummaries.self, from: data).summaries
            }
            else {
                return []
            }
        }
    }
}

extension DependencyValues {
    var dataProvider: DataProvider {
        get {
            self[DataProvider.self]
        }
        set {
            self[DataProvider.self] = newValue
        }
    }
}

extension Bundle: DependencyKey {
    public static let liveValue = Bundle.main
}

extension DependencyValues {
    var mainBundle: Bundle {
        get {
            self[Bundle.self]
        }
        set {
            self[Bundle.self] = newValue
        }
    }
}
