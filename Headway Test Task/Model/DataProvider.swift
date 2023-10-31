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
        func loadImage(name: String) async throws -> UIImage? {
            let url: URL?
            if let path = Bundle.main.path(forResource: name, ofType: "jpg") {
                url = URL(fileURLWithPath: path)
            }
            else if let path = Bundle.main.path(forResource: name, ofType: "png") {
                url = URL(fileURLWithPath: path)
            }
            else {
                url = nil
            }
            if let url = url {
                let data = try Data(contentsOf: url)
                return UIImage(data: data)
            }
            else {
                return nil
            }
        }
        
        func loadBooks() async throws -> [BookSummary] {
            if let path = Bundle.main.path(forResource: "books", ofType: "json") {
                let url = URL(fileURLWithPath: path)
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                return try decoder.decode([BookSummary].self, from: data)
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