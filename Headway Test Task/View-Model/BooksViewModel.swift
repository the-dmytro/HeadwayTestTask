//
// Created by Dmytro Kopanytsia on 04.11.2023.
//

import Foundation
import ComposableArchitecture
import Combine

class BooksViewModel: ObservableObject {
    @Published var isLoading = false
    
    private let store: Store<AppState, AppAction>
    private var cancellableSet: Set<AnyCancellable> = []
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
        subscribe(store: store)
    }
    
    func subscribe(store: Store<AppState, AppAction>) {
        store.scope(state: { $0.bookStore.isLoading }, action: AppAction.bookStore)
            .publisher
            .assign(to: &$isLoading)
    }
}
