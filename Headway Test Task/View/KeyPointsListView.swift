//
// Created by Dmytro Kopanytsia on 03.11.2023.
//

import SwiftUI

struct KeyPointsListView: View {
    @ObservedObject var viewModel: KeyPointsListViewModel
    var body: some View {
        VStack(alignment: .center) {
            List(viewModel.keyPoints, id: \.id) { keyPoint in
                KeyPointView(keyPoint: keyPoint, isSelected: keyPoint == viewModel.currentKeyPoint)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectKeyPoint(keyPoint)
                        }
                    }
            }
                .listStyle(.plain)
        }
    }
}

struct KeyPointView: View {
    let keyPoint: BookSummaryKeyPoint
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(keyPoint.title)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(isSelected ? .black : .gray)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
        .background(Color.clear)
        .cornerRadius(12)
    }
}