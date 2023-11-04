//
// Created by Dmytro Kopanytsia on 03.11.2023.
//


import ComposableArchitecture
import Combine

class PayWallViewModel: ObservableObject {
    @Published var isPresented = false
    @Published var isLoading = false
    @Published var isProcessingPurchase = false
    @Published var isAvailable = false
    @Published var purchaseButtonText = "-"
    @Published var generalErrorText: String?
    @Published var purchaseErrorText: String?
    
    private var selectedPurchase: Purchase? {
        didSet {
            if let selectedPurchase = selectedPurchase {
                purchaseButtonText = "Start listening - \(selectedPurchase.price)"
            } else {
                purchaseButtonText = "Purchase unavailable"
            }
        }
    }
    
    private let store: Store<AppState, AppAction>
    private var cancellableSet: Set<AnyCancellable> = []
    
    init(store: Store<AppState, AppAction>) {
        self.store = store
        subscribe(store: store)
    }
    
    private func subscribe(store: Store<AppState, AppAction>) {
        store.scope(state: { $0.purchases.loadingState }, action: AppAction.purchases)
            .publisher
            .combineLatest(store.scope(state: { $0.purchases.selectedPurchase }, action: AppAction.purchases).publisher)
            .sink { [weak self] combined in
                guard let self else {
                    return
                }
                self.generalErrorText = nil
                self.purchaseErrorText = nil
                
                let loadingState = combined.0
                let selectedPurchase = combined.1
                
                switch loadingState {
                case .notLoaded:
                    self.isPresented = true
                    self.isLoading = false
                    self.isProcessingPurchase = false
                    self.isAvailable = false
                case .loading:
                    self.isPresented = true
                    self.isLoading = true
                    self.isProcessingPurchase = false
                    self.isAvailable = false
                case .loaded:
                    self.isPresented = selectedPurchase?.status != .purchased
                    self.isLoading = false
                    self.isProcessingPurchase = selectedPurchase?.status == .purchasing
                    self.isAvailable = selectedPurchase?.status == .available
                case .error:
                    self.isPresented = true
                    self.isLoading = false
                    self.isProcessingPurchase = false
                    self.isAvailable = false
                    self.generalErrorText = "Unable to load purchases, please wait a moment"
                }
                
                if let selectedPurchase = selectedPurchase {
                    switch selectedPurchase.status {
                    case .error:
                        self.purchaseErrorText = "Unable to purchase, please try again"
                        
                    default:
                        self.purchaseErrorText = nil
                    }
                }
                self.selectedPurchase = selectedPurchase
            }
            .store(in: &cancellableSet)
    }
    
    func purchaseAction() {
        purchase()
    }
    
    private func purchase() {
        if let selectedPurchase = selectedPurchase {
            store.send(.purchases(.purchase(selectedPurchase.id)))
        }
    }
}
