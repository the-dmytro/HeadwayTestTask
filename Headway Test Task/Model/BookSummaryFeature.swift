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
        var selectedBook: BookSummary?
    }
    
    enum Action: Equatable {
        case selectBook(BookSummary)
        case loadBook(BookSummary)
        case bookLoaded(BookSummary)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .selectBook(let book):
            state.selectedBook = book
            return .none
        }
    }
}
