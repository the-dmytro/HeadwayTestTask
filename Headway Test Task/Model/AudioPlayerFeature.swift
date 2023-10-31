//
//  AudioPlayerFeature.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import Foundation
import ComposableArchitecture
import AVFoundation

struct AudioPlayerFeature: Reducer {
    
    // MARK: Dependencies
    
    @Dependency(\.audioPlayer) var audioPlayer
    
    //MARK: Types
    
    enum Failure: Error, Equatable {
        case durationMismatch
    }
    
    enum AudioLoadingState: Equatable {
        case notLoaded
        case loading
        case loaded
        case error(Error)
        
        static func ==(lhs: AudioPlayerFeature.AudioLoadingState, rhs: AudioPlayerFeature.AudioLoadingState) -> Bool {
            switch (lhs, rhs) {
            case (.notLoaded, .notLoaded), (.loading, .loading), (.loaded, .loaded):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    enum AudioPlayingState: Equatable {
        case notPlaying
        case playing
        case paused
        case error(Error)
        
        static func ==(lhs: AudioPlayerFeature.AudioPlayingState, rhs: AudioPlayerFeature.AudioPlayingState) -> Bool {
            switch (lhs, rhs) {
            case (.notPlaying, .notPlaying), (.playing, .playing), (.paused, .paused):
                return true
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    struct State: Equatable {
        var metaData: AudioMetaData?
        var loadingState: AudioLoadingState = .notLoaded
        var playingState: AudioPlayingState = .notPlaying
        var currentTime: TimeInterval = 0
    }
    
    enum Action: Equatable {
        case loadMetaData(AudioMetaData)
        case loadFile(String)
        case loaded
        case loadingError(Error)
        
        case play
        case pause
        
        case seekToTime(TimeInterval)
        case seekToNextKeyPoint
        case seekToPreviousKeyPoint
        
        case startedPlaying
        case pausedPlaying
        case unableToPlay(Error)
        case unableToSeek(Error)
        case updateCurrentTime(TimeInterval)
        case updateDuration(TimeInterval)
        
        static func ==(lhs: AudioPlayerFeature.Action, rhs: AudioPlayerFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadMetaData(let lhsMetaData), .loadMetaData(let rhsMetaData)):
                return lhsMetaData == rhsMetaData
            case (.loadFile(let lhsFileName), .loadFile(let rhsFileName)):
                return lhsFileName == rhsFileName
            case (.loadingError(let lhsError), .loadingError(let rhsError)), (.unableToPlay(let lhsError), .unableToPlay(let rhsError)), (.unableToSeek(let lhsError), .unableToSeek(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.updateCurrentTime(let lhsTime), .updateCurrentTime(let rhsTime)), (.seekToTime(let lhsTime), .seekToTime(let rhsTime)):
                return lhsTime == rhsTime
            case (.updateDuration(let lhsDuration), .updateDuration(let rhsDuration)):
                return lhsDuration == rhsDuration
            case (.loaded, .loaded), (.play, .play), (.pause, .pause), (.startedPlaying, .startedPlaying), (.pausedPlaying, .pausedPlaying), (.seekToNextKeyPoint, .seekToNextKeyPoint), (.seekToPreviousKeyPoint, .seekToPreviousKeyPoint):
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadMetaData(let metaData):
            if state.playingState == .playing {
                return .run { send in
                    await send(.pause)
                    await send(.loadMetaData(metaData))
                }
            }
            else {
                state.metaData = metaData
                state.loadingState = .loading
                return .run { send in
                    await send(.loadFile(metaData.fileName))
                }
            }
            
        case .loadFile(let fileName):
            return .run { send in
                if let loadingFailure = await audioPlayer.loadLocalFile(fileName) {
                    await send(.loadingError(loadingFailure))
                }
                else {
                    await send(.loaded)
                }
                
                // TODO: add send(.updateCurrentTime(time.seconds)) to a player
                // TODO: add .updateDuration(playerItem.asset.duration.seconds) to a player
            }
            
        case .loaded:
            state.loadingState = .loaded
            return .none
            
        case .loadingError(let error):
            state.loadingState = .error(error)
            return .none
            
        case .play:
            switch state.loadingState {
            case .loaded:
                return .run { send in
                    if let failure = await audioPlayer.play() {
                        await send(.unableToPlay(failure))
                    }
                    else {
                        await send(.startedPlaying)
                    }
                }
                
            default:
                return .none
            }
        
        
        case .pause:
            if state.playingState == .playing {
                return .run { send in
                    if let failure = await audioPlayer.pause() {
                        await send(.unableToPlay(failure))
                    }
                    else {
                        await send(.pausedPlaying)
                    }
                }
            }
            else {
                return .none
            }
        case .seekToTime(let time):
            if state.loadingState == .loaded {
                return .run { send in
                    if let failure = await audioPlayer.seekToTime(time) {
                        await send(.unableToSeek(failure))
                    }
                }
            }
            else {
                return .none
            }
        case .seekToNextKeyPoint:
            // TODO: Seek to next key point
            return .none
        case .seekToPreviousKeyPoint:
            // TODO: Seek to previous key point
            return .none
        case .startedPlaying:
            state.playingState = .playing
            return .none
        case .pausedPlaying:
            state.playingState = .paused
            return .none
        case .unableToPlay(let failure):
            state.playingState = .error(failure)
            return .none
        case .unableToSeek(let failure):
            state.playingState = .error(failure)
            return .none
        case .updateCurrentTime(let time):
            state.currentTime = time
            return .none
        case .updateDuration(let duration):
            if let metaData = state.metaData, metaData.duration != duration {
                return .run { send in
                    await send(.loadingError(Failure.durationMismatch))
                }
            }
            else {
                return .none
            }
        }
    }
}
