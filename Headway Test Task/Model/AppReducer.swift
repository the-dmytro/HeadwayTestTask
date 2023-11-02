//
// Created by Dmytro Kopanytsia on 02.11.2023.
//

import Foundation
import ComposableArchitecture

struct AppState: Equatable {
    var bookStore: BookStoreFeature.State = .init()
    var bookSummary: BookSummaryFeature.State = .init()
    var audioPlayer: AudioPlayerFeature.State = .init()
    var purchases: PurchasesFeature.State = .init()
}

enum AppAction: Equatable {
    case bookStore(BookStoreFeature.Action)
    case bookSummary(BookSummaryFeature.Action)
    case audioPlayer(AudioPlayerFeature.Action)
    case purchases(PurchasesFeature.Action)
}

struct AppReducer: Reducer {
    typealias State = AppState
    typealias Action = AppAction
    
    var bookStore = BookStoreFeature()
    var bookSummary = BookSummaryFeature()
    var audioPlayer = AudioPlayerFeature()
    var purchases = PurchasesFeature()
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .bookStore(let action):
            return bookStore.reduce(into: &state.bookStore, action: action)
                .map { Action.bookStore($0) }
        case .bookSummary(let action):
            return bookSummary.reduce(into: &state.bookSummary, action: action)
                .map { Action.bookSummary($0) }
        case .audioPlayer(let action):
            return audioPlayer.reduce(into: &state.audioPlayer, action: action)
                .map { Action.audioPlayer($0) }
        case .purchases(let action):
            return purchases.reduce(into: &state.purchases, action: action)
                .map { Action.purchases($0) }
        }
    }
}
