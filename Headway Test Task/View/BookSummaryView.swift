//
// Created by Dmytro Kopanytsia on 30.10.2023.
//

import SwiftUI
import ComposableArchitecture

struct BookSummaryView: View {
    @Dependency(\.appCore) var appCore
    @ObservedObject var viewModel: BookSummaryViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            bookCover
            currentKeyPointLabel
            currentKeyPointTitle
            if viewModel.displayChapterList {
                keyPointList
            } else {
                audioPlayer
            }
            Spacer()
            modeToggle
        }
    }
    
    private var bookCover: some View {
        viewModel.coverImage?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            .padding(EdgeInsets(top: 48, leading: 64, bottom: 24, trailing: 64))
    }
    
    private var currentKeyPointLabel: some View {
        Text("KEY POINT \(viewModel.currentKeyPoint) OF \(viewModel.keyPointsNumber)")
            .lineLimit(2)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.gray)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
    
    private var currentKeyPointTitle: some View {
        Text(viewModel.currentKeyPointTitle)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(.black)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
    
    private var audioPlayer: some View {
        AudioPlayerView(viewModel: appCore.audioPlayerViewModel())
    }
    
    private var keyPointList: some View {
        KeyPointsListView(viewModel: appCore.keyPointsListViewModel())
    }
    
    private var modeToggle: some View {
        Toggle(isOn: $viewModel.displayChapterList, label: {
            Text("Toggle Label")
        })
            .toggleStyle(CustomToggleStyle())
    }
}

struct CustomToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .circular)
                .fill(Color.white)
                .frame(width: 110, height: 60)
                .overlay(
                    Circle()
                        .fill(Color.blue)
                        .padding(3)
                        .offset(x: configuration.isOn ? 25 : -25)
                )
                .addBorder(Color.gray, width: 0.5, cornerRadius: 30)
                .onTapGesture {
                    withAnimation {
                        configuration.isOn.toggle()
                    }
                }
            HStack(spacing: 20) {
                Image(systemName: "headphones")
                    .foregroundColor(configuration.isOn ? .black : .white)
                    .font(.system(size: 24))
                Image(systemName: "list.bullet")
                    .foregroundColor(configuration.isOn ? .white : .black)
                    .font(.system(size: 24))
            }
        }
    }
}

extension View {
    public func addBorder<S>(_ content: S, width: CGFloat = 1, cornerRadius: CGFloat) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(roundedRect.strokeBorder(content, lineWidth: width))
    }
}