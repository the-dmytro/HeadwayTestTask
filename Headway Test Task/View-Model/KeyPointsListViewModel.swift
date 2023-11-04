//
// Created by Dmytro Kopanytsia on 03.11.2023.
//

import ComposableArchitecture
import Combine

class KeyPointsListViewModel: ObservableObject {
    @Published var keyPoints: [BookSummaryKeyPoint] = []
    @Published var currentKeyPoint: BookSummaryKeyPoint? = nil
    
    private let store: Store<AppState, AppAction>
    private var cancellableSet: Set<AnyCancellable> = []
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
        subscribe(store: store)
    }
    
    private func subscribe(store: Store<AppState, AppAction>) {
        store.scope(state: { $0.bookKeyPoints.keyPoints }, action: AppAction.bookKeyPoints)
            .publisher
            .sink { [weak self] keyPoints in
                guard let self else {
                    return
                }
                self.keyPoints = keyPoints
            }
            .store(in: &cancellableSet)
        
        store.scope(state: { $0.bookKeyPoints.selectedKeyPoint }, action: AppAction.bookKeyPoints)
            .publisher
            .sink { [weak self] keyPoint in
                guard let self else {
                    return
                }
                if let keyPoint = keyPoint {
                    self.currentKeyPoint = keyPoint
                } else {
                    self.currentKeyPoint = nil
                }
            }
            .store(in: &cancellableSet)
    }
    
    func selectKeyPoint(_ keyPoint: BookSummaryKeyPoint) {
        store.send(.bookKeyPoints(.selectKeyPoint(keyPoint.id)))
    }
}
