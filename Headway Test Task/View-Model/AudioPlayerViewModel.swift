//
//  AudioPlayerViewModel.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import SwiftUI
import ComposableArchitecture

class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    
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
    
    }
    
    func seekToEndAction() {
    
    }
    
    func goBackward5SecondsAction() {
    
    }
    
    func goForward10SecondsAction() {
    
    }
    
    func seekToTimeAction(_ time: TimeInterval) {
    
    }
    
    // MARK: Private interface
    
    private func play() {
    
    }
    
    private func pause() {
    
    }
}
