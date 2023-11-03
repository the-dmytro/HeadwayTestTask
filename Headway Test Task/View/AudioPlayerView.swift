//
// Created by Dmytro Kopanytsia on 30.10.2023.
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var viewModel: AudioPlayerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            slider
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
                if !editing {
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
            viewModel.seekToStartAction()
        }, label: {
            Image(systemName: "forward.end.fill")
                .playerButtonStyle(.small)
        })
    }
    
    private var minimumValueLabel: some View {
        Text(viewModel.currentTimeText)
            .font(.system(size: 12))
            .foregroundColor(.gray)
    }
    
    private var maximumValueLabel: some View {
        Text(viewModel.durationText)
            .font(.system(size: 12))
            .foregroundColor(.gray)
    }
}

struct PlayerButtonStyle: ViewModifier {
    enum PlayerButtonStyleType: CGFloat {
        case small = 23
        case medium = 28
        case large = 36
    }
    
    let type: PlayerButtonStyleType
    init(_ type: PlayerButtonStyleType = .medium) {
        self.type = type
    }
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: type.rawValue))
            .foregroundColor(.black)
    }
}

extension Image {
    func playerButtonStyle(_ type: PlayerButtonStyle.PlayerButtonStyleType) -> some View {
        self.modifier(PlayerButtonStyle(type))
    }
}