//
// Created by Dmytro Kopanytsia on 02.11.2023.
//

import Foundation
import ComposableArchitecture

enum UserAction: Equatable {
    case playPauseButtonAction
    case seekToStartAction
    case seekToEndAction
    case goBackward5SecondsAction
    case goForward10SecondsAction
    case seekToTimeAction(TimeInterval)
}