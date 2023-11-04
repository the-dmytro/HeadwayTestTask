//
// Created by Dmytro Kopanytsia on 03.11.2023.
//

import Foundation
import ComposableArchitecture

struct ScenarioFeature: Reducer {
    typealias State = AppState
    typealias Action = AppAction
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .bookStore(let action):
            return processBookStoreAction(action)
            
        case .bookSummary(let action):
            return processBookSummaryAction(action)
            
        case .bookKeyPoints(let action):
            return processBookKeyPointsAction(action)
            
        case .audioPlayer(let action):
            return processAudioPlayerAction(action)
            
        case .purchases(let action):
            return processPurchasesAction(action)
        }
    }
    
    private func processBookStoreAction(_ action: BookStoreFeature.Action) -> Effect<Action> {
        switch action {
        case .booksLoaded(let books):
            if let book = books.first {
                return .merge(
                    .send(.bookSummary(.selectBook(book))),
                    .send(.purchases(.loadProducts(books.compactMap({ $0.productId }))))
                )
            }
            else {
                return .none
            }
        case .loadBooks, .error:
            return .none
        }
    }
    
    private func processBookSummaryAction(_ action: BookSummaryFeature.Action) -> Effect<Action> {
        switch action {
        case .deselectBook:
            return .merge(
                .send(.audioPlayer(.unloadAudio)),
                .send(.bookKeyPoints(.unloadKeyPoints)),
                .send(.purchases(.deselectPurchase))
            )
        case .selectBook(let book):
            return .merge(
                .send(.bookKeyPoints(.loadKeyPoints(book.keyPoints))),
                .send(.audioPlayer(.loadMetaData(book.audioMetaData))),
                .send(.audioPlayer(.loadCuePoints(book.keyPoints.map { $0.start }))),
                .send(.purchases(.selectPurchase(book.productId)))
            )
        default:
            return .none
        }
    }
    
    private func processBookKeyPointsAction(_ action: BookKeyPointsFeature.Action) -> Effect<Action> {
        switch action {
        case .keyPointSelected(let keyPoint):
            return .send(.audioPlayer(.seekToTime(keyPoint.start)))
        default:
            return .none
        }
    }
    
    private func processAudioPlayerAction(_ action: AudioPlayerFeature.Action) -> Effect<Action> {
        switch action {
        case .seekToTime(let time), .updateCurrentTime(let time):
            return .send(.bookKeyPoints(.adjustKeyPointToTime(time)))
        default:
            return .none
        }
    }
    
    private func processPurchasesAction(_ action: PurchasesFeature.Action) -> Effect<Action> {
        switch action {
//        case .productPurchased(let purchase):
//            return
        default:
            return .none
        }
    }
}
