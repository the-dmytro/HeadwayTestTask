//
//  BookSummaryViewModel.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import SwiftUI
import ComposableArchitecture
import Combine

class BookSummaryViewModel: ObservableObject {
    @Published private(set) var coverImage: Image?
    @Published private(set) var isCoverImageLoading: Bool = false
    @Published private(set) var title: String = ""
    @Published private(set) var keyPointsNumber: Int = 0
    @Published private(set) var currentKeyPoint: Int = 0
    @Published private(set) var currentKeyPointTitle: String = ""
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    init(store: Store<AppState, AppAction>) {
        subscribe(store: store)
    }
    
    private func subscribe(store: Store<AppState, AppAction>) {
        store.scope(state: { $0.bookSummary.coverImageLoadingState }, action: AppAction.bookSummary)
            .publisher
            .sink { [weak self] state in
                guard let self else {
                    return
                }
                switch state {
                case .notLoaded:
                    self.isCoverImageLoading = false
                    self.coverImage = nil
                case .loading:
                    self.isCoverImageLoading = true
                    self.coverImage = nil
                case .loaded(let image):
                    self.isCoverImageLoading = false
                    self.coverImage = Image(uiImage: image)
                case .error:
                    self.isCoverImageLoading = false
                    self.coverImage = nil
                }
            }
            .store(in: &cancellableSet)
        
        store.scope(state: { $0.bookSummary.selectedBook }, action: AppAction.bookSummary)
            .publisher
            .sink { [weak self] book in
                guard let self else {
                    return
                }
                if let book = book {
                    self.title = book.title
                    self.keyPointsNumber = book.keyPoints.count
                    self.currentKeyPoint = 0
                    self.currentKeyPointTitle = book.keyPoints.first?.title ?? ""
                } else {
                    self.title = ""
                    self.keyPointsNumber = 0
                    self.currentKeyPoint = 0
                    self.currentKeyPointTitle = ""
                }
            }
            .store(in: &cancellableSet)
        
        store.scope(state: { $0.bookSummary.selectedKeyPoint }, action: AppAction.bookSummary)
            .publisher
            .sink { [weak self] keyPoint in
                guard let self else {
                    return
                }
                if let keyPoint = keyPoint {
                    // TODO: set index of key point
                    self.currentKeyPointTitle = keyPoint.title
                } else {
                    self.currentKeyPoint = 0
                    self.currentKeyPointTitle = ""
                }
            }
            .store(in: &cancellableSet)
    }
}
