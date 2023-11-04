//
// Created by Dmytro Kopanytsia on 04.11.2023.
//

import SwiftUI
import ComposableArchitecture

struct BookView: View {
    @Dependency(\.appCore) var appCore
    @StateObject var viewModel: BooksViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingView()
            } else {
                BookSummaryView(viewModel: appCore.bookSummaryViewModel())
                PayWallView(viewModel: appCore.payWallViewModel())
            }
        }
            .background(Color.appBackgroudColor)
    }
}
