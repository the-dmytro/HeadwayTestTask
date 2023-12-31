//
//  AudioPlayerViewModel.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import Foundation
import ComposableArchitecture
import Combine

class AudioPlayerViewModel: ObservableObject {
    enum PlayingSpeed: Float, CaseIterable {
        case x0_5 = 0.5
        case x1 = 1
        case x1_5 = 1.5
        case x2 = 2
        
        var title: String {
            switch self {
            case .x0_5:
                return "0.5x"
            case .x1:
                return "1x"
            case .x1_5:
                return "1.5x"
            case .x2:
                return "2x"
            }
        }
        
        var next: PlayingSpeed {
            if self == Self.allCases.last {
                return Self.allCases.first!
            }
            else {
                return Self.allCases.first(where: { $0.rawValue > self.rawValue })!
            }
        }
    }
    
    @Published var isLoaded: Bool = false
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0 {
        didSet {
            currentTimeText = String(format: "%d:%02d", Int(currentTime) / 60, Int(currentTime) % 60)
        }
    }
    @Published var duration: TimeInterval = 0 {
        didSet {
            durationText = String(format: "%d:%02d", Int(duration) / 60, Int(duration) % 60)
        }
    }
    @Published var currentTimeText: String = "0:00"
    @Published var durationText: String = "0:00"
    @Published var playingSpeedText = "Speed: \(PlayingSpeed.x1.title)"
    
    private var isSeekingActive = false
    private var playingSpeed: PlayingSpeed = .x1 {
        didSet {
            playingSpeedText = "Speed: \(playingSpeed.title)"
            print("playingSpeed: \(playingSpeed), playingSpeedText: \(playingSpeedText)")
        }
    }
    
    private let store: Store<AppState, AppAction>
    private var cancellableSet: Set<AnyCancellable> = []
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
        subscribe(store: store)
    }
    
    private func subscribe(store: Store<AppState, AppAction>) {
        store.scope(state: { $0.audioPlayer.loadingState }, action: AppAction.audioPlayer)
            .publisher
            .sink { [weak self] state in
                guard let self else {
                    return
                }
                switch state {
                case .notLoaded, .loading, .error:
                    self.isLoaded = false
                case .loaded:
                    self.isLoaded = true
                }
            }
            .store(in: &cancellableSet)
        
        store.scope(state: { $0.audioPlayer.playingState }, action: AppAction.audioPlayer)
            .publisher
            .sink { [weak self] state in
                guard let self else {
                    return
                }
                switch state {
                case .notPlaying, .paused, .error:
                    self.isPlaying = false
                case .playing:
                    self.isPlaying = true
                }
            }
            .store(in: &cancellableSet)
        
        store.scope(state: { $0.audioPlayer.currentTime }, action: AppAction.audioPlayer)
            .publisher
            .sink { [weak self] time in
                guard let self else {
                    return
                }
                if self.isSeekingActive == false { // TODO: Solve issue with isSeekingActive false all the time
                    self.currentTime = time
                }
            }
            .store(in: &cancellableSet)
        
        store.scope(state: { $0.audioPlayer.metaData }, action: AppAction.audioPlayer)
            .publisher
            .sink { [weak self] metaData in
                guard let self else {
                    return
                }
                self.duration = metaData?.duration ?? 0
            }
            .store(in: &cancellableSet)
    }
    
    // MARK: UI interactions
    
    func playPauseButtonAction() {
        if isPlaying {
            pause()
        }
        else {
            play()
        }
    }
    
    func seekToStartAction() {
        seekToStart()
    }
    
    func seekToEndAction() {
        seekToEnd()
    }
    
    func goBackward5SecondsAction() {
        goBackward5Seconds()
    }
    
    func goForward10SecondsAction() {
        goForward10Seconds()
    }
    
    func seekToTimeAction(_ time: TimeInterval) {
        seekToTime(time)
    }
    
    func setSeekingActive(_ isActive: Bool) {
        isSeekingActive = isActive
    }
    
    func switchSpeedAction() {
        switchSpeed()
    }
    
    // MARK: Private interface
    
    private func play() {
        store.send(.audioPlayer(.play))
    }
    
    private func pause() {
        store.send(.audioPlayer(.pause))
    }
    
    private func seekToStart() {
        store.send(.audioPlayer(.seekToPreviousKeyPoint))
    }
    
    private func seekToEnd() {
        store.send(.audioPlayer(.seekToNextKeyPoint))
    }
    
    private func goBackward5Seconds() {
        store.send(.audioPlayer(.seekToTime(currentTime - 5)))
    }
    
    private func goForward10Seconds() {
        store.send(.audioPlayer(.seekToTime(currentTime + 10)))
    }
    
    func seekToTime(_ time: TimeInterval) {
        store.send(.audioPlayer(.seekToTime(time)))
    }
    
    func switchSpeed() {
        playingSpeed = playingSpeed.next
        store.send(.audioPlayer(.setPlayingRate(playingSpeed.rawValue)))
    }
}
