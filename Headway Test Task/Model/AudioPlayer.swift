//
//  AudioPlayer.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import Foundation
import AVFoundation
import ComposableArchitecture

struct AudioPlayer {
    enum DataFailure: Error, Equatable {
        case fileNotFound
        case fileNotLoaded
    }
    enum PlayingFailure: Error, Equatable {
        case playerNotLoaded
        case outOfDurationRange
    }
    var loadLocalFile: @Sendable (String) async -> DataFailure?
    var unload: @Sendable () async -> Void
    var play: @Sendable () async -> PlayingFailure?
    var pause: @Sendable () async -> PlayingFailure?
    var seekToTime: @Sendable (TimeInterval) async -> PlayingFailure?
}

extension AudioPlayer: DependencyKey {
    static var liveValue: Self {
        let playerActor = Actor()
        return Self(
            loadLocalFile: {
                await playerActor.loadLocalFile(name: $0)
            },
            unload: {
                await playerActor.unload()
            },
            play: {
                await playerActor.play()
            },
            pause: {
                await playerActor.pause()
            },
            seekToTime: {
                await playerActor.seekToTime($0)
            }
        )
    }
    
    private actor Actor {
        private var player: AVAudioPlayer?
        
        func loadLocalFile(name: String) -> DataFailure? {
            if let path = Bundle.main.path(forResource: name, ofType: "aac") {
                let url = URL(fileURLWithPath: path)
                do {
                    player = try AVAudioPlayer(contentsOf: url)
                } catch {
                    return .fileNotLoaded
                }
                return nil
            }
            else {
                return .fileNotFound
            }
        }
        
        func unload() {
            player?.stop()
            player = nil
        }
        
        func play() -> PlayingFailure? {
            guard let player else {
                return .playerNotLoaded
            }
            player.play()
            return nil
        }
        
        func pause() -> PlayingFailure? {
            guard let player else {
                return .playerNotLoaded
            }
            player.pause()
            return nil
        }
        
        func seekToTime(_ time: TimeInterval) -> PlayingFailure? {
            guard let player else {
                return .playerNotLoaded
            }
            guard time >= 0 && time <= player.duration else {
                return .outOfDurationRange
            }
            player.currentTime = time
            return nil
        }
    }
}

extension DependencyValues {
    var audioPlayer: AudioPlayer {
        get {
            self[AudioPlayer.self]
        }
        set {
            self[AudioPlayer.self] = newValue
        }
    }
}