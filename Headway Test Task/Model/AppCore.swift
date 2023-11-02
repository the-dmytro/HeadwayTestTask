//
// Created by Dmytro Kopanytsia on 02.11.2023.
//

import Foundation
import ComposableArchitecture

class AppCore {
    let store: Store<AppState, AppAction>
    
    init() {
        store = Store(initialState: AppState()) {
            AppReducer()
        }
        store.send(.bookStore(.loadBooks))
    }
    
    func bookSummaryViewModel() -> BookSummaryViewModel {
        BookSummaryViewModel(store: store)
    }
}
