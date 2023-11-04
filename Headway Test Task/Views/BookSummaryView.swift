//
// Created by Dmytro Kopanytsia on 30.10.2023.
//

import SwiftUI
import ComposableArchitecture

struct BookSummaryView: View {
    @Dependency(\.appCore) var appCore
    @StateObject var viewModel: BookSummaryViewModel
    
    var body: some View {
        VStack(alignment: .center) {
            bookCoverView
            Spacer()
            bookInfoView
            Spacer()
            if viewModel.displayChapterList {
                keyPointList
            } else {
                audioPlayer
            }
            Spacer()
            modeToggle
        }
    }
    
    private var bookCoverView: some View {
        ZStack {
            Color.clear
            if viewModel.isCoverImageLoading {
                LoadingView()
            }
            else {
                bookCover
            }
        }
            .frame(height: 400)
    }
    
    private var bookCover: some View {
        viewModel.coverImage?
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(12)
            .padding(EdgeInsets(top: 48, leading: 64, bottom: 24, trailing: 64))
    }
    
    private var bookInfoView: some View {
        VStack {
            currentKeyPointLabel
            currentKeyPointTitle
        }
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    private var currentKeyPointLabel: some View {
        Text("KEY POINT \(viewModel.currentKeyPoint) OF \(viewModel.keyPointsNumber)")
            .lineLimit(2)
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.appGray)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
    
    private var currentKeyPointTitle: some View {
        Text(viewModel.currentKeyPointTitle)
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(.invertibleBlack)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
    
    private var audioPlayer: some View {
        AudioPlayerView(viewModel: appCore.audioPlayerViewModel())
    }
    
    private var keyPointList: some View {
        KeyPointsListView(viewModel: appCore.keyPointsListViewModel())
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    private var modeToggle: some View {
        Toggle(isOn: $viewModel.displayChapterList, label: {
            Text("Toggle Label")
        })
            .toggleStyle(CustomToggleStyle())
    }
}
