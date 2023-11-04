//
//  BookSummaryFeature.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import Foundation
import ComposableArchitecture
import UIKit

struct BookSummaryFeature: Reducer {
    @Dependency(\.dataProvider) var dataProvider
    
    //MARK: Types
    
    enum CoverLoadingState: Equatable {
        case notLoaded
        case loading
        case loaded(UIImage)
        case error(Error)
        
        static func ==(lhs: BookSummaryFeature.CoverLoadingState, rhs: BookSummaryFeature.CoverLoadingState) -> Bool {
            switch (lhs, rhs) {
            case (.notLoaded, .notLoaded), (.loading, .loading):
                return true
            case (.loaded(let lhsImage), .loaded(let rhsImage)):
                return lhsImage == rhsImage
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    struct State: Equatable {
        var selectedBook: BookSummary?
        var coverImageLoadingState: CoverLoadingState = .notLoaded
    }
    
    enum Action: Equatable {
        case selectBook(BookSummary)
        case deselectBook
        case loadCoverImage
        case coverImageLoaded(UIImage)
        case coverImageLoadingError(Error)
        
        static func ==(lhs: BookSummaryFeature.Action, rhs: BookSummaryFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (.selectBook(let lhsBook), .selectBook(let rhsBook)):
                return lhsBook == rhsBook
            case (.loadCoverImage, .loadCoverImage), (.deselectBook, .deselectBook):
                return true
            case (.coverImageLoaded(let lhsImage), .coverImageLoaded(let rhsImage)):
                return lhsImage == rhsImage
            case (.coverImageLoadingError(let lhsError), .coverImageLoadingError(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    // MARK: Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .selectBook(let book):
            state.selectedBook = book
            state.coverImageLoadingState = .notLoaded
            return .run { send in
                await send(.loadCoverImage)
            }
            
        case .loadCoverImage:
            guard let book = state.selectedBook else {
                return .none
            }
            state.coverImageLoadingState = .loading
            return .run { send in
                do {
                    if let image = try await dataProvider.loadImage(book.coverName) {
                        await send(.coverImageLoaded(image))
                    }
                } catch {
                    await send(.coverImageLoadingError(error))
                }
            }
            
        case .coverImageLoaded(let image):
            state.coverImageLoadingState = .loaded(image)
            return .none
            
        case .coverImageLoadingError(let error):
            state.coverImageLoadingState = .error(error)
            return .none
            
        case .deselectBook:
            state.selectedBook = nil
            state.coverImageLoadingState = .notLoaded
            return .none
        }
    }
}
