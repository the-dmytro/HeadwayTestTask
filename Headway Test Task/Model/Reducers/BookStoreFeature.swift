//
// Created by Dmytro Kopanytsia on 31.10.2023.
//

import Foundation
import ComposableArchitecture

struct BookStoreFeature: Reducer {
    
    // MARK: Dependencies
    
    @Dependency(\.dataProvider) var dataProvider
    
    //MARK: Types
    
    struct State: Equatable {
        var isLoading: Bool = false
        var books: [BookSummary] = []
    }
    
    enum Action: Equatable {
        case loadBooks
        case booksLoaded([BookSummary])
        case error(Error)
        
        static func ==(lhs: BookStoreFeature.Action, rhs: BookStoreFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadBooks, .loadBooks):
                return true
            case (.booksLoaded(let lhsBooks), .booksLoaded(let rhsBooks)):
                return lhsBooks == rhsBooks
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    // MARK: Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadBooks:
            state.isLoading = true
            return .run { send in
                do {
                    let books = try await dataProvider.loadBooks()
                    await send(.booksLoaded(books))
                }
                catch {
                    await send(.error(error))
                }
            }
        case .booksLoaded(let books):
            state.isLoading = false
            state.books = books
            return .none
            
        case .error:
            state.isLoading = false
            return .none
        }
    }
}
