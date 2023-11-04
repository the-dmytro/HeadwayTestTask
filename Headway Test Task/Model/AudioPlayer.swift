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
    typealias CurrentTimeUpdateCallback = (TimeInterval) async -> Void
    var loadLocalFile: @Sendable (String) async -> DataFailure?
    var unload: @Sendable () async -> Void
    var play: @Sendable () async -> PlayingFailure?
    var pause: @Sendable () async -> PlayingFailure?
    var seekToTime: @Sendable (TimeInterval) async -> PlayingFailure?
    var setRate: @Sendable (Float) async -> Void
    var setCurrentTimeUpdateCallback: @Sendable (CurrentTimeUpdateCallback?) async -> Void
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
            },
            setRate: {
                await playerActor.setRate($0)
            },
            setCurrentTimeUpdateCallback: {
                await playerActor.setCurrentTimeUpdateCallback($0)
            }
        )
    }
    
    private actor Actor {
        private var player = AVPlayer(playerItem: nil)
        private var latestRate: Float = 1
        private var currentTimeUpdateCallback: CurrentTimeUpdateCallback? // TODO: Come up with better solution
        
        init() {
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 60), queue: .main) { [weak self] time in
                Task(priority: .userInitiated) { [weak self] in
                    await self?.currentTimeUpdateCallback?(time.seconds)
                }
            }
        }
        
        func loadLocalFile(name: String) -> DataFailure? {
            if let path = Bundle.main.path(forResource: name, ofType: "m4a") {
                let url = URL(fileURLWithPath: path)
                let asset = AVURLAsset(url: url)
                let duration = asset.duration.seconds
                if duration < 0 {
                    return .fileNotLoaded
                }
                player.replaceCurrentItem(with: AVPlayerItem(asset: asset))
                return nil
            }
            else {
                return .fileNotFound
            }
        }
        
        func unload() async {
            await player.pause()
            player.replaceCurrentItem(with: nil)
        }
        
        func play() async -> PlayingFailure? {
            await player.playImmediately(atRate: latestRate)
            return nil
        }
        
        func pause() async -> PlayingFailure? {
            await player.pause()
            return nil
        }
        
        func seekToTime(_ time: TimeInterval) -> PlayingFailure? {
            guard let currentItem = player.currentItem else {
                return .playerNotLoaded
            }
            if time < 0 {
                player.seek(to: CMTime(seconds: 0, preferredTimescale: 60))
            }
            else if time > currentItem.duration.seconds {
                player.seek(to: CMTime(seconds: currentItem.duration.seconds, preferredTimescale: 60))
            }
            else {
                player.seek(to: CMTime(seconds: time, preferredTimescale: 60))
            }
            return nil
        }
        
        func setRate(_ rate: Float) async {
            if await player.rate > 0 {
                await player.playImmediately(atRate: rate)
            }
        }
        
        func setCurrentTimeUpdateCallback(_ callback: CurrentTimeUpdateCallback?) async {
            currentTimeUpdateCallback = callback
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
