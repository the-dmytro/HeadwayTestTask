//
// Created by Dmytro Kopanytsia on 02.11.2023.
//

import Foundation
import ComposableArchitecture

struct BookKeyPointsFeature: Reducer {
    struct State: Equatable {
        var keyPoints: [BookSummaryKeyPoint] = []
        var selectedKeyPoint: BookSummaryKeyPoint? = nil
    }
    
    enum Action: Equatable {
        typealias KeyPointIndex = Int
        
        case loadKeyPoints([BookSummaryKeyPoint])
        case selectKeyPoint(KeyPointIndex)
        case keyPointSelected(BookSummaryKeyPoint)
        case adjustKeyPointToTime(TimeInterval)
        case deselectKeyPoint
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadKeyPoints(let keyPoints):
            state.keyPoints = keyPoints
            state.selectedKeyPoint = keyPoints.first
            return .none
        
        case .selectKeyPoint(let index):
            state.selectedKeyPoint = state.keyPoints.indices.contains(index) ? state.keyPoints[index] : nil
            return .none
            
        case .keyPointSelected(let keyPoint):
            state.selectedKeyPoint = keyPoint
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
