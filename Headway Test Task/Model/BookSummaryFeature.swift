//
//  BookSummaryFeature.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import Foundation
import ComposableArchitecture

struct BookSummaryFeature: Reducer {
    @Dependency(\.dataProvider) var dataProvider
    
    //MARK: Types
    
    struct State: Equatable {
        var isLoading: Bool = false
        var books: [BookSummary] = []
        var selectedBook: BookSummary?
    }
    
    enum Action: Equatable {
        case loadBooks
        case booksLoaded([BookSummary])
        case selectBook(BookSummary)
        case loadBook(BookSummary)
        case bookLoaded(BookSummary)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadBooks:
            state.isLoading = true
            return .none // TODO: Load books from local storage
        case .booksLoaded(let books):
            state.isLoading = false
            state.books = books
            return .none
        case .selectBook(let book):
            state.selectedBook = book
            return .none
        }
    }
}
