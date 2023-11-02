//
// Created by Dmytro Kopanytsia on 02.11.2023.
//

import Foundation
import ComposableArchitecture

struct BookKeyPointsFeature: Reducer {
    struct State: Equatable {
        var keyPoints: [BookSummaryKeyPoint]
        var selectedKeyPoint: BookSummaryKeyPoint?
    }
    
    enum Action: Equatable {
        typealias KeyPointIndex = Int
        
        case selectKeyPoint(KeyPointIndex)
        case adjustKeyPointToTime(TimeInterval)
        case deselectKeyPoint
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .selectKeyPoint(let index):
            state.selectedKeyPoint = state.keyPoints.indices.contains(index) ? state.keyPoints[index] : nil
            return .none
        
        case .adjustKeyPointToTime(let time):
            if let keyPoint = state.keyPoints.first(where: { time > $0.start }) {
                state.selectedKeyPoint = keyPoint
            } else {
                state.selectedKeyPoint = nil
            }
            return .none
            
        case .deselectKeyPoint:
            state.selectedKeyPoint = nil
            return .none
        }
    }
}
