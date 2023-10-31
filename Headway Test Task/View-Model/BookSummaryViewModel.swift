//
//  BookSummaryViewModel.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import SwiftUI
import ComposableArchitecture

class BookSummaryViewModel: ObservableObject {
    @Published var image: Image?
    @Published var title: String = ""
    @Published var keyPointsNumber: Int = 0
    @Published var currentKeyPoint: Int = 0
    @Published var currentKeyPointTitle: String = ""
}
