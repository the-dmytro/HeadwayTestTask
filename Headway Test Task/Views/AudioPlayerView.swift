//
// Created by Dmytro Kopanytsia on 30.10.2023.
//

import SwiftUI

struct AudioPlayerView: View {
    @StateObject var viewModel: AudioPlayerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            slider
            switchSpeedButton
            Spacer()
            buttons
        }
            .padding(16)
            .disabled(viewModel.isLoaded == false)
            .opacity(viewModel.isLoaded ? 1 : 0.5)
    }
    
    private var slider: some View {
        Slider(value: $viewModel.currentTime,
            in: 0...viewModel.duration,
            onEditingChanged: { editing in
                viewModel.setSeekingActive(editing)
                if editing == false {
                    viewModel.seekToTimeAction(viewModel.currentTime)
                }
            },
            minimumValueLabel: Text(viewModel.currentTimeText),
            maximumValueLabel: Text(viewModel.durationText),
            label: { EmptyView() }
        )
            .font(.system(size: 12))
    }
    
    private var buttons: some View {
        HStack(spacing: 16) {
            seekToStartButton
            goBackward5SecondsButton
            playPauseButton
            goForward10SecondsButton
            seekToEndButton
        }
    }
    
    private var seekToStartButton: some View {
        Button(action: {
            viewModel.seekToStartAction()
        }, label: {
            Image(systemName: "backward.end.fill")
                .playerButtonStyle(.small)
        })
    }
    
    private var goBackward5SecondsButton: some View {
        Button(action: {
            viewModel.goBackward5SecondsAction()
        }, label: {
            Image(systemName: "gobackward.5")
                .playerButtonStyle(.medium)
        })
    }
    
    private var playPauseButton: some View {
        Button(action: {
            viewModel.playPauseButtonAction()
        }) {
            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                .playerButtonStyle(.large)
        }
    }
    
    private var goForward10SecondsButton: some View {
        Button(action: {
            viewModel.goForward10SecondsAction()
        }, label: {
            Image(systemName: "goforward.10")
                .playerButtonStyle(.medium)
        })
    }
    
    private var seekToEndButton: some View {
        Button(action: {
            viewModel.seekToEndAction()
        }, label: {
            Image(systemName: "forward.end.fill")
                .playerButtonStyle(.small)
        })
    }
    
    private var minimumValueLabel: some View {
        Text(viewModel.currentTimeText)
            .font(.system(size: 12))
            .foregroundColor(.appGray)
    }
    
    private var maximumValueLabel: some View {
        Text(viewModel.durationText)
            .font(.system(size: 12))
            .foregroundColor(.appGray)
    }
    
    private var switchSpeedButton: some View {
        Button(action: {
            viewModel.switchSpeedAction()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(.appGray.opacity(0.2))
                Text(viewModel.playingSpeedText)
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .foregroundColor(.invertibleBlack)
            }
                .frame(width: 74, height: 28)
        })
    }
}