//
// Created by Dmytro Kopanytsia on 30.10.2023.
//

import SwiftUI

struct AudioPlayerView: View {
    @ObservedObject var viewModel: AudioPlayerViewModel
    
    var body: some View {
        VStack {
            slider
                .padding()
            Spacer()
            buttons
                .padding()
        }
    }
    
    private var slider: some View {
        Slider(value: $viewModel.currentTime,
            onEditingChanged: { editing in
                if !editing {
                    viewModel.seekToTimeAction(viewModel.currentTime)
                }
            },
            minimumValueLabel: Text("\(viewModel.currentTime)"),
            maximumValueLabel: Text("\(viewModel.duration)"),
            label: { EmptyView() })
    }
    
    private var buttons: some View {
        HStack {
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
                .font(.title)
        })
    }
    
    private var goBackward5SecondsButton: some View {
        Button(action: {
            viewModel.goBackward5SecondsAction()
        }, label: {
            Image(systemName: "gobackward.5")
                .font(.title)
        })
    }
    
    private var playPauseButton: some View {
        Button(action: {
            viewModel.playPauseButtonAction()
        }) {
            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
        }
    }
    
    private var goForward10SecondsButton: some View {
        Button(action: {
            viewModel.goForward10SecondsAction()
        }, label: {
            Image(systemName: "goforward.10")
                .font(.title)
        })
    }
    
    private var seekToEndButton: some View {
        Button(action: {
            viewModel.seekToStartAction()
        }, label: {
            Image(systemName: "forward.end.fill")
                .font(.title)
        })
    }
}
