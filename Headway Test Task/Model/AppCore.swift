//
// Created by Dmytro Kopanytsia on 02.11.2023.
//

import Foundation
import ComposableArchitecture

struct AppCore {
    var store: Store<AppState, AppAction>
    var booksViewModel: () -> BooksViewModel
    var bookSummaryViewModel: () -> BookSummaryViewModel
    var audioPlayerViewModel: () -> AudioPlayerViewModel
    var keyPointsListViewModel: () -> KeyPointsListViewModel
    var payWallViewModel: () -> PayWallViewModel
}

extension AppCore: DependencyKey {
    static var liveValue: Self {
        let actor = Actor()
        return Self(
            store: actor.store,
            booksViewModel: actor.booksViewModel,
            bookSummaryViewModel: actor.bookSummaryViewModel,
            audioPlayerViewModel: actor.audioPlayerViewModel,
            keyPointsListViewModel: actor.keyPointsListViewModel,
            payWallViewModel: actor.payWallViewModel
        )
    }
    
    private class Actor {
        let store: Store<AppState, AppAction>
        
        init() {
            store = Store(initialState: AppState()) {
                AppReducer()
            }
            store.send(.bookStore(.loadBooks))
        }
        
        func booksViewModel() -> BooksViewModel {
            BooksViewModel(store: store)
        }
        
        func bookSummaryViewModel() -> BookSummaryViewModel {
            BookSummaryViewModel(store: store)
        }
        
        func audioPlayerViewModel() -> AudioPlayerViewModel {
            AudioPlayerViewModel(store: store)
        }
        
        func keyPointsListViewModel() -> KeyPointsListViewModel {
            KeyPointsListViewModel(store: store)
        }
        
        func payWallViewModel() -> PayWallViewModel {
            PayWallViewModel(store: store)
        }
    }
}

extension DependencyValues {
    var appCore: AppCore {
        get {
            self[AppCore.self]
        }
        set {
            self[AppCore.self] = newValue
        }
    }
}