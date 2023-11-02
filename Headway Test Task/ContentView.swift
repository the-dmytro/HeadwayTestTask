//
//  ContentView.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 25.10.2023.
//

import SwiftUI

struct ContentView: View {
    let appCore: AppCore
    var body: some View {
        BookSummaryView(viewModel: appCore.bookSummaryViewModel())
    }
}
