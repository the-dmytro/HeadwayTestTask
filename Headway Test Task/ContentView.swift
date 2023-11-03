//
//  ContentView.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 25.10.2023.
//

import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    @Dependency(\.appCore) var appCore
    var body: some View {
        BookSummaryView(viewModel: appCore.bookSummaryViewModel())
            .background(Color(red: 254 / 255, green: 248 / 255, blue: 244 / 255))
    }
}
