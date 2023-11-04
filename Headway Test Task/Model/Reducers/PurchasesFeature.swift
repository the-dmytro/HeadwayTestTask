//
//  PurchasesFeature.swift
//  Headway Test Task
//
//  Created by Dmytro Kopanytsia on 27.10.2023.
//

import Foundation
import ComposableArchitecture
import StoreKit

struct PurchasesFeature: Reducer {
    // MARK: Dependencies
    
    @Dependency(\.purchasesProvider) var purchasesProvider
    
    // MARK: Types
    
    enum LoadingState: Equatable {
        case notLoaded
        case loading
        case loaded([Purchase.ID: Purchase])
        case error(Error)
        
        static func ==(lhs: LoadingState, rhs: LoadingState) -> Bool {
            switch (lhs, rhs) {
            case (.notLoaded, .notLoaded), (.loading, .loading):
                return true
            case (.loaded(let lhsPurchases), .loaded(let rhsPurchases)):
                return lhsPurchases == rhsPurchases
            case (.error(let lhsError), .error(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    struct State: Equatable {
        var loadingState: LoadingState = .notLoaded
        var purchases: [Purchase.ID: Purchase] = [:]
        var selectedPurchase: Purchase?
    }
    
    enum Action: Equatable {
        case loadProducts([Purchase.ID])
        case productsLoaded([Purchase.ID: Purchase])
        case unableToLoad(Error)
        case reloadProducts
        case selectPurchase(Purchase.ID)
        case deselectPurchase
        case purchase(Purchase.ID)
        case productPurchased(Purchase.ID)
        case unableToPurchase(Purchase.ID, Error)
        case resetSelectedPurchaseStatus
        
        static func ==(lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.loadProducts(let lhsProductIds), .loadProducts(let rhsProductIds)):
                return lhsProductIds == rhsProductIds
            case (.productsLoaded(let lhsPurchases), .productsLoaded(let rhsPurchases)):
                return lhsPurchases == rhsPurchases
            case (.unableToLoad(let lhsError), .unableToLoad(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.purchase(let lhsId), .purchase(let rhsId)), (.selectPurchase(let lhsId), .selectPurchase(let rhsId)), (.productPurchased(let lhsId), .productPurchased(let rhsId)):
                return lhsId == rhsId
            case (.deselectPurchase, .deselectPurchase), (.reloadProducts, .reloadProducts), (.resetSelectedPurchaseStatus, .resetSelectedPurchaseStatus):
                return true
            case (.unableToPurchase(let lhsId, let lhsError), .unableToPurchase(let rhsId, let rhsError)):
                return lhsId == rhsId && lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
    
    // MARK: Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadProducts(let productIds):
            state.loadingState = .loading
            state.purchases = productIds.reduce(into: [:]) { $0[$1] = Purchase(id: $1) }
            return .run { send in
                do {
                    let products = try await purchasesProvider.loadPurchasesAvailability(productIds)
                    await send(.productsLoaded(products))
                }
                catch {
                    await send(.unableToLoad(error))
                }
            }
            
        case .productsLoaded(let purchases):
            state.loadingState = .loaded(purchases)
            state.purchases = state.purchases.reduce(into: [:]) { $0[$1.key] = purchases[$1.key] }
            if let selectedPurchase = state.selectedPurchase {
                state.selectedPurchase = purchases[selectedPurchase.id]
            }
            return .none
            
        case .unableToLoad(let error):
            state.loadingState = .error(error)
            return .none
            
        case .reloadProducts:
            if state.purchases.keys.isEmpty == false {
                return .send(.loadProducts(Array(state.purchases.keys)))
            }
            else {
                return .none
            }
            
        case .selectPurchase(let purchaseID):
            state.selectedPurchase = state.purchases[purchaseID]
            return .none
            
        case .deselectPurchase:
            state.selectedPurchase = nil
            return .none
            
        case .purchase(let purchaseID):
            guard state.selectedPurchase?.id == purchaseID else {
                return .none
            }
            state.selectedPurchase?.status = .purchasing
            return .run { send in
                do {
                    try await purchasesProvider.purchase(purchaseID)
                    await send(.productPurchased(purchaseID))
                }
                catch {
                    await send(.unableToPurchase(purchaseID, error))
                }
            }
            
        case .productPurchased(let purchaseID):
            state.purchases[purchaseID]?.status = .purchased
            if state.selectedPurchase?.id == purchaseID {
                state.selectedPurchase?.status = .purchased
            }
            return .none
            
        case .unableToPurchase(let purchaseID, let error):
            if state.selectedPurchase?.id == purchaseID {
                state.selectedPurchase?.status = .error(error)
            }
            return .none
            
        case .resetSelectedPurchaseStatus:
            if let selectedPurchase = state.selectedPurchase {
                state.selectedPurchase = state.purchases[selectedPurchase.id]
            }
            return .none
        }
    }
}