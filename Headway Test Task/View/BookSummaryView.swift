//
// Created by Dmytro Kopanytsia on 30.10.2023.
//

import SwiftUI

struct BookSummaryView: View {
    @ObservedObject var viewModel: BookSummaryViewModel
    var body: some View {
        VStack(alignment: .center) {
            bookCover
            currentKeyPointLabel
            currentKeyPointTitle
            audioPlayer
        }
    }
    
    private var bookCover: some View {
        viewModel.coverImage?
            .resizable()
            .scaledToFill()
            .cornerRadius(10)
    }
    
    private var currentKeyPointLabel: some View {
        Text("KEY POINT \(viewModel.currentKeyPoint) OF \(viewModel.keyPointsNumber)")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.gray)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
    
    private var currentKeyPointTitle: some View {
        Text(viewModel.currentKeyPointTitle)
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black)
            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
    }
    
    private var audioPlayer: some View {
        AudioPlayerView(viewModel: AudioPlayerViewModel())
    }
}
