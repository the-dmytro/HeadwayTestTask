//
// Created by Dmytro Kopanytsia on 02.11.2023.
//

import Foundation
import ComposableArchitecture

enum AppAction: Equatable {
    case bookStore(BookStoreFeature.Action)
    case bookSummary(BookSummaryFeature.Action)
    case bookKeyPoints(BookKeyPointsFeature.Action)
    case audioPlayer(AudioPlayerFeature.Action)
    case purchases(PurchasesFeature.Action)
}

struct AppState: Equatable {
    var bookStore: BookStoreFeature.State = .init()
    var bookSummary: BookSummaryFeature.State = .init()
    var bookKeyPoints: BookKeyPointsFeature.State = .init()
    var audioPlayer: AudioPlayerFeature.State = .init()
    var purchases: PurchasesFeature.State = .init()
}

struct AppReducer: Reducer {
    typealias State = AppState
    typealias Action = AppAction
    
    var bookStore = BookStoreFeature()
    var bookSummary = BookSummaryFeature()
    var bookKeyPoints = BookKeyPointsFeature()
    var audioPlayer = AudioPlayerFeature()
    var purchases = PurchasesFeature()
    var scenarios = ScenarioFeature()
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        .merge(
            dispatchAction(action: action, state: &state),
            scenarios.reduce(into: &state, action: action)
        )
    }
    
    private func dispatchAction(action: Action, state: inout State) -> Effect<Action> {
        switch action {
        case .bookStore(let action):
            return bookStore.reduce(into: &state.bookStore, action: action)
                .map { Action.bookStore($0) }
            
        case .bookSummary(let action):
            return bookSummary.reduce(into: &state.bookSummary, action: action)
                .map { Action.bookSummary($0) }
            
        case .bookKeyPoints(let action):
            return bookKeyPoints.reduce(into: &state.bookKeyPoints, action: action)
                .map { Action.bookKeyPoints($0) }
            
        case .audioPlayer(let action):
            return audioPlayer.reduce(into: &state.audioPlayer, action: action)
                .map { Action.audioPlayer($0) }
        case .purchases(let action):
            return purchases.reduce(into: &state.purchases, action: action)
                .map { Action.purchases($0) }
        }
    }
}
