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
        BookView(viewModel: appCore.booksViewModel())
    }
}
